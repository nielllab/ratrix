%%% clear;
close all
clear all

addpath(genpath('utilities'));

align2pSessions; %%% select session files and align to reference
shiftx = round(shiftx-mean(shiftx));
shifty = round(shifty-mean(shifty));

framesPerSess = 3000;

allF = [];
for session = 0:length(shiftx)
    
    if session ==0
        for mergeSess=1:length(shiftx);
            
            loadAlignSessiondata
            nf = size(F,3);
            downsamp = round(nf/framesPerSess); if downsamp<1, downsamp=1,end;
            allF = cat(3,allF,F(:,:,downsamp:downsamp:end));
            usedFrames(mergeSess) = size(allF,3);
        end
    else
        loadAlignSessiondata
        allF=F;
    end
    clear F dfofInterp;
    
    
    if session ==0
        figure
        display('getting correlation map');
        tic
        imagesc(correlation_image(allF(:,:,10:10:end)));
        toc
        [cropy cropx] = ginput(2);
        cropx = sort(round(cropx)); cropy= sort(round(cropy));
    end
    
    
    %%% default cropy = [33 364}; cropx = [33 364]
    meanShiftImg = meanShiftImg(cropx(1):cropx(2),cropy(1):cropy(2));
    figure
    imagesc(meanShiftImg); colormap gray
    nframes = min(size(allF,3),10^5)
    Y = allF(cropx(1):cropx(2),cropy(1):cropy(2),1:nframes); clear allF
    size(Y)
    
    Y = Y - min(Y(:));
    if ~isa(Y,'double');    Y = double(Y);  end         % convert to double
    
    [d1,d2,T] = size(Y);                                % dimensions of dataset
    d = d1*d2;                                          % total number of pixels
    
    % Set parameters
    
    %K = 400;                                           % number of components to be found
    tau = 2.5;   %%% default = 4                                      % std of gaussian kernel (size of neuron)
    if session==0
        p=0;
        cell_est = 10^3*d1*d2/(500^2);                  %%% estimate number of cells by 10^5/mm^3 = 10^3 per 1mm field of view 10um deep
        sprintf('estimated %d cells in field, might want to multiple by 1.5 to find %d',round(cell_est), round(cell_est*1.5))
        K = input('how many cells? ');
    else
        p = 1;
    end
    %%% default =2                                   % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
    merge_thr = 0.85;                                  % merging threshold
    
    options = CNMFSetParms(...
        'd1',d1,'d2',d2,...                         % dimensions of datasets
        'search_method','ellipse','dist',2,... %default =3  % search locations when updating spatial components
        'deconv_method','constrained_foopsi',...    % activity deconvolution method
        'temporal_iter',2,...                       % number of block-coordinate descent steps
        'fudge_factor',0.9,...                     % bias correction for AR coefficients  %%% = 0.7 for .25sec data
        'merge_thr',merge_thr,...                    % merging threshold
        'gSig',tau,...
        'min_size',2,'max_size',6, ...  %%% default 3 an d8
        'sx',12,'df_prctile',5, ...     %%% default 16, 50
        'restimate_g', 1,  ...            %%% recalc AR coefficients during updating (maybe turn this off so we can hard code or upper limit?
        'nb',1, ...                  %%% default 1
        'noise_range', [0.25 0.5] ...  %%% noise range for calculating SNR (should be above signal freqs) default [0.25 0.5]; set to [0.375 0.5] for 0.25sec data
        );
    
    %% Data pre-processing
    [P,Y] = preprocess_data(Y,p);
    Cn =  reshape(P.sn,d1,d2); %correlation_image(Y); %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
    Cn = correlation_image(Y(:,:,10:10:end));
    
    Yr = reshape(Y,d,T);
    
    if session ==0
        
        %% fast initialization of spatial components using greedyROI and HALS
        tic
        [Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options);  % initialize
        toc
        
        
        % display centers of found components
        
        figure;imagesc(Cn);
        axis equal; axis tight; hold all;
        scatter(center(:,2),center(:,1),'mo');
        title('Center of ROIs from initialization overlaid on SNR'); colorbar
        drawnow;
        
        clear Y;
        
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
        display('spatial')
        [A2,b2,Cm] = update_spatial_components(Yr,Cm,f,Am,P,options);
        toc
        display('temporal')
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
    
    if session==0
        figure
        draw2pSegs(usePts,1:length(usePts),jet,size(meanShiftImg,1),1:length(usePts),[1 length(usePts)])
        
        contour_threshold = 0.95;                       % amount of energy used for each component to construct contour plot
        figure;
        [Coor,json_file] = plot_contours(A_or,reshape(P.sn,d1,d2),contour_threshold,0); % contour plot of spatial footprints
    end
    
    dF = C_df; spikes = S_df;
    
    figure
    imagesc(dF,[0 1]); colorbar
    if session>0,    
        title([filename{session} ' dF']),
    else  title('merged sessions dF')
        hold on
        for s= 1:length(shiftx);
            plot([usedFrames(s) usedFrames(s)],[1 size(dF,1)],'g','Linewidth',2)
        end
    end
    
    figure
    imagesc(spikes,[0 0.2]); colorbar
 if session>0,    
        title([filename{session} ' spikes']),
    else  title('merged sessions spikes')
        hold on
        for s= 1:length(shiftx);
            plot([sum(usedFrames(1:s)) sum(usedFrames(1:s))],[1 size(dF,1)],'g')
        end
    end
    
    
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
    
    if session>0
        suffix = '_allfiles_PTS_dF';
        outname = [filename{session}(1:end-4) '_' suffix '.mat'];
        thisSession = filename{session};
        save(outname,'dF','greenframe','meanImg','usePts','spikes','meanShiftImg','cropx','cropy','thisSession');
    end
    
end
