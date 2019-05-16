% this script runs a quick test for topox or topoy to get cycavg and
% fourier map

%%add pixel-wise, thresholded histogram of phase

% %%% reads raw images, calculates dfof, and aligns to stim sync
close all; clear all;dbstop if error
sbxaligndir
fileName = uigetfile('*.sbx','topox file');

dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=10;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters
cfg.syncToVid=0; cfg.saveDF=0; cfg.alignData=0;
sessionName = 'topo';
get2pSession_sbx;

nframes = min(size(dfofInterp,3),3000);  %%% limit topoY data to 5mins to avoid movie boundaries
dfofInterp = dfofInterp(:,:,1:nframes);

%%% generate pixel-wise fourier map
cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);
prctile(amp(:),98)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,0.5))
colormap(hsv); colorbar
title('fourier map')

clear cycAvg mov
figure
for i = 1:cycLength
cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
end
cycAvgT = squeeze(mean(mean(cycAvg,2),1));
    figure
plot(cycAvgT); title('cycle average')
    

