function topo2pOcto(fileName,sessionName,psfile)%%% create session file for topo (periodic spatial) stim
%%% reads raw images, calculates dfof, and aligns to stim sync
close all

psfile = 'C:\temp\temp.ps'
  if exist(psfile,'file')==2;delete(psfile);end
dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=10;
cycFrames = framerate*cycLength;

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
nframes = floor(nframes/cycFrames)*cycFrames;
dfofInterp = dfofInterp(:,:,1:nframes);


global info
mv = info.aligned.T;
buffer(:,1) = max(mv,[],1)/cfg.spatialBin+1; buffer(buffer<1)=1;
buffer(:,2) = max(-mv,[],1)/cfg.spatialBin+1; buffer(buffer<0)=0;
buffer=round(buffer)
buffer(2,:) = buffer(2,:)+32 %%% to account for deadbands;
dfof = dfofInterp;
dfofInterp= dfof(buffer(1,1):(end-buffer(1,2)),buffer(2,1):(end-buffer(2,2)),:);


figure
plot((1:size(dfofInterp,3))*dt,squeeze(mean(mean(dfofInterp,2),1)))
title('mean fluorescence');
xlabel('secs')

%%% generate pixel-wise fourier map
cycLength = cycLength/dt;
map = 0;
filt = fspecial('gaussian',10,2);
for i= 1:size(dfofInterp,3);
    map = map+imfilter(dfofInterp(:,:,i),filt)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);

figure
imagesc(amp); title('amp'); colormap jet; axis equal

prctile(amp(:),98)
amp=amp/prctile(amp(:),98); amp = amp-0.2; amp(amp>1)=1; amp(amp<0)=0;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,2))
colormap(hsv); colorbar

polarImg = img;

display('saving data')
save(sessionName,'polarImg','map','-append')

display('saving polar img')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

% %%% generate cycle average movie
% % movieFile = [fileName(1:end-4) '_cycAvg.avi'];
% movieFile = [fileName '_cycAvg.avi'];
%     
clear cycAvg mov
figure
for i = 1:cycLength
cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
%imagesc(cycAvg(:,:,i),[-0.1 0.5]); colormap gray; axis equal
%mov(i) = getframe(gcf);
end

% vid = VideoWriter(movieFile);
% vid.FrameRate=8;
% open(vid);
% writeVideo(vid,mov);
% close(vid)



cycAvgT = mean(mean(cycAvg,2),1);
figure
plot(squeeze(cycAvgT));
title('timecourse cyc avg');
xlabel ('frames')
display('saving timecourse fig')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

[fPDF, pPDF] = uiputfile('*.pdf','save pdf file');
newpdfFile = fullfile(pPDF,fPDF);
try
    dos(['ps2pdf ' psfile ' "' newpdfFile '"'] )
    
catch
    display('couldnt generate pdf');
end

sbxfilename = fileName;
save(sessionName,'sbxfilename','-append')

keyboard
