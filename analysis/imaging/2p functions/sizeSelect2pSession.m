function sizeSelect2pSession(fileName,sessionName,psfile)
dbstop if error
%%% create session file for passive presentation of behavior (grating patch) stim
%%% reads raw images, calculates dfof, and aligns to stim sync
dt = 0.1; %%% resampled time frame
framerate=1/dt;

cycLength=1;
blank =1;

global S2P

if (exist('S2P','var')&S2P==1)
    cfg.dt = dt; cfg.spatialBin=1; cfg.temporalBin=1;  %%% configuration parameters suite2p
    cfg.syncToVid=1; cfg.saveDF=0; cfg.nodfof=1;
else
    cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters
    cfg.syncToVid=1; cfg.saveDF=0;
end
get2pSession_sbx;

global info

figure
plot(info.aligned.T);
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

m=double(info.aligned.m);
upper = prctile(m(:),95)*1.2;
lower = min(m(:));
figure
imagesc(m,[lower upper]); colormap gray; title('sbx aligned mean'); axis equal
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end


cycLength = cycLength/dt;
% map = 0;
% for i= 1:size(dfofInterp,3);
%     map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
% end
% amp = abs(map);
% amp=amp/prctile(amp(:),98); amp(amp>1)=1;
% img = mat2im(mod(angle(map),2*pi),hsv,[0 2*pi]);
% img = img.*repmat(amp,[1 1 3]);
% mapimg= figure
% figure
% imshow(img)
% colormap(hsv); colorbar
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
% moviefname = 'C:\sizeSelect2sf8sz26min.mat';
moviefname = 'C:\sizeselectBin22min.mat'
% moviefname = 'C:\sizeselectLongISI22min.mat'
load(moviefname)
ntrials= floor(min(dt*length(dfofInterp)/(isi+duration),length(sf)))-1
sf=sf(1:ntrials); theta=theta(1:ntrials); phase=phase(1:ntrials); radius=radius(1:ntrials); xpos=xpos(1:ntrials);
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
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end

load(['stim_obj' fileName(end-7:end)]);
% load(stimobj)
spInterp = get2pSpeed(stimRec,dt,size(dfofInterp,3));
running = zeros(1,ntrials);
for i = 1:ntrials
    running(i) = mean(spInterp(1,1+cycLength*(i-1):cycLength+cycLength*(i-1)),2)>20;
end

% top = squeeze(mean(dFout(:,:,find(timepts==1),xpos==x(1))-dFout(:,:,find(timepts==0),xpos==x(1)),4));
% bottom = squeeze(mean(dFout(:,:,find(timepts==1),xpos==x(end))-dFout(:,:,find(timepts==0),xpos==x(end)),4));
% figure
% subplot(2,2,1)
% imagesc(top,[0 0.25]); axis equal; title('top')
% subplot(2,2,2)
% imagesc(bottom,[0 0.25]); axis equal; title('bottom')
% subplot(2,2,3)
% top(top<0)=0; bottom(bottom<0)=0;
% imagesc((top-bottom)./(top+bottom),[-1 1]); title('top-bottom')
% subplot(2,2,4);
% plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(1)),4),2),1)))
% hold on
% plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(end)),4),2),1)))
% title('position'); xlim([min(timepts) max(timepts)]);
%


