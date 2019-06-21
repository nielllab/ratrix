close all
clear all

% load('G62AAA4TT_subj.mat')
% load('20171027T133757_48.mat')  %%% frames 1:116 are noise

load('G62WW3RT_subj.mat')
load('20171027T152824_79.mat')  %%% frames 1:116 are noise

%load('20171102T171734_85.mat');

[f p] = uigetfile('*.mat','topox maps file')
load(fullfile(p,f),'mapNorm');
topox = polarMap(mapNorm{3});
figure
imshow(topox)

[f p] = uigetfile('*.mat','topoy maps file')
load(fullfile(p,f),'mapNorm','map');
topoy = polarMap(mapNorm{3});
figure
imshow(topoy)


[f p] = uigetfile('*.mat','maps file');

downsize = 0.25;
load(fullfile(p,f));
df = imresize(dfof_bg,downsize);
topox = imresize(topox,downsize);
topoy = imresize(topoy,downsize);


mn = mean(mean(abs(df),2),1);
figure
plot(squeeze(mn)); title('mean abs dfof'); xlabel('frame')
%%% stimDetails = information for each condition
%%% allStop.frameT = time (in absolute value) of each frame, beginning  at start of stopping period
%%% allResp.frameT = time (in absolute value) of each frame, beginning  at start of stopping period

t0 = allStop(1).frameT(1);  %%% starting gun

for i = 1:length(allResp);
    onsets(i) = allResp(i).frameT(1)-t0;
end

goodStart=150;
%df(:,:,1:116)=0; %%% frames 1:116 of 102717 AAA4TT are noise
df(:,:,1:goodStart)=0; %% frames 1:150 of 110217WW3RT are noise


stdMap = std(df(:,:,1:10:end),[],3);
figure;colormap jet
imagesc(stdMap,[0 0.1])
[x y] = ginput(2);
df = df(y(1):y(2),x(1):x(2),:);
topox_crop = topox(y(1):y(2),x(1):x(2),:);
topoy_crop = topoy(y(1):y(2),x(1):x(2),:);

stdMap = std(df(:,:,1:10:end),[],3);
figure
imagesc(stdMap,[0 0.1])


frameT = frameT-frameT(1);  %%% time of camera frames;
figure
plot(diff(frameT))

clear onsetDf
for i = 1:length(onsets);
    onsetFrame(i) = find(diff(frameT>onsets(i)));
    onsetDf(:,:,:,i) = df(:,:,onsetFrame(i)-10:onsetFrame(i)+40);
end

badtrials = onsetFrame<=goodStart;
sum(badtrials)

figure
for f = 1:12;
    subplot(3,4,f)
    imagesc(mean(onsetDf(:,:,f*3,:),4)-mean(onsetDf(:,:,11,:),4) ,[-0.01 0.05])
    axis equal
end

for i=1:length(stimDetails);
    tc(i) = stimDetails(i).targContrast;
    fc(i) = stimDetails(i).flankContrast;
end

tcTrial = tc(trialCond);
fcTrial = fc(trialCond);


tcTrial(badtrials)=NaN;
fcTrial(badtrials)=NaN;

range = [0 0.1];

figure
subplot(1,2,1);
imshow(topox_crop);
subplot(1,2,2);
imshow(topoy_crop);

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


%%% target contrasts
contrasts = unique(tc);
for c = 1:length(contrasts);
    figure
     trials =  abs(tcTrial)==contrasts(c);
    set(gcf,'Name',sprintf('tc = %0.3f  n = %d',contrasts(c),sum(trials)));
    for f = 1:12;
        subplot(3,4,f)
        imagesc(mean(onsetDf(:,:,f*3,trials),4)-mean(onsetDf(:,:,11,trials),4) ,range);
        hold on; plot(xpts,ypts,'r.')
        axis equal; axis off
    end
end

%%% flanker contrasts
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

figure
subplot(1,2,1);
imshow(topox_crop); hold on; plot(xpts,ypts,'wo')
subplot(1,2,2);
imshow(topoy_crop);hold on; plot(xpts,ypts,'wo')
