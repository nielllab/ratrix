%%% clear;
close all
clear all

addpath(genpath('utilities'));

align2pSessions; %%% select session files and align to reference
shiftx = round(shiftx-mean(shiftx));
shifty = round(shifty-mean(shifty));

for session = 1:length(shiftx)
    
  display(sprintf('loading %s',sessionName{session}))
    tic, load(filename{session},'dfofInterp','meanImg','greenframe'); toc
    
    border=32;nframes = size(dfofInterp,3);
    
    F = (1 + dfofInterp).* repmat(meanImg,[1 1 size(dfofInterp,3)]);  %%% reconstruct F from dF/F
    F=  circshift(F, -[shiftx(session) shifty(session) 0]);  %%% shift to standard coordinates
    
    meanShiftImg = circshift(meanImg,-[shiftx(session) shifty(session) ]);
    meanShiftImg = meanShiftImg((border+1):end-border,(border+1):end-border);


Y = F((border+1):end-border,(border+1):end-border,1:nframes); clear  F dfofInterp
size(Y)

Y = Y - min(Y(:)); 
if ~isa(Y,'double');    Y = double(Y);  end         % convert to double

[d1,d2,T] = size(Y);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels

% Set parameters

K = 500;                                           % number of components to be found
tau = 2;   %%% default = 4                                      % std of gaussian kernel (size of neuron) 
p = 2;         %%% default =2                                   % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
merge_thr = 0.8;                                  % merging threshold

options = CNMFSetParms(...                      
    'd1',d1,'d2',d2,...                         % dimensions of datasets
    'search_method','ellipse','dist',2,... %default =3  % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.9,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                    % merging threshold
    'gSig',tau,...
    'min_size',2,'max_size',5, ...  %%% default 3 an d8
    'sx',12,'df_prctile',5, ...     %%% default 16, 50
    'restimate_g', 1,  ...            %%% recalc AR coefficients during updating (maybe turn this off so we can hard code or upper limit?
    'nb',4 ...                  %%% default 1
    );

%% Data pre-processing
[P,Y] = preprocess_data(Y,p);

Yr = reshape(Y,d,T);

if session ==1
    
%% fast initialization of spatial components using greedyROI and HALS
[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options);  % initialize

clear Y;

% display centers of found components
Cn =  reshape(P.sn,d1,d2); %correlation_image(Y); %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
figure;imagesc(Cn);
    axis equal; axis tight; hold all;
    scatter(center(:,2),center(:,1),'mo');
    title('Center of ROIs found from initialization algorithm');
    drawnow;

%% update spatial components
display('doing spatial components')
tic
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,Ain,P,options);
toc

%% update temporal components
display('doing temporal components')
tic
[C,f,P,S] = update_temporal_components(Yr,A,b,Cin,fin,P,options);
toc

%% merge found components
[Am,Cm,K_m,merged_ROIs,P,Sm] = merge_components(Yr,A,b,C,f,P,S,options);

%% repeat
display('repeat spatial temporal')
tic
[A2,b2,Cm] = update_spatial_components(Yr,Cm,f,Am,P,options);
[C2,f2,P,S2] = update_temporal_components(Yr,A2,b2,Cm,f,P,options);
toc

[A_or,C_or,S_or,P] = order_ROIs(A2,C2,S2,P); % order components
    Aref = A_or; bref=b2;

else
  clear Y
  display('doing temporal components')
tic

[Cm,f,P,S] = update_temporal_components(Yr,Aref,bref,[],[],P,options);
toc
 C_or=Cm; S_or=S; f2 = f;
end

%% do some plotting
K_m = size(C_or,1);
[C_df,~,S_df] = extract_DF_F(Yr,[A_or,b2],[C_or;f2],S_or,K_m+(1:options.nb)); % extract DF/F values (optional)


%% display components
plot_components_GUI(Yr,A_or,C_or,b2,f2,Cn,options)

for i = 1:size(A_or,2);
    usePts{i} = find(A_or(:,i));
end

if session==1
figure
draw2pSegs(usePts,1:length(usePts),jet,size(meanShiftImg,1),1:length(usePts),[1 length(usePts)])

contour_threshold = 0.95;                       % amount of energy used for each component to construct contour plot
figure;
[Coor,json_file] = plot_contours(A_or,reshape(P.sn,d1,d2),contour_threshold,0); % contour plot of spatial footprints
end

dF = C_df; spikes = S_df;
   
figure
imagesc(dF,[0 1]); title(filename{session});
drawnow

% overlay = zeros(size(meanShiftImg,1),size(meanShiftImg,2),3);
% refCells = reshape(mean(Aref,2), size(meanShiftImg));
% theseCells = reshape(mean(A_or,2), size(meanShiftImg));
% figure
% imagesc(refCells,[0 1])
% figure
% imagesc(theseCells,[0 1]);
% overlay(:,:,1) = 10*refCells;
% overlay(:,:,2) = 10*theseCells;
% overlay(overlay>1)=1;
% figure
% imshow(overlay);


suffix = '_Eff_pts4nb';
    outname = [filename{session}(1:end-4) '_' suffix '.mat'];
    save(outname,'dF','greenframe','meanImg','usePts','spikes','meanShiftImg');
    
    keyboard
end
