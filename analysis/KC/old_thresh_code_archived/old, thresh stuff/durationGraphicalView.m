%% DURATION Calc's
% this part needed for any loops involving looping over DURATION:

% need to make vectors with duration values
for i=1:length(stimDetails); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
    % note: stim details contains info (incl. contrast values) for every 
    % possible condition. It is NOT ordered by trial.
    dur(i) = stimDetails(i).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
end

% note: trial cond is a list of indicies for rown in stimdetails - with this you can index what stim conditions (duration, contrast etc) were displayed each trial
% These indicies *are* ordered by trial
% so now, by using trialCond to index into d, we can get a list of stimulus in the order that they were presented:

durOrderedByTrial = dur(trialCond); % save in new vector that is a list 
% of trial conditions ordered by trial

% from imagingThresholdPassive: 
% trials = abs(fcTrial)==contrasts(c) & tcTrial ==tcontrasts(c2);
% ^ this is done inside for loops
% fcTrial is the list of trials at the order presented

% gets a list of the duration value options, so we know how many durations to loop over
uniqueDurations = unique(dur); 

% use this instead of uniqueDurations if you want to subtract some
% durations:
% % subtractLast3UniqueDurations = uniqueDurations(:,1:length(uniqueDurations)-3);

%% Setting variables for figures
% change animal ID each time:
% load('F:\Kristen\Widefield2\balldata_G6H277RT\G6H277RT_subj.mat')
load('F:\Kristen\Widefield2\040421_EE81LT_RIG2\balldata_EE81LT\EE81LT_subj.mat')
subjName = subjData{1,1}.name % subjNameStr is a char, not string
titleText = ' : Cortical Activation at Each Duration Over Time' % making char variables for sprintf/title later

reigons = {'V1','HVA1','HVA2','HVA3','HVA4'}
r = 1 % since I know the number of reigions is equal to the number of xpts, i'll just index regions
% w/in the xpts loop and add 1 to the index each time. the 'r' index should be equal to i at the end
% ALL TRIALS - ONE FIG, SUBPLOTS = POINTS, ALL TRACES/trials, df/f vs frames

subplotNum = 1

range = [0 0.1];

frames = [12 15 18 21];
s = 1 ;%


%% Duration (rows) vs frames (columns)
figure % make one figure for all subplots
%t = suptitle(sprintf('%s', subjName, titleText))
%set(t, 'FontSize', 12)
suptitle('peri-stimulus cortical response to varying durations')
for d = 1:length(uniqueDurations); % for each unique duration
% for d = 1:length(subtractLast3UniqueDurations);
% for c = 1:length(contrasts);    

%    trials =  abs(tcTrial)==contrasts(c);
%    trialsMinusOne = trials(1,1:length(trials)-1); 

     clear dthTrials
     dthDurOrderedByTrialMeetCriteria = durOrderedByTrial(idxOnsetsMeetBothCriteria); % this index variable is saved as output on imThreshPass
     dthTrials = dthDurOrderedByTrialMeetCriteria == uniqueDurations(d);
     % dthTrials = dthDurOrderedByTrialMeetCriteria == subtractLast3UniqueDurations(d);
    
    for f = 1:length(frames) 
        % subplot(7,4,s) % for subtractLongDurs
         subplot(5,4,s)

        %axes('Position',[left bottom width height])
        imagesc(mean(onsetDf(:,:,frames(f),dthTrials),4)-mean(onsetDf(:,:,11,dthTrials),4),range);   
%       
        
        if subplotNum == 1
            ylabel('df/f')
            xlabel ('frames')
        else
            set(gca,'XTick',[], 'YTick', [])
        end
    
        s = s + 1;
        axis off;
        axis image;

    end
    
end

% A = mean(onsetDf(:,:,frames(f),cthTrialsMinusOne),4)-mean(onsetDf(:,:,11,cthTrialsMinusOne),4);
% imagesc(linspace(0,1,4),linspace(0,1,7),A)
% imageChangeInDfFromStimOnseToFrameNum = mean(onsetDf(:,:,frames(f),cthTrialsMinusOne),4)-mean(onsetDf(:,:,11,cthTrialsMinusOne),4);
% imagesc(linspace(0,1,4),linspace(0,1,7),imageChangeInDfFromStimOnseToFrameNum)
        