clear all
close all

dt = 0.25;
framerate=1/dt;
[f p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');

if strcmp(f(end-3:end),'.mat')
    display('loading data')
    load(fullfile(p,f))
    display('done')
else
    blank = input('stim includes blank? 0/1 : ');
    cycLength = input('cycle length : ');
    dfofInterp = get2pdata(fullfile(p,f),dt,cycLength);
    [f p] = uiputfile('*.mat','session data');
    
    figure
    timecourse = squeeze(mean(mean(dfofInterp(:,:,1:60/dt),2),1));
    plot(timecourse);
    
    startTime = input('start time : ');
    display('saving data')
    sessionName= fullfile(p,f);
    save(sessionName,'dfofInterp','blank','startTime','-v7.3');   
     display('done')
end

if ~blank
    gratingfname = 'C:\grating2p8orient2sf.mat';
else
    gratingfname = 'C:\grating2p8orient2sfBlank.mat';
end
load(gratingfname);

% timecourse = squeeze(mean(mean(dfofInterp,2),1));
% template = zeros((isi+duration)/dt,1);
% template((isi/dt+1):(isi+duration)/dt)=1;
% template = repmat(template,length(xpos),1);
% for lag = 1:240;
%     match(lag)=sum(template.*timecourse(lag:lag+length(template)-1));
% end
% figure
% plot(match)
% [ymax startTime]=max(match);
% startTime=startTime-3;
% sprintf('suggested start time = %d',startTime);
% startTime = input('start time : ');

dfReshape = reshape(dfofInterp, size(dfofInterp,1)*size(dfofInterp,2),size(dfofInterp,3));
[osi osifit tuningtheta amp  tfpref pmin R resp] = gratingAnalysis(gratingfname, startTime,dfReshape,dt,blank);

osi = reshape(osi,   size(dfofInterp,1), size(dfofInterp,2) );
R = reshape(R,size(dfofInterp,1), size(dfofInterp,2));
theta =reshape(tuningtheta,size(dfofInterp,1), size(dfofInterp,2));
tfpref = reshape(tfpref,size(dfofInterp,1), size(dfofInterp,2));
resp = reshape(resp,size(dfofInterp,1), size(dfofInterp,2),size(resp,2));

figure
imagesc(squeeze(mean(resp,3)),[-0.5 0.5]);

for doOrientationFig = 1:0
    figure
    im1=squeeze(max(max(orientation(:,:,[1 5],:),[],4),[],3));
    imagesc(im1,[0 0.75])
    colormap gray
    im1= im1/1;
    im1(im1<0)=0; im1(im1>1)=1;
    im1 = im1(25:end,1:end-25);
    figure
    imshow(im1)
    
    figure
    
    im2=squeeze(max(max(orientation(:,:,[3 7],:),[],4),[],3));
    imagesc(im2,[0 0.75])
    colormap gray
    im2= im2/1;
    im2(im2<0)=0; im2(im2>1)=1;
    im2 = im2(25:end,1:end-25);
    figure
    imshow(im2)
    
    
    im = zeros(size(im1,1),size(im1,2),3);
    im(:,:,1)=im1;
    im(:,:,2)=im2;
    im(:,:,3)=im2;
    
    figure
    imshow(im)
end

figure
imagesc(R,[0 2]);

theta(isnan(theta))=-0.1;
im = mat2im(theta,hsv,[-0.1 pi]);
osi_norm = 3*osi; osi_norm(osi_norm>1)=1;
R_norm=R/2; R_norm(R_norm>1)=1; R_norm(R_norm<0)=0;

white =ones(size(im(:,:,1)));

for c = 1:3
    im(:,:,c) = (white.*(1-osi_norm) + im(:,:,c).*osi_norm).*R_norm;
end
figure
imshow(imresize(im,4));
title('orientation preference')

j= jet;
j = j(end/2:end,:);
tf_im = mat2im(tfpref,j,[-1 1]);
for c =1:3
    tf_im(:,:,c) = tf_im(:,:,c).*R_norm;
end
figure
imshow(imresize(tf_im,4));
title('tf preference')

ptsfname = uigetfile('*.mat','pts file');
if ptsfname==0
    [pts dF neuropil] = get2pPts(dfofInterp);
else
    load(ptsfname);
end
dFClean = dF-0.7*repmat(neuropil,size(dF,1),1);

[osi osifit tuningtheta amp  tfpref pmin R resp]= gratingAnalysis(gratingfname, startTime,dFClean,dt,blank);


c = 'rgbcmk'
figure
hold on
trange = 50:1250
for i = 1:size(dF,1);
    i
    plot((1:length(trange))*dt/60,(dF(i,trange)-neuropil(trange)) + i,c(mod(i,6)+1));
end
ylim([0 size(dF,1)+2]); xlim([0 length(trange)*dt/60]);
xlabel('mins')

save(sessionName,'osi','osifit','tuningtheta','amp','pmin','R','tfpref','-append');


