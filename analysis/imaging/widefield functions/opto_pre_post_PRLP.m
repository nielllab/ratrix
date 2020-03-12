%% opto_pre_post_PRLP.m
clear all
%%%use topox to manually stimulate opto every other trial
%%%this code splits data into baseline trials and opto trials

%%%set up PDF to save figures
psfilename = 'D:\tempWF.ps'; 
if exist(psfilename,'file')==2;delete(psfilename);end

%% loading the data
%%% open the maps file containing the data
[f,p] = uigetfile('*.mat','MAPS file for opto expt');
%%%load the dfof data

display('loading data')
tic
load(fullfile(p,f),'dfof_bg','sp');
toc

downsamp = 0.5;
dfof_bg = imresize(dfof_bg,downsamp); %%% downsample to make things more manageable

%%%create empty arrays to split data in to 'baseline' and 'opto' trials
baseline = zeros(size(dfof_bg,1),size(dfof_bg,2),size(dfof_bg,3)/2);
opto = baseline;

%% splitting the data into baseline/opto periods

%%%define the parameters of the imaging
cycle_length = 10; %seconds
frame_rate = 10; %Hz
fpc = cycle_length*frame_rate; %frames per cycle
num_cycles = size(dfof_bg,3)/fpc; %total number of stimulus cycles
nreps = floor(num_cycles/2);  %%% number of reps (i.e. control/stim pairs);

%%%loop through and load the dfof data into the empty arrays
cnt = 1;
for i = 1:2:num_cycles %go through and put odd 
    baseline(:,:,cnt:cnt+fpc-1) = dfof_bg(:,:,1+(fpc*(i-1)):fpc+(fpc*(i-1)));
    opto(:,:,cnt:cnt+fpc-1) = dfof_bg(:,:,1+(fpc*i):fpc+(fpc*i));
    cnt=cnt+fpc;
end

%%% instead, organize resp(x,y,t,rep,cond)

resp = zeros(size(dfof_bg,1),size(dfof_bg,2),fpc,nreps,2);
for i = 1:num_cycles
    rep = ceil(i/2);
    cond = mod(i-1,2)+1;
    resp(:,:,:,rep,cond) = dfof_bg(:,:,(i-1)*fpc + (1:fpc));
end


%%%loop through and make cycle averages for baseline and opto
for i = 1:fpc
    baseline_mov(:,:,i) = mean(baseline(:,:,i:fpc:end),3);
    opto_mov(:,:,i) = mean(opto(:,:,i:fpc:end),3);
end

cycAvg = squeeze(mean(resp,4)); %%% average over reps
trialAvg = squeeze(mean(resp,3));  %%% average over time (to give mean for each rep)

%% plotting

%%%set a range for imagesc
pltrange = [-0.02 0.02];

