close all
clear all

% load('G6H277RT_subj.mat')
% load('20210107T133757_48.mat')  %%% frames 1:116 are noise

load('G6H277RT_subj.mat')
load('20210107T155415_1.mat')  %%% frames 1:116 are noise

%load('20171102T171734_85.mat');

[f p] = uigetfile('*.mat','topox maps file')
load(fullfile(p,f),'mapNorm');
topox = polarMap(mapNorm{3}); % polar map = projecting features from plane to sphere
f1 = figure
imshow(topox)
title('topox polar map of normalized WF signal')

[f p] = uigetfile('*.mat','topoy maps file')
load(fullfile(p,f),'mapNorm','map');
topoy = polarMap(mapNorm{3});
f2 = figure
imshow(topoy)
title('topoy polar map of normalized WF signal')


[f p] = uigetfile('*.mat','maps file');

downsize = 0.25; % why resize by this factor?
load(fullfile(p,f));
df = imresize(dfof_bg,downsize);
topox = imresize(topox,downsize);
topoy = imresize(topoy,downsize);


mn = mean(mean(abs(df),2),1); % why take the first mean across rows? I thought each cell in df was a pixel? Now taking the second mean leaves us only with one pixel over 3000 frames...
figure
plot(squeeze(mn)); title('mean abs dfof vs frames - 1 pix?'); xlabel('frame') % is this mean abs dfof for 1 pixel?

%%% stimDetails = information for each condition
%%% allStop.frameT = time (in absolute value) of each frame, beginning  at start of stopping period
%%% allResp.frameT = time (in absolute value) of each frame, beginning  at start of stopping period

%%% ^ same info in both these above, so why not use just one? 

t0 = allStop(1).frameT(1);  %%% starting gun - t0 is the first time point (what are the rows, considering there's only 286 of them?)

for i = 1:length(allResp); % allResp also has 286 rows... not frames, right?
    onsets(i) = allResp(i).frameT(1)-t0; % what are rows in allResp? onset = time of first frame for each response minus time of first frame first stop? 
end

goodStart=150; % cutting out the first few frams, forget why
df(:,:,1:goodStart)=0; %% frames 1:150 of 110217WW3RT are noise


stdMap = std(df(:,:,1:10:end),[],3); % only take every 10 frames (don't need all, why?). taking std across 3rd dimension, time
figure;colormap jet
imagesc(stdMap,[0 0.1])
title('stDev of dfof_bg across time(downsized & trimmed first 150 frames)')


[x y] = ginput(2);
df = df(y(1):y(2),x(1):x(2),:); % cropping df to be area I select - anyway to get retino map over this?
topox_crop = topox(y(1):y(2),x(1):x(2),:);
topoy_crop = topoy(y(1):y(2),x(1):x(2),:);

stdMap = std(df(:,:,1:10:end),[],3); % gonna show image of std of croppoed df over time
figure
imagesc(stdMap,[0 0.1])
title('Cropped stDev of dfof_bg across time(downsized & trimmed first 150 frames)') % axes are pixels?


frameT = frameT-frameT(1);  %%% time of camera frames;
figure
plot(diff(frameT)) % plotting the difference between each successive value in frameT
title('difference in time of camera frames from each other')

clear onsetDf
for i = 1:length(onsets); % for each onset time of each reasponse
    onsetFrame(i) = find(diff(frameT>onsets(i))); %confused.. I think this gets you the onset of the frame rather than onset of the response?
    onsetDf(:,:,:,i) = df(:,:,onsetFrame(i)-10:onsetFrame(i)+40); % this gets the df values for onset frame and 10 frames behind and 40 ahead (why these particular numbers again? 
    % where does the extra dimension in onsetDf come in?
    % so, onset Df is yet another subsection of dfof_bg? just aorund onset
    % frame only?
end

badtrials = onsetFrame<=goodStart;
sum(badtrials)

figure
for f = 1:12; % why 12?
    subplot(3,4,f) % is each subplot a point in time?
    % Qs4below: why mult time dimesion by 3 times f? 11 is because the
    % first frame after the 10 before frame starts... something like
    % that... mean across 4th dimension means across all onsets?
    imagesc(mean(onsetDf(:,:,f*3,:),4)-mean(onsetDf(:,:,11,:),4) ,[-0.01 0.05])
    % so we're subtracing frame 11 from frame 3*f... I guess we're showing
    % an image of the difference in means at two time points 
    axis equal
    title('what are axes? subplots are time?') %Q
end


for i=1:length(stimDetails); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc)
    tc(i) = stimDetails(i).targContrast; % making vector with list of targ contrast for each condition
    fc(i) = stimDetails(i).flankContrast;
end

tcTrial = tc(trialCond); % use trial cond to index into correct target contrast value for that condition
fcTrial = fc(trialCond);


tcTrial(badtrials)=NaN;
fcTrial(badtrials)=NaN;

range = [0 0.1];

% show topox topoy crop
figure
subplot(1,2,1);
imshow(topox_crop);
subplot(1,2,2);
imshow(topoy_crop);
title('topox_crop & topoy crop');

% pick 5 pts - where? why 5?
clear xpts ypts % why clear these?
for i = 1:5
    i
    [xpts(i) ypts(i)] = ginput(1);
    for s = 1:2
        subplot(1,2,s)
        hold on
        plot(xpts(i),ypts(i),'*');
    end
end

%%% target contrasts - do the points I picked get analyzed?
% what's being plotted here in plain english? what's the subtraction?
% is each sublot a tifferent interval in time?

contrasts = unique(tc); % go thru list of contrasts and take each value only once, make this a new vector
for c = 1:length(contrasts); % for each unique contrast
    figure
     trials =  abs(tcTrial)==contrasts(c); % confused... c-th unique contrast... make abs value of trial target condition equal  contrast? then to  'c' contrast, then assign that to trials?
    set(gcf,'Name',sprintf('tc = %0.3f  n = %d',contrasts(c),sum(trials)));
    for f = 1:12;
        subplot(3,4,f) % why f times 3?
        imagesc(mean(onsetDf(:,:,f*3,trials),4)-mean(onsetDf(:,:,11,trials),4) ,range); % again plotting this subtraction
        hold on; plot(xpts,ypts,'r.')
        axis equal; axis off
        title('?');
    end
end

%%% flanker contrasts - what's being plotted here? what contrast are targets here?
contrasts = unique(abs(fc));
for c = 1:length(contrasts);
    figure
    trials =  abs(fcTrial)==contrasts(c);
    set(gcf,'Name',sprintf('fc = %0.3f  n = %d',contrasts(c),sum(trials)));
    for f = 1:12;
        subplot(3,4,f)
        imagesc(mean(onsetDf(:,:,f*3,trials),4)-mean(onsetDf(:,:,11,trials),4) ,range)
        axis equal; axis off
    end
end

%%% full parameters = flanker and target

% do I need these flanker parts?
contrasts = unique(abs(fc));
tcontrasts = unique(tc);
for c = 1:length(contrasts);
    for c2= 1:length(tcontrasts)
% for c = [1 3];
%     for c2 = [1 3];
        trials = abs(fcTrial)==contrasts(c) & tcTrial ==tcontrasts(c2);
        figure
        set(gcf,'Name',sprintf('fc = %0.3f tc = %0.3f n = %d',contrasts(c),tcontrasts(c2),sum(trials)));
        for f = 1:12;
            subplot(3,4,f)
            imagesc(median(onsetDf(:,:,f*3,trials),4)-mean(onsetDf(:,:,11,trials),4) ,range)
            axis equal; axis off
                   hold on; plot(xpts,ypts,'r.'); colormap jet
        end
    end
end

%? 
figure
subplot(1,2,1);
imshow(topox_crop); hold on; plot(xpts,ypts,'wo')
subplot(1,2,2);
imshow(topoy_crop);hold on; plot(xpts,ypts,'wo')

