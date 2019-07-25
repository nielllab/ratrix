function topo2pSession(fileName,sessionName,psfile)%%% create session file for topo (periodic spatial) stim
%%% reads raw images, calculates dfof, and aligns to stim sync

dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=10;

global S2P

if (exist('S2P','var')&S2P==1)
    cfg.dt = dt; cfg.spatialBin=1; cfg.temporalBin=1;  %%% configuration parameters suite2p
    cfg.syncToVid=1; cfg.saveDF=0; cfg.nodfof=1;
else
    cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
    cfg.syncToVid=1; cfg.saveDF=0;
end
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
%maxAmp = prctile(amp(:),95)  %%% changed from 98 to 95 for better scaling - cmn072119
maxAmp = 0.15;
amp=amp/maxAmp; amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,1))
colormap(hsv); colorbar
title(sprintf('%s maxAmp = %0.2f',sessionName,maxAmp));

polarImg = img;

display('saving')
save(sessionName,'polarImg','map','dfofInterp','-append')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%%% generate cycle average movie
% movieFile = [fileName(1:end-4) '_cycAvg.avi'];
movieFile = [fileName '_cycAvg.avi'];
    
clear cycAvg mov
figure
for i = 1:cycLength
cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
imagesc(cycAvg(:,:,i),[-0.1 0.5]); colormap gray; axis equal
mov(i) = getframe(gcf);
end

cycAvgT = mean(mean(cycAvg,2),1); %%%  should find a way to select pixels above a certain intensity, so we don't average noise
figure
plot(squeeze(cycAvgT(1,1,:)));
title('timecourse cyc avg');
xlabel ('frames')
%%% CMN commented out since it's a repeat of figure made in get2pSession - 0722319
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end


vid = VideoWriter(movieFile);
vid.FrameRate=8;
open(vid);
writeVideo(vid,mov);
close(vid)

tcourse = squeeze(mean(mean(dfofInterp,2),1)); %%% save this out to avoid reading in all data later


sbxfilename = fileName;
save(sessionName,'sbxfilename','cycAvgT','tcourse','-append')

