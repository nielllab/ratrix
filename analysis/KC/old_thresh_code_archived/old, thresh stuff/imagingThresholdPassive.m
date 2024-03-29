addpath F:\Kristen\Widefield2\balldata_G6H277RT
% addpath F:\Kristen\Widefield2\balldatathe_EE1LT
% addpath F:\Kristen\Widefield2\balldata_EE81LT

close all
clear all


load('277RT_subj.mat')
% load('EE81LT_subj.mat')

load('20210311T161951_5.mat')
% load('20210107T155415_1.mat') %277rt 010721
% load('20210204T131006_5.mat') %277rt 020421 % doBehavior generates one of these files per session
% load('20210107T140819_6.mat') % EE81LT 010721 (file acccidentally named 010621)
% load('20210204T164434_3.mat') % EE1LT 020421

[f p] = uigetfile('*.mat','topox maps file')
load(fullfile(p,f),'mapNorm');
topox = polarMap(mapNorm{3}); % polar map = projecting features from plane to sphere
f1 = figure
imshow(topox)
title('topox polar map of normalized WF signal')

% savefig('EE8LT_020421_topoX_retinotopy_imThreshPass') % hard coding

[f p] = uigetfile('*.mat','topoy maps file')
load(fullfile(p,f),'mapNorm','map');
topoy = polarMap(mapNorm{3});
f2 = figure
imshow(topoy)
title('topoy polar map of normalized WF signal')

% savefig('EE8LT_020421_topoY_retinotopy_imThreshPass')


[f p] = uigetfile('*.mat','maps file');

downsize = 0.25; % why resize by this factor?
load(fullfile(p,f));
df = imresize(dfof_bg,downsize);
topox = imresize(topox,downsize);
topoy = imresize(topoy,downsize);


mn = mean(mean(abs(df),2),1); % taking the average of the entire imaging field over time
figure
plot(squeeze(mn)); title('mean abs dfof across entire image vs frames'); 
ylabel('mean abs dfof of entire image') 
xlabel('frame') 
xlim([0 size(squeeze(mn),1)])  

% savefig('EE8LT_020421_meanWholeImageVsFrames_imThreshPass')

%%% stimDetails = information for each condition
%%% allStop.frameT = time (in absolute value) of each frame, beginning  at start of stopping period
%%% allResp.frameT = time (in absolute value) of each frame, beginning  at start of stopping period

%%% ^ same info in both these above, so why not use just one? Answer:
%%% allStop relates to the imaging frames whereas allResp relates to,
%%% whereas allResp relates to stimulus frames (expand...)

t0 = allStop(1).frameT(1);  %%% starting gun - t0 is the first frame the stim comes on (rows in allStop = trials)
% I think allStop % allResp is in order of stims presented

for i = 1:length(allResp); 
    onsets(i) = allResp(i).frameT(1)-t0; % onset = time of first frame for each stimulus presentation minus of time of first frame (stim onset relative to first frame when mouse stops/stim comes on)
end % now have onset times for eact stim, in frames

stdMap = std(df(:,:,1:10:end),[],3); % only take every 10 frames (don't need all, why?). taking std across 3rd dimension, time
figure;
colormap jet
imagesc(stdMap,[0 0.1])
title('stDev of dfof_bg across time(downsized)')

% savefig('EE8LT_020421_stDev_of_Dfof_overtime_imThreshPass')


[x y] = ginput(2);
df = df(y(1):y(2),x(1):x(2),:); % cropping df to be area I select 
topox_crop = topox(y(1):y(2),x(1):x(2),:);
topoy_crop = topoy(y(1):y(2),x(1):x(2),:);

stdMap = std(df(:,:,1:10:end),[],3); % gonna show image of std of croppoed df over time
figure
colormap jet
imagesc(stdMap,[0 0.1])
title('Cropped stDev of dfof_bg across time(downsized)') % axes are pixels?

% savefig('EE8LT_020421_CROP_stDev_of_Dfof_overtime_imThreshPass')

frameT = frameT-frameT(1);  %%% time of camera frames;
figure
plot(diff(frameT)) % plotting the difference between each successive value in frameT
title('difference in time of camera frames from each other')

% savefig('EE8LT_020421_camFrameDiffTime_imThreshPass')

clear onsetDf
clear onsetFrame
clear i
    % for EE81LT on 010621, we have to leave out the last trial because
    % there are not 40 frames after it (df is shorter than last frame
    % number in onsets + 40 
for i = 1:length(onsets)-1; % for each onset time of each response
    onsetFrame(i) = find(diff(frameT>onsets(i))); %now we're getting the matching imaging frame for that stim onset time... the innermost part is saying find indicies for all frames that are after the onset of stim
    
    onsetDf(:,:,:,i) = df(:,:,onsetFrame(i)-10:onsetFrame(i)+40);
    
    % now we're storing each chunk (10 frames behind onset and 40 frames ahead - this captures the whole stim evoked response
    % so, onset Df is yet another subsection of dfof_bg, just aorund onset frame time only
    % note: trials ~10 sec... 50 frames at 10 hz is only 5 sec - why? b/c
    % trial includes 5 sec prior to stim onset? How long is stim on screen?
end


figure
suptitle('avg dfof across all trials, all, conditions, over time')
for f = 1:12; % why 12 - 12 times points just good number for display
    subplot(3,4,f) % each plot is a further point in time
    % Mult time dimesion by 3 times f because we don't want to plot all the
    % frames - notice that we're taking the mean across 4th dimension, so
    % we're taking every 3rd frame averaged across *all* stimulus presnetiations 
    % 11 is because we took 10 frames before stim onset and here we're subtracting onset of stim from baseline
    % baseline is the average activity at each time point across this 5 sec interval that
    % includes pre & post stim onset. the mean activity right after stim
    % onset is subtracted from that baseline
    % wait think I got it - subtracting start of stim from all other time points.. 
    % switches from neg to pos when stim comes on so the baseline is stim onset? 
    % (kinda confused here... we're subtracting the same onset stim point from every 3rd frame... why?
    imagesc(mean(onsetDf(:,:,f*3,:),4)-mean(onsetDf(:,:,11,:),4) ,[-0.01 0.05]) 
    axis equal
    xlabel('pix?') 
    ylabel('pix?') 
end
% savefig('EE8LT_020421_meanDfof_allTrialsCondsOverTime_imThreshPass')

for i=1:length(stimDetails); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    tc(i) = stimDetails(i).targContrast; % making vector with list of targ contrast for each condition
    fc(i) = stimDetails(i).flankContrast;
end

tcTrial = tc(trialCond); % use trial cond to index into correct target contrast value for that condition
fcTrial = fc(trialCond);

range = [0 0.1]; % how range picked?

% show topox topoy crop
figure
subplot(1,2,1);
imshow(topox_crop);
subplot(1,2,2);
imshow(topoy_crop);
title('topox_crop & topoy crop');

% pick 5 pts - V1, motor ctx, 3 HVAs
clear xpts ypts 
for i = 1:5
    i
    [xpts(i) ypts(i)] = ginput(1);
    for s = 1:2
        subplot(1,2,s)
        hold on
        plot(xpts(i),ypts(i),'*');
    end
end

% plotting by target contrast 
contrasts = unique(tc); % go thru list of contrasts and take each value only once, make this a new vector
for c = 1:length(contrasts); % for each unique contrast
    figure
    suptitle('dfof every 3rd frame, peri-stim, by target contrast')
    trials =  abs(tcTrial)==contrasts(c); % confused... c-th unique contrast... make abs value of trial target condition equal contrast? then to  'c' contrast, then assign that to trials?
    % EE81LT needs trials-1 on 010621
    trialsMinusOne = trials(1,1:length(trials)-1); 
     set(gcf,'Name',sprintf('tc = %0.3f  n = %d',contrasts(c),sum(trials)));
    for f = 1:12;
        subplot(3,4,f) 
        imagesc(mean(onsetDf(:,:,f*3,trialsMinusOne),4)-mean(onsetDf(:,:,11,trialsMinusOne),4) ,range); 
        hold on; plot(xpts,ypts,'r.')
        axis equal; axis off;
    end
end

%%% plotting by flanker contrasts - all flanker contrasts are zero so I
%%% think this plot should be the same as the earlier one that's across all
contrasts = unique(abs(fc));
for c = 1:length(contrasts);
    figure
    suptitle('dfof every 3rd frame, peri-stim, by flanker contrast')
    trials =  abs(fcTrial)==contrasts(c);
    % EE81LT needs trials-1 on 010621
    trialsMinusOne = trials(1,1:length(trials)-1);
    set(gcf,'Name',sprintf('fc = %0.3f  n = %d',contrasts(c),sum(trials)));
    for f = 1:12;
        subplot(3,4,f)
        imagesc(mean(onsetDf(:,:,f*3,trialsMinusOne),4)-mean(onsetDf(:,:,11,trialsMinusOne),4) ,range)
        axis equal; axis off
    end
end

%%% full parameters = flanker and target

contrasts = unique(abs(fc));
tcontrasts = unique(tc);
for c = 1:length(contrasts);
    for c2= 1:length(tcontrasts)
% for c = [1 3];
%     for c2 = [1 3];
        trials = abs(fcTrial)==contrasts(c) & tcTrial ==tcontrasts(c2);
        % EE81LT needs trials-1 on 010621
        
        MinusOne = trials(1,1:length(trials)-1);
        figure
        suptitle(sprintf('dfof over time both targ & flank, targC = %d', c2))
        set(gcf,'Name',sprintf('fc = %0.3f tc = %0.3f n = %d',contrasts(c),tcontrasts(c2),sum(trials)));
        for f = 1:12;
            subplot(3,4,f)
            % why median below instead of mean?
            imagesc(median(onsetDf(:,:,f*3,trialsMinusOne),4)-mean(onsetDf(:,:,11,trialsMinusOne),4) ,range) % what does range mean here
            axis equal; axis off
            hold on; 
            plot(xpts,ypts,'r.'); 
            colormap jet
        end
        % savefig(sprintf('EE8LT_020421_%d_imThreshPass',c2))
    end
end

%? 
figure
suptitle('picked points')

subplot(1,2,1);
imshow(topox_crop); 
hold on; 
plot(xpts,ypts,'wo')

subplot(1,2,2);
imshow(topoy_crop);
hold on; 
plot(xpts,ypts,'wo')

% savefig('EE8LT_020421_picked_points')
