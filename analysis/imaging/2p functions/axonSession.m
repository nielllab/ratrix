%%%i turned function mode on PRLP 070317
%function axonSession(fileName,sessionName,psfile)%%% create session file for topo (periodic spatial) stim
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
prctile(amp(:),98)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,0.5))
colormap(hsv); colorbar

polarImg = img;
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

cycAvgT = mean(mean(cycAvg,2),1);
figure
plot(squeeze(cycAvgT(1,1,:)));
title('timecourse cyc avg');
xlabel ('frames')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end


vid = VideoWriter(movieFile);
vid.FrameRate=8;
open(vid);
writeVideo(vid,mov);
close(vid)

filt= fspecial('average',3);
tic
dfFilt2 = medfilt1(imresize(dfofInterp,0.5),3,[],3);
toc

% tic
% for i = 1:size(dfofInterp,3);
%    if i/100 == round(i/100)
%        i
%    end
%    dfFilt2(:,:,i) = medfilt2(dfFilt(:,:,i),[3 3]);
% end
% toc

stdImg = std(dfFilt2,[],3);
maxImg = max(dfFilt2,[],3);
skewImg = skewness(dfFilt2,[],3);
stdFig = figure
imagesc(stdImg,[0.1 0.5]); colormap gray
figure
imagesc(maxImg,[0.5 3]); colormap gray
figure
imagesc(skewImg,[ 0 4]); colormap gray

figure
imagesc(sqrt(meanImg),sqrt([ 250 500])); colormap gray


figure
for i = 1:300;
    if mod(i,4)==0
        figure
    end
    subplot(2,2,mod(i,4)+1);
%     imagesc(dfFilt2(:,:,i*10+5).*imresize(meanImg,0.5)); colormap gray; title(sprintf('%d',i*10));
    %%%it was crashing on this line so I deleted the +5 PRLP 070317
    imagesc(dfFilt2(:,:,i*10).*imresize(meanImg,0.5),[100 1000]); colormap gray; title(sprintf('%d',i*10));
end
figure
for i = 1050:1070;
    if mod(i,4)==0
        figure
    end
    subplot(2,2,mod(i,4)+1);
    imagesc(dfFilt2(:,:,i).*imresize(meanImg,0.5)); colormap gray; title(sprintf('%d',i*10));
end


figure; 
imagesc(sqrt(mean(dfFilt2(:,:,[585:595 220:230]),3).*imresize(meanImg,0.5)),sqrt([ 100 1000])); colormap gray

for i = 1:20;
    figure(stdFig); hold on
    [x(i),y(i)] = ginput(1);
    plot(x(i),y(i),'b*');
end
x=round(x); y= round(y);

clear trace
for i = 1:20;
    trace(i,:) = medfilt1(squeeze(dfFilt2(y(i),x(i),:)),5) - 0.5 + i;
    %%%this was operating on dfFilt before but it didn't exist, so I
    %%%assumed it was supposed to be dFilt2 PRLP 070317
end
figure
plot((1:size(trace,2))*0.1,trace')


figure
plot(mean(trace,1))


sbxfilename = fileName;
save(sessionName,'sbxfilename','-append')