for location=1:length(x)
    figure
    set(gcf,'Name',sprintf('xpos = %d',x(location)))
    for s =1:length(sz)
        img =  squeeze(mean(dFout(:,:,find(timepts==duration),xpos==x(location) & radius == sz(s))-dFout(:,:,find(timepts==0),xpos==x(location) & radius==sz(s)),4));
        subplot(2,ceil(length(sz)/2),s)
        imagesc(img,[0 0.25]); axis equal; colormap jet; title(sprintf('size %d',sizes{s}));
        resp(s,:) = squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(location)& radius==sz(s)),4),2),1))- squeeze(mean(mean(mean(dFout(:,:,find(timepts==0),xpos==x(location)& radius==sz(s)),4),2),1));
    end
    
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    figure
    plot(timepts,resp'); ylim([-0.05 0.2]); title(sprintf('xpos = %d',x(location))); legend(sizes);
    
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
end


figure
cwdth=size(dfofInterp,1)/2;
swdth=ceil(cwdth/4);
hold on
plot(squeeze(nanmean(nanmean(dfofInterp(cwdth-5:cwdth+5,cwdth-5:cwdth+5,:),2),1)),'g-')
plot(squeeze(nanmean(nanmean(dfofInterp(swdth-5:swdth+5,swdth-5:swdth+5,:),2),1)),'r-')
legend('center','surround','location','northwest')
xlabel('frames')
ylabel('dfof')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

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
    for j = 2:length(sz)
        subplot(2,floor(length(sz)/2),j-1)
        imagesc(frmdata(:,:,i,j,1),[-0.01 0.1])
        set(gca,'ytick',[],'xtick',[])
        axis square
        xlabel(sprintf('%sdeg',sizes{j}))
    end
    mtit(sprintf('sit sf=%0.2f',freq(i)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end

% %%%this code breaks down into first and half of session, saved because we
% %%%know they look the same so it should be fine but just in case
% %%get rid of temporal info and have first, second half and whole
% frmdata = nan(size(dFout,1),size(dFout,2),length(sz),2);frmdata1=frmdata;frmdata2=frmdata;
% starttrial = ceil(length(radius)/2);
% for s = 1:length(sz);
%     for r = 1:2
%         frmdata(:,:,s,r) = nanmean(nanmean(dFout(:,:,9:11,radius==sz(s)&running==(r-1)),4),3)-...
%             nanmean(nanmean(dFout(:,:,1:4,radius==sz(s)&running==(r-1)),4),3);
%         frmdata1(:,:,s,r) = nanmean(nanmean(dFout(:,:,9:11,find(radius(1:starttrial)==sz(s)&running(1:starttrial)==(r-1))),4),3)-...
%             nanmean(nanmean(dFout(:,:,1:4,find(radius(1:starttrial)==sz(s)&running(1:starttrial)==(r-1))),4),3);
%         frmdata2(:,:,s,r) = nanmean(nanmean(dFout(:,:,9:11,find(radius(starttrial+1:end)==sz(s)&running(starttrial+1:end)==(r-1))+starttrial),4),3)-...
%             nanmean(nanmean(dFout(:,:,1:4,find(radius(starttrial+1:end)==sz(s)&running(starttrial+1:end)==(r-1))+starttrial),4),3);
% %     for loc = 1:length(x);
% %         for f = 1:length(freq);
% %             data(:,:,:,s,loc,f) = mean(dFout(:,:,:,xpos == x(loc) & radius ==sz(s) & sf ==freq(f)),4);
% %         end
% %     end
%     end
% end
% 
% plotmin=0;
% plotmax=0.15*max(max(max(frmdata(:,:,:,1))));
% figure;
% colormap jet
% subplot(2,3,1)
% imagesc(frmdata1(:,:,4,1),[plotmin plotmax])
% set(gca,'ytick',[],'xtick',[])
% axis square
% xlabel('1st half 20deg')
% subplot(2,3,2)
% imagesc(frmdata2(:,:,4,1),[plotmin plotmax])
% set(gca,'ytick',[],'xtick',[])
% axis square
% xlabel('2nd half 20deg')
% subplot(2,3,3)
% imagesc(frmdata(:,:,4,1),[plotmin plotmax])
% set(gca,'ytick',[],'xtick',[])
% axis square
% xlabel('Total 20deg')
% subplot(2,3,4)
% imagesc(frmdata1(:,:,end,1),[plotmin plotmax])
% set(gca,'ytick',[],'xtick',[])
% axis square
% xlabel('1st half 50deg')
% subplot(2,3,5)
% imagesc(frmdata2(:,:,end,1),[plotmin plotmax])
% set(gca,'ytick',[],'xtick',[])
% axis square
% xlabel('2nd half 50deg')
% subplot(2,3,6)
% imagesc(frmdata(:,:,end,1),[plotmin plotmax])
% set(gca,'ytick',[],'xtick',[])
% axis square
% xlabel('Total 50deg')
% mtit('sit dF across experiment')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end


% mainfig = figure
% location =1; s = 4;
% imagesc(squeeze(mean(dFout(:,:,find(timepts==duration),xpos==x(location) & radius == sz(s))-dFout(:,:,find(timepts==0),xpos==x(location) & radius==sz(s)),4)),[0 0.25]); colormap jet
% 
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

display('saving')
save(sessionName,'frmdata','meandfofInterp','xpos','sf','theta','phase','radius','radiusRange','timepts','moviefname','sbxfilename','-append')
%%%'frmdata1','frmdata2',

% for i = 1:10;
%     figure(mainfig)
%     [ypt xpt] = ginput(1); xpt= round(xpt); ypt= round(ypt);
%     hold on
%     plot(ypt,xpt,'go')
%     response = squeeze(data(xpt,ypt,:,:,1,1));
%     for s = 1:size(response,2);
%         response(:,s) = response(:,s) - response(find(timepts==0),s);
%     end
%     
%     figure
%     plot(response)
%     sz_tune(i,:) = squeeze(mean(response(8:10,:),1)); sz_tune(i,:) = sz_tune(i,:)/max(sz_tune(i,:));
%     figure
%     plot(sz_tune(i,:));
% end
% 
% figure
% plot(sz_tune');