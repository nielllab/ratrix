%% opto_pre_post_PRLP.m

%%%use topox to manually stimulate opto every other trial
%%%this code splits data into baseline trials and opto trials

%%%set up PDF to save figures
psfilename = 'D:\tempWF.ps'; 
if exist(psfilename,'file')==2;delete(psfilename);end

%% loading the data
%%% open the maps file containing the data
[f,p] = uigetfile('*.mat','MAPS file for opto expt');
%%%load the dfof data
load(fullfile(p,f),'dfof_bg');

%%%create empty arrays to split data in to 'baseline' and 'opto' trials
baseline = zeros(size(dfof_bg,1),size(dfof_bg,2),size(dfof_bg,3)/2);
opto = baseline;

%% splitting the data into baseline/opto periods

%%%define the parameters of the imaging
cycle_length = 10; %seconds
frame_rate = 10; %Hz
fpc = cycle_length*frame_rate; %frames per cycle
num_cycles = size(dfof_bg,3)/fpc; %total number of stimulus cycles

%%%loop through and load the dfof data into the empty arrays
cnt = 1;
for i = 1:2:num_cycles %size of third dimension (total frames)
    baseline(:,:,cnt:cnt+99) = dfof_bg(:,:,1+(fpc*(i-1)):100+(fpc*(i-1)));
    opto(:,:,cnt:cnt+99) = dfof_bg(:,:,1+(fpc*i):100+(fpc*i));
    cnt=cnt+fpc;
end

%%%loop through and make cycle averages for baseline and opto
for i = 1:fpc
    baseline_mov(:,:,i) = mean(baseline(:,:,i:fpc:end),3);
    opto_mov(:,:,i) = mean(opto(:,:,i:fpc:end),3);
end

%% plotting

%%%set a range for imagesc
pltrange = [-0.01 0.01];

%%%plot the baseline average
figure; colormap jet
imagesc(mean(baseline_mov,3),pltrange)
title('baseline')
axis off
colorbar
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

%%%plot the opto average
figure; colormap jet
imagesc(mean(opto_mov,3),pltrange)
title('opto')
axis off
colorbar
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

%%%plot the baseline minus the opto
figure; colormap jet
imagesc(mean(opto_mov,3)-mean(baseline_mov,3),pltrange)
title('baseline-opto')
axis off
colorbar
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

%%%plot the cycle averages for the two to compare
figure;colormap jet
for i = 1:frame_rate
    subplot(2,frame_rate,i)
    imagesc(mean(baseline_mov(:,:,i:frame_rate:end),3),pltrange)
    axis image
    axis off
    subplot(2,frame_rate,i+frame_rate)
    imagesc(mean(opto_mov(:,:,i:frame_rate:end),3),pltrange)
    axis image
    axis off
end
colorbar
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

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