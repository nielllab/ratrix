function occlusion2pSession(fileName,sessionName,psfile)%%% create session file for topo (periodic spatial) stim
%%% reads raw images, calculates dfof, and aligns to stim sync
cond=[];isi=[];
plotrange = [-0.01 0.45]; %range for imagesc plots
aniState={'sit','run'};
dt = 0.1; %%% resampled time frame
imagerate=1/dt;
cycLength = 5;

global S2P

if (exist('S2P','var')&S2P==1)
    cfg.dt = dt; cfg.spatialBin=1; cfg.temporalBin=1;  %%% configuration parameters suite2p
    cfg.syncToVid=1; cfg.saveDF=0; cfg.nodfof=1;
else
    cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
    cfg.syncToVid=1; cfg.saveDF=0;
end
get2pSession_sbx;

% %%% generate pixel-wise fourier map
% cycLength = cycLength/dt;
% map = 0;
% for i= 1:size(dfofInterp,3);
%     map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
% end
% map = map/size(dfofInterp,3); map(isnan(map))=0;
% amp = abs(map);
% prctile(amp(:),98)
% amp=amp/prctile(amp(:),98); amp(amp>1)=1;
% img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
% img = img.*repmat(amp,[1 1 3]);
% mapimg= figure
% figure
% imshow(imresize(img,0.5))
% colormap(hsv); colorbar
% 
% polarImg = img;
% save(sessionName,'polarImg','map','dfofInterp','-append')
% 
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% %%% generate cycle average movie
% % movieFile = [fileName(1:end-4) '_cycAvg.avi'];
% movieFile = [fileName '_cycAvg.avi'];
%     
% clear cycAvg mov
% figure
% for i = 1:cycLength
% cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
% imagesc(cycAvg(:,:,i),[-0.1 0.5]); colormap gray; axis equal
% mov(i) = getframe(gcf);
% end
% 
% cycAvgT = mean(mean(cycAvg,2),1);
% figure
% plot(squeeze(cycAvgT(1,1,:)));
% title('timecourse cyc avg');
% xlabel ('frames')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% 
% vid = VideoWriter(movieFile);
% vid.FrameRate=8;
% open(vid);
% writeVideo(vid,mov);
% close(vid)

xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
moviefname = 'C:\occludeStim5cond_2theta_6min.mat'
load(moviefname)
% nframes = min(size(dfofInterp,3),length(sf)*10+10);  %%% limit topoY data to 5mins to avoid movie boundaries
% dfofInterp = dfofInterp(:,:,1:nframes);
% ntrials= min(dt*length(dfofInterp)/(isi+duration),length(sf))-1;
cycLength=duration+isi;
load(['stim_obj' fileName(end-7:end)],'stimRec');
reps = floor(size(dfofInterp,3)/(size(moviedata,3)/60)/10); %how many times did you let the movie repeat?
frm1 = find(stimRec.f==1);frm1 = frm1(1:reps);
strtframes = round((stimRec.ts(frm1)-stimRec.ts(1))*10)+1;
ntrials = length(cond);
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;

dFout = nan(size(dfofInterp,1),size(dfofInterp,2),length(timepts),ntrials*reps);
for i = 1:reps
    df = dfofInterp(:,:,strtframes(i):strtframes(i)+length(cond)*cycLength*imagerate+isi*imagerate);
    df = align2onsets(df,onsets,dt,timepts);
    dFout(:,:,:,1+(i-1)*ntrials:i*ntrials) = df;
end
ntrials = ntrials*reps;cond=repmat(cond,[1 reps]);theta=repmat(theta,[1 reps]);
timepts = timepts - isi;
timepts = round(timepts*1000)/1000;
sbxfilename = fileName;
meandfofInterp = squeeze(mean(mean(dfofInterp,1),2))';

spInterp = get2pSpeed(stimRec,dt,size(dfofInterp,3));
running = zeros(1,ntrials);
for i = 1:ntrials
    running(i) = mean(spInterp(1,1+cycLength*(i-1):cycLength+cycLength*(i-1)),2)>20;
end


frmdata = nan(size(dFout,1),size(dFout,2),size(dFout,3),length(condList)-1,2);
for c = 1:length(condList)-1;
        for r = 1:2
            frmdata(:,:,:,c,r) = nanmean(dFout(:,:,:,cond==c&running==(r-1)),4)-...
                nanmean(dFout(:,:,:,cond==length(condList)&running==(r-1)),4);
        end
end
frmdata = frmdata(:,25:end-25,:,:,:);

sprintf('Pick center of visual response')
midpt = isi*imagerate + round(imagerate*duration/2);
figure;
colormap jet
imagesc(squeeze(frmdata(:,:,midpt,1,1)),plotrange)
axis off; axis equal
title('select center of response @ midpoint time of moving spot')
[y x] = ginput(1);
hold on
plot(y,x,'wo','MarkerSize',15)
x=round(x); y=round(y);
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

f1=figure;f2=figure;
spr = 20; %half-length of square used to pull out local response amplitude
for i = 1:size(frmdata,4)
    for r = 1:2 %sit/run
        if isnan(squeeze(frmdata(1,1,1,i,r)))
            continue
        else
            figure
            plot(timepts,squeeze(nanmean(nanmean(frmdata(:,:,:,i,r),2),1)))
            xlabel('time (s)')
            ylabel('frame mean dfof')
            title(sprintf('%s',condList{i}))
            if exist('psfile','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfile,'-append');
            end
            
            figure;colormap jet
            cnt=1;
            for j = 1:2:imagerate*duration %plot every other stimulus time point
                subplot(duration,imagerate/2,cnt)
                imagesc(squeeze(frmdata(:,:,isi*imagerate+j,i,r)),plotrange)
                axis off;axis equal
                cnt=cnt+1;
            end
            mtit(sprintf('%s %s',aniState{r},condList{i}))
            if exist('psfile','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfile,'-append');
            end

            if r==1
                figure(f1)
                subplot(2,round(size(frmdata,4)/2),i)
                plot(timepts,squeeze(nanmean(nanmean(frmdata(x-spr:x+spr,y-spr:y+spr,:,i,r),2),1)),'k')
                xlabel('time (s)');ylabel('sit dfof');title(sprintf('%s',condList{i}));
                axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
            else
                figure(f2)
                subplot(2,round(size(frmdata,4)/2),i)
                plot(timepts,squeeze(nanmean(nanmean(frmdata(x-spr:x+spr,y-spr:y+spr,:,i,r),2),1)),'k')
                xlabel('time (s)');ylabel('run dfof');title(sprintf('%s',condList{i}));
                axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
            end

            %make the movie
            movname = [fileName(1:end-7) aniState{r} '_' condList{i}]
            cycle_mov = squeeze(frmdata(:,:,:,i,r));
%             cycle_mov = imresize(double(cycle_mov),downsample,'method','box');
            baseline = prctile(cycle_mov,1,3);
            cycle_mov = cycle_mov - repmat(baseline,[1 1 size(cycle_mov,3)]);
            lowthresh= prctile(cycle_mov(:),2);
            upperthresh = prctile(cycle_mov(:),98)*1.5;
            cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
            mov = immovie(permute(cycMov,[1 2 4 3]));
            vid = VideoWriter(movname);
            vid.FrameRate=imagerate;
            open(vid);
            writeVideo(vid,mov);
            close(vid)
        end
    end
end
figure(f1)
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure(f2)
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

save(sessionName,'sbxfilename','frmdata','meandfofInterp','moviefname','x','y','-append')