% %%%plot the baseline average
% figure; colormap jet
% imagesc(mean(baseline_mov,3),pltrange)
% title('baseline')
% axis off
% colorbar
% if exist('psfilename','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfilename,'-append');
% end
% 
% %%%plot the opto average
% figure; colormap jet
% imagesc(mean(opto_mov,3),pltrange)
% title('opto')
% axis off
% colorbar
% if exist('psfilename','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfilename,'-append');
% end
% 
% %%%plot the baseline minus the opto
% figure; colormap jet
% imagesc(mean(opto_mov,3)-mean(baseline_mov,3),pltrange)
% title('baseline-opto')
% axis off
% colorbar
% if exist('psfilename','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfilename,'-append');
% end

%%% plot 4 conditions (control, stim, difference, mean)
titles = {'control','stim','stim minus control','avg stim + control'};
figure
for cond = 1:4
    if cond==1 | cond ==2
        meanImg(:,:,cond) = median(cycAvg(:,:,:,cond),3);
    elseif cond ==3
        meanImg(:,:,cond) = meanImg(:,:,2) - meanImg(:,:,1);
    else
        meanImg(:,:,cond) = 0.5*(meanImg(:,:,2) + meanImg(:,:,1));
    end
    subplot(2,2,cond)
    imagesc(meanImg(:,:,cond),pltrange); axis equal
    colormap jet; axis off; colorbar;
    title(titles{cond});
end
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end


%%% compute condensed cycle averages 
%%% i.e. binning, so rather than 100 frames per cycle, have eg 2, 4, or 10;

nf = 4 %%% number of mean frames to span a cycle
nperf = fpc/nf;
downsampTrialMean = zeros(size(cycAvg,1),size(cycAvg,2),nf,2);
for i = 1:nf
    range = round((i-1)*nperf) + (1:round(nperf));
    downsampTrialMean(:,:,i,:) = mean(cycAvg(:,:,range,:),3);
end

%%% plot cycle averages
figure
conds = {'control','stim'};
pltrange = [-0.025 0.025];
for i = 1:nf
    for cond = 1:2
        subplot(2,nf,(cond-1)*nf + i);
        imagesc(downsampTrialMean(:,:,i,cond),pltrange); colormap jet;
        axis equal; axis off ; title(sprintf('%s epoch %d',conds{cond},i));   
    end
end
colorbar %%% only on last one
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end


%%% plot trial averages
conds = {'control','stim'};
pltrange = [-0.2 0.2];
for cond = 1:2
    figure
    for trial = 1:nreps
        subplot(3,5,trial);
        imagesc(trialAvg(:,:,trial,cond),pltrange); colormap jet
        axis equal; axis off ; title(sprintf('%s rep %d',conds{cond},trial));   
    end
    if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end
end


%%% select points to plot
meanfig = figure; 
imagesc(meanImg(:,:,3));
title('select 6 points')
hold on
col = 'rgbcmy';
range = -5:5;
for i = 1:6
    figure(meanfig)
    [x(i) y(i)] = ginput(1); x = round(x); y= round(y);
    plot(x(i),y(i),[col(i) '*'],'LineWidth',2);
    pointResp(i,:,:,:) = mean(mean(resp(y(i) + range, x(i)+range,:,:,:),2),1);
end
legend('1','2','3','4','5','6')
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end

%%% plot all values at these points
for cond = 1:2
    figure
    for i = 1:6
        subplot(2,3,i)
        plot(1:100,squeeze(pointResp(i,:,:,cond)));
        hold on
        plot(1:100,mean(squeeze(pointResp(i,:,:,cond)),2),'g','LineWidth',2)
        ylim([-0.2 0.2]); title(sprintf('%s site %d',conds{cond},i));
    end
end
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end


%%% plot control and stim for these points
figure
for i = 1:6
    subplot(2,3,i);
    plot(1:100,mean(squeeze(pointResp(i,:,:,1)),2),'k','LineWidth',1); hold on
    plot(1:100,mean(squeeze(pointResp(i,:,:,2)),2),'r','LineWidth',1)
    ylim([-0.1 0.1]);
end
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end

    

%%% plot running speed
figure
plot(sp);
xlabel('frame'); ylabel('running speed');
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end


% 
% %%%plot the cycle averages for the two to compare
% figure;colormap jet
% for i = 1:frame_rate
%     subplot(2,frame_rate,i)
%     imagesc(mean(baseline_mov(:,:,i:frame_rate:end),3),pltrange)
%     axis image
%     axis off
%     subplot(2,frame_rate,i+frame_rate)
%     imagesc(mean(opto_mov(:,:,i:frame_rate:end),3),pltrange)
%     axis image
%     axis off
% end
% colorbar
if exist('psfilename','var'),    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');    print('-dpsc',psfilename,'-append'); end

%% save PDF
try
    dos(['ps2pdf ' psfilename ' "' fullfile(p,f(1:end-4)) 'OPTOanalysis.pdf' '"'])
catch
    display('couldnt generate pdf');
end

delete(psfilename);

%% optional: watch it happen in real time
% figure;colormap jet
% for i=1:size(opto_mov,3)
%     imagesc(opto_mov(:,:,i),pltrange)
%     drawnow
% end