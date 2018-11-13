function spot2pSession(fileName,sessionName,psfile)%%% create session file for topo (periodic spatial) stim
%%% reads raw images, calculates dfof, and aligns to stim sync

dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=1;

global S2P

if (exist('S2P','var')&S2P==1)
    cfg.dt = dt; cfg.spatialBin=1; cfg.temporalBin=1;  %%% configuration parameters suite2p
    cfg.syncToVid=1; cfg.saveDF=0; cfg.nodfof=1;
else
    cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
    cfg.syncToVid=1; cfg.saveDF=0;
end
get2pSession_sbx;

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

xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
moviefname = 'C:\sizeTest.mat'
load(moviefname)
nframes = min(size(dfofInterp,3),length(sf)*10+10);  %%% limit topoY data to 5mins to avoid movie boundaries
dfofInterp = dfofInterp(:,:,1:nframes);
ntrials= min(dt*length(dfofInterp)/(isi+duration),length(sf))-1;
ntrials = length(sf);
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dfofInterp,onsets,dt,timepts);
timepts = timepts - isi;
timepts = round(timepts*1000)/1000;
sbxfilename = fileName;
meandfofInterp = squeeze(mean(mean(dfofInterp,1),2))';
        
sz = unique(radius);
freq = unique(sf);
x=unique(xpos);
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)); end

load(['stim_obj' fileName(end-7:end)]);
% load(stimobj)
spInterp = get2pSpeed(stimRec,dt,size(dfofInterp,3));
running = zeros(1,ntrials);
for i = 1:ntrials
    running(i) = mean(spInterp(1,1+cycLength*(i-1):cycLength+cycLength*(i-1)),2)>20;
end

% for location=1:length(x)
%     figure
%     set(gcf,'Name',sprintf('xpos = %d',x(location)))
%     for s =1:length(sz)
%         img =  squeeze(mean(dFout(:,:,find(timepts==duration),xpos==x(location) & radius == sz(s))-dFout(:,:,find(timepts==0),xpos==x(location) & radius==sz(s)),4));
%         subplot(2,ceil(length(sz)/2),s)
%         imagesc(img,[0 0.25]); axis equal; colormap jet; title(sprintf('size %d',sizes{s}));
%         resp(s,:) = squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(location)& radius==sz(s)),4),2),1))- squeeze(mean(mean(mean(dFout(:,:,find(timepts==0),xpos==x(location)& radius==sz(s)),4),2),1));
%     end
%     
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
%     
%     figure
%     plot(timepts,resp'); ylim([-0.05 0.2]); title(sprintf('xpos = %d',x(location))); legend(sizes);
%     
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
%     
% end
% 
% 
% figure
% cwdth=size(dfofInterp,1)/2;
% swdth=ceil(cwdth/4);
% hold on
% plot(squeeze(nanmean(nanmean(dfofInterp(cwdth-5:cwdth+5,cwdth-5:cwdth+5,:),2),1)),'g-')
% plot(squeeze(nanmean(nanmean(dfofInterp(swdth-5:swdth+5,swdth-5:swdth+5,:),2),1)),'r-')
% legend('center','surround','location','northwest')
% xlabel('frames')
% ylabel('dfof')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

%%get rid of temporal info and have first, second half and whole
frmdata = nan(size(dFout,1),size(dFout,2),length(freq),length(sz),2);
for s = 1:length(sz);
    for fre = 1:length(freq)
        for r = 1:2
            frmdata(:,:,fre,s,r) = nanmean(nanmean(dFout(:,:,9:11,radius==sz(s)&sf==freq(fre)&running==(r-1)),4),3)-...
                nanmean(nanmean(dFout(:,:,1:4,radius==sz(s)&sf==freq(fre)&running==(r-1)),4),3);
        end
    end
end

for i = 1:length(freq)
    figure;
    colormap jet
    for j = 1:length(sz)
        subplot(2,ceil(length(sz)/2),j)
        imagesc(frmdata(:,:,i,j,1),[-0.01 0.1])
        set(gca,'ytick',[],'xtick',[])
        axis square
        xlabel(sprintf('%ddeg',radiusRange(j)*2))
    end
    mtit(sprintf('sit sf=%0.2f',freq(i)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end

save(sessionName,'sbxfilename','frmdata','meandfofInterp','xpos','sf','theta','phase','radius','radiusRange','timepts','moviefname','sbxfilename','-append')

