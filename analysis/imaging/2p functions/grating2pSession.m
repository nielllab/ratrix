function grating2pSession(fileName,sessionName, psfile);
%%% create session file for grating (2sf, 4sec on / 4sec off) stim
%%% reads raw images, calculates dfof, and aligns to stim sync

dt = 0.25; %%% resampled time frame
framerate=1/dt;

cycLength=8;
blank =1;

cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=4;  %%% configuration parameters
get2pSession_sbx;


%%% generate pixel-wise fourier map
cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[0 2*pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)
title('cycle fourier analysis')
colormap(hsv); colorbar

figure
tcourse = squeeze(mean(mean(dfofInterp,2),1));
plot((1:length(tcourse))*dt,tcourse);

if ~blank
    gratingfname = 'C:\grating2p8orient2sf.mat';
else
    gratingfname = 'C:\grating2p8orient2sfBlank.mat';
end
load(gratingfname);

%dfofInterp = imresize(dfofInterp,0.5);
dfReshape = reshape(dfofInterp, size(dfofInterp,1)*size(dfofInterp,2),size(dfofInterp,3));
[osi osifit tuningtheta amp  tfpref pmin R resp tuning spont] = gratingAnalysis(gratingfname, 1,dfReshape,dt,blank);

osi = reshape(osi,   size(dfofInterp,1), size(dfofInterp,2) );
R = reshape(R,size(dfofInterp,1), size(dfofInterp,2));
theta =reshape(tuningtheta,size(dfofInterp,1), size(dfofInterp,2));
tfpref = reshape(tfpref,size(dfofInterp,1), size(dfofInterp,2));
resp = reshape(resp,size(dfofInterp,1), size(dfofInterp,2),size(resp,2));

figure
imagesc(squeeze(mean(resp,3)),[-0.5 0.5]);
title('responsiveness')

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
figure
imshow(im)
osi_norm = 2*osi; osi_norm(isnan(osi_norm))=0; osi_norm(osi_norm>1)=1;
figure
imagesc(osi_norm); title('osinorm')
%osi_norm = osifit;

R_norm=R/2; R_norm(R_norm>1)=1; R_norm(R_norm<0)=0;
figure
imagesc(R_norm); title('Rnorm')
white =ones(size(im(:,:,1)));

for c = 1:3
    im(:,:,c) = (white.*(1-osi_norm) + im(:,:,c).*osi_norm).*R_norm;
end
figure
imshow(imresize(im,4));
title('orientation preference')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end


j= jet;
j = j(end/2:end,:);
tf_im = mat2im(tfpref,jet,[-1 1]);
for c =1:3
    tf_im(:,:,c) = tf_im(:,:,c).*R_norm;
end
figure
imshow(imresize(tf_im,4));
title('sf preference')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end