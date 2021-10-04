% let's not subtract anything, just graphically plot 10 frames
% at full contrast

clear seventhConTrials
     
conOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetFramesMeetBothCriteria);
seventhConTrials = conOrderedByTrialMeetCriteria == uniqueContrasts(7);
 
clear frames
frames = [9 10 11 12 13 14 15 16 17 18];
% frames = [1 3 5 7 9 11];
clear frames4title
frames4title = {'f 9';'f 10';'f 11';'f 12';'f 13';'f 14';'f 15';'f 16';'f 17';'f 18';};

% range = [-0.005 0.02];
range = [0 0.035];

figure
suptitle('peri-stim frames, no baseline subtraction')

clear i
for i = 1:length(frames)
        
     subplot(2,5,i)
    
    %for frame 15
    imagesc(mean(onsetDf(:,:,frames(i),seventhConTrials),4),range); % ,range
    
    st = title(sprintf('%s', frames4title{f}));
    
    axis off;
    axis image;
    
%     clear st
%     st = title(sprintf('%s', frames4title{i}));
%     set(st, 'FontSize', 10);
    
    s = s + 1;

end


% want to split up the no baseline subtracted into multiple duration figs

% con @ each dur
% putting together dur & con so that I can index into the trials in order w/trialCond
conAndDur = [con; dur];
% put it in order of trial presentation:
conAndDurOrderedByTrial = conAndDur(:,trialCond); 
 
clear frames
frames = [9 10 11 12 13 14 15 16 17 18];
% frames = [1 3 5 7 9 11];
clear frames4title
frames4title = {'f 9';'f 10';'f 11';'f 12';'f 13';'f 14';'f 15';'f 16';'f 17';'f 18';};

range = [-0.01 0.085]; % the range spreads out I guess as you seperate the durations out

durFrames2ms = (uniqueDurations/60)*(1000); % go from seconds to ms

for d = 1:length(uniqueDurations)
    
    figure
    titleText = sprintf('peri-stim, no baseline subtraction, duration = %0.00f ms',durFrames2ms(d));
    suptitle(titleText)
    
    for c = 7

        clear seventhCthDthTrials
        seventhCthDthTrials = conAndDurOrderedByTrial(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrial(2,:) == uniqueDurations(d);

        clear f
        for f = 1:length(frames)
        
            subplot(2,5,f)
        
            imagesc(mean(onsetDf(:,:,frames(f),seventhCthDthTrials),4),range); % ,range
            
            st = title(sprintf('%s', frames4title{f}));
            axis off;
            axis image;
    
        end
    
    end

end


% same as 1st plot not split by duration but w/baseline subtraction

baselineFrameSubtracted = 10;

clear seventhConTrials
     
conOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetFramesMeetBothCriteria);
seventhConTrials = conOrderedByTrialMeetCriteria == uniqueContrasts(7);
 
clear frames
frames = [9 10 11 12 13 14 15 16 17 18];

clear frames4title
frames4title = {'f 9';'f 10';'f 11';'f 12';'f 13';'f 14';'f 15';'f 16';'f 17';'f 18';};

range = [-0.01 0.085]; 

clear baselineFrameSubtracted4title;
baselineFrameSubtracted4title = '10';

figure
suptitle('peri-stim frames, w/baseline subtraction')

clear f
for f = 1:length(frames) % for every frame, subtract the baseline frame
        
    subplot(2,5,f)
    
    % subtract baseline frame from every frame
    imagesc(mean(onsetDf(:,:,frames(f),seventhConTrials),4)-mean(onsetDf(:,:,baselineFrameSubtracted,seventhConTrials),4)) 
    
    st = title(sprintf('%s', frames4title{f}));
    
    axis off;
    axis image;
    
%     clear st
%     st = title(sprintf('%s', frames4title{i}));
%     set(st, 'FontSize', 10);
    
    s = s + 1;

end


% want to split up the WITH baseline subtracted into multiple duration figs

baselineFrame = 4;

% con @ each dur
% putting together dur & con so that I can index into the trials in order w/trialCond
conAndDur = [con; dur];
% put it in order of trial presentation:
conAndDurOrderedByTrial = conAndDur(:,trialCond); 
 
clear frames
frames = [1:1:15];

clear frames4title
%frames4title = {'f 9';'f 10';'f 11';'f 12';'f 13';'f 14';'f 15';'f 16';'f 17';'f 18';};

range = [-0.01 0.085]; % the range spreads out I guess as you seperate the durations out

durFrames2ms = (uniqueDurations/60)*(1000); % go from seconds to ms

for d = 1:length(uniqueDurations)
    
    figure
    titleText = sprintf('peri-stim, w/baseline subtraction, duration = %0.00f ms',durFrames2ms(d));
    suptitle(titleText)
    
    for c = 7

        clear seventhCthDthTrials
        seventhCthDthTrials = conAndDurOrderedByTrial(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrial(2,:) == uniqueDurations(d);

        clear f
        for f = 1:length(frames)
        
            subplot(3,5,f)
        
            imagesc(mean(onsetDf(:,:,frames(f),seventhCthDthTrials),4)-mean(onsetDf(:,:,baselineFrame,seventhCthDthTrials),4),range); % ,range
            
            %st = title(sprintf('%s', frames4title{f}));
            axis off;
            axis image;
    
        end
    
    end

end


% let's just plot all 51 frames at full contrast

range = [0 0.035];
clear frames
frames = [1:1:size(onsetDf,3)]; % however many frames collected in onsetDf

figure

% get date for title
[filepath,name,ext] = fileparts('20210411T123140_25.mat');
datePart = name(1:8);
year = datePart(1:4);
month = datePart(5:6);
day = datePart(7:8);
date = sprintf('%s ', month, day, year);

% more title info
subjName = subjData{1,1}.name; % subjNameStr is a char, not string
titleText = ': each frame of onsetsDf no subtraction of baseline frame'; % making char variables for sprintf/title later
supTit = suptitle(sprintf('%s', date, subjName, titleText));
set(supTit, 'FontSize', 14);

clear cfor c = 7; % highest contrast only 

    clear seventhConTrials 
    conOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetFramesMeetBothCriteria);
    seventhConTrials = conOrderedByTrialMeetCriteria == uniqueContrasts(7);
   
    for f = 1:length(frames) 
        
        subplot(3,5,f)
        
        imagesc(mean(onsetDf(:,:,frames(f),seventhConTrials),4),range) % ,range 
        
        axis off;
        axis image;

    end
    
end

% looks like peak activity frame might be frame 13, not 15, and I missed that fact 
% by only plotting every 3 frames

% same as prev but subtract baseline
% let's subtract each of the frames by a certain baseline frame

baselineFrameSubtracted = 4;

range = [0 0.035];
frames = [1:1:size(onsetDf,3)]; 

figure

% get date for title
[filepath,name,ext] = fileparts('20210411T123140_25.mat');
datePart = name(1:8);
year = datePart(1:4);
month = datePart(5:6);
day = datePart(7:8);
date = sprintf('%s ', month, day, year);

clear baselineFrameSubtracted4title;
baselineFrameSubtracted4title = '4';

% more title info
subjName = subjData{1,1}.name; % subjNameStr is a char, not string
titleText = sprintf(': df/f over frames with frame %s subtracted from each frame (averaged over trials)', baselineFrameSubtracted4title);  
% titleText = ': each frame of onsetsDf with frame %s subtracted, baselineFrameSubtracted'; % making char variables for sprintf/title later
supTit = suptitle(sprintf('%s', date, subjName, titleText));
set(supTit, 'FontSize', 14);

clear c

for c = 7; % highest contrast only 

    clear seventhConTrials 
    conOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetFramesMeetBothCriteria);
    seventhConTrials = conOrderedByTrialMeetCriteria == uniqueContrasts(7);
   
    for f = 1:length(frames) 
        
        subplot(3,5,f)
        
        imagesc(mean(onsetDf(:,:,frames(f),seventhConTrials),4)-mean(onsetDf(:,:,baselineFrameSubtracted,seventhConTrials),4),range) % ,range 
        
        axis off;
        axis image;
        
    end
    
end


% want to plot a trace just arounf my onset time (+/-), for one 
% representitive point

% show topox topoy crop
figure
subplot(1,2,1);
imshow(topox_crop);
subplot(1,2,2);
imshow(topoy_crop);
title('topox_crop & topoy crop');


% pick 1 pts - V1
clear Onexpts Oneypts 
for i = 1:1
    i
    [Onexpts(i) Oneypts(i)] = ginput(1);
    for s = 1:2
        subplot(1,2,s)
        hold on
        plot(Onexpts(i),Oneypts(i),'*');
    end
end


% plot that point over the peri-stim time period

 % onset df across frames, averaged over trials
 % should give pix x pix x frames (~50 frames, peri-stim)
clear meanOnsetDfOverTrials
meanOnsetDfOverTrials = mean(onsetDf,4);

% Now I want to subtract d/f at frame 10 (supposedly bwefore stim onset, 
% at low point in previous trace& 
% from the df/f value from every frame at the point I chose...

% round the point
RoundOneXpts = round(abs(Onexpts));
RoundOneYpts = round(abs(Oneypts));

% let's make a vector that's the same as meanOnsetDfOverTrials but for one point only
% Should return a 1 x frames, possibly need squeeze
clear onePixMeanOnsetDf
onePixMeanOnsetDf = squeeze(meanOnsetDfOverTrials(RoundOneYpts,RoundOneXpts,:))'; % switch x & y. All trials one point
    
% then I want to subtract df/f at the 10th frame from each frame. Should be one 
% cell that equals zero at least

% loop: I want to try different baseline frame variables

%baseline4Legend = {'frame 1';'frame 10';'frame 20';'frame 30';'frame 40';'frame 50';};
baseline4Legend = {'frame 1';'frame 9';'frame 10';'frame 11';'frame 12';'frame 16';};

figure % gonna plot each baseline frame value as it's own subplot
suptitle('df/f at one point over time, w/different baseline frame subtracted')
clear subplotNum
subplotNum = 1;

clear b
for b = [1, 9, 10, 11, 12, 16]; % for differnt baseline frames

    % subtract baseline frame
    clear i % i = frames 
    clear dfRel2Baseline

        for i = 1:length(onePixMeanOnsetDf) % for each frame
            % subtract a different frame as baseline
            dfRel2Baseline(i) = onePixMeanOnsetDf(i) - onePixMeanOnsetDf(b);
           
        end

    clear x_axis
    x_axis = [1:length(dfRel2Baseline)];
    %x_axis = [1:length(onePixMeanOnsetDf)];

    clear myplot
    myplot = plot(x_axis,dfRel2Baseline, 'linewidth',1);
    %myplot = plot(x_axis,onePixMeanOnsetDf, 'linewidth',1);

    % Change the format of the tick labels and remove the scientific notation
    ax = ancestor(myplot, 'axes');
    r = ax.YAxis;
    r.TickLabelFormat = '%g';
    r.Exponent = 0;
    
    ylim([-0.005, 0.014])
    xlim([0, length(dfRel2Baseline)])
    %xlim([0, length(onePixMeanOnsetDf)])
    
    hold on 
   
end
legend(baseline4Legend)

hold on
plot(x_axis,onePixMeanOnsetDf, 'linewidth',2)

