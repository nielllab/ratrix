%%% create session file for topo (periodic spatial) stim
%%% reads raw images, calculates dfof, and aligns to stim sync

clear all

dt = 0.25; %%% resampled time frame
framerate=1/dt;
cycLength=10;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=4;  %%% configuration parameters
get2pSession_sbx;

%%% generate pixel-wise fourier map
cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
amp = abs(map);
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[0 2*pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)
colormap(hsv); colorbar

%%% generate cycle average movie
[f p] = uiputfile('*.avi','cycle avg movie file?');
if p~=0
    clear cycAvg mov
    figure
    for i = 1:cycLength
        cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
        imagesc(cycAvg(:,:,i),[-0.1 0.5]); colormap gray; axis equal
        mov(i) = getframe(gcf);
    end
    vid = VideoWriter(fullfile(p,f));
    vid.FrameRate=8;
    open(vid);
    writeVideo(vid,mov);
    close(vid)
end
