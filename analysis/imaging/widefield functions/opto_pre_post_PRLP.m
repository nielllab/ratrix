%% opto_pre_post_PRLP.m
%use topox to manually stimulate opto every other trial
%this code splits data into baseline trials and opto trials

[f,p] = uigetfile('*.mat','MAPS file for opto expt');

load(fullfile(p,f),'dfof_bg');

baseline = zeros(size(dfof_bg,1),size(dfof_bg,2),size(dfof_bg,3)/2);
opto = baseline;

cycle_length = 10; %seconds
frame_rate = 10; %Hz
fpc = cycle_length*frame_rate; %frames per cycle
num_cycles = size(dfof_bg,3)/fpc; %total number of stimulus cycles

cnt = 1;
for i = 1:2:num_cycles %size of third dimension (total frames)
    baseline(:,:,cnt:cnt+99) = dfof_bg(:,:,1+(fpc*(i-1)):100+(fpc*(i-1)));
    opto(:,:,cnt:cnt+99) = dfof_bg(:,:,1+(fpc*i):100+(fpc*i));
    cnt=cnt+fpc;
end

for i = 1:fpc
    baseline_mov(:,:,i) = mean(baseline(:,:,i:fpc:end),3);
    opto_mov(:,:,i) = mean(opto(:,:,i:fpc:end),3);
end

pltrange = [-0.01 0.01];

figure; colormap jet
imagesc(mean(baseline_mov,3),pltrange)
title('baseline')
axis off
colorbar

figure; colormap jet
imagesc(mean(opto_mov,3),pltrange)
title('opto')
axis off
colorbar

figure; colormap jet
imagesc(mean(opto_mov,3)-mean(baseline_mov,3),pltrange)
title('baseline-opto')
axis off
colorbar

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

% figure;colormap jet
% for i=1:size(opto_mov,3)
%     imagesc(opto_mov(:,:,i),pltrange)
%     drawnow
% end