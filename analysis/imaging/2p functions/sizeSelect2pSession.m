function sizeSelect2pSession( fileName, sessionName,psfile)
dbstop if error
%%% create session file for passive presentation of behavior (grating patch) stim
%%% reads raw images, calculates dfof, and aligns to stim sync
dt = 0.1; %%% resampled time frame
framerate=1/dt;

cycLength=1;
blank =1;

cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters
cfg.syncToVid=1; cfg.saveDF=0;
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

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
% moviefname = 'C:\sizeSelect2sf5sz14min.mat';
moviefname = 'C:\sizeSelect2sf8sz26min.mat';
load (moviefname)
ntrials= min(dt*length(dfofInterp)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dfofInterp,onsets,dt,timepts);
timepts = timepts - isi;

timepts = round(timepts*1000)/1000;
sbxfilename = fileName;
meandfofInterp = squeeze(mean(mean(dfofInterp,1),2))';
display('saving')
save(sessionName,'meandfofInterp','xpos','sf','theta','phase','radius','radiusRange','timepts','moviefname','sbxfilename','-append')

%keyboard

sz = unique(radius);
freq = unique(sf);
x=unique(xpos);
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end

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
        subplot(2,length(sz)/2,s)
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


data = zeros(size(dFout,1),size(dFout,2),size(dFout,3),length(sz),length(x),2);
for s = 1:length(sz);
    for loc = 1:length(x);
        for f = 1:length(freq);
            data(:,:,:,s,loc,f) = mean(dFout(:,:,:,xpos == x(loc) & radius ==sz(s) & sf ==freq(f)),4);
        end
    end
end


mainfig = figure
location =1; s = 4;
imagesc(squeeze(mean(dFout(:,:,find(timepts==duration),xpos==x(location) & radius == sz(s))-dFout(:,:,find(timepts==0),xpos==x(location) & radius==sz(s)),4)),[0 0.25]); colormap jet

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

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