%% ONSETS - needs you to have done the 'CROP' step first because that's 
% where dfCROP gets made

% remember, frameT gets redefined even before t0 gets defined
frameT = frameT-frameT(1); 

%% making variable 'onset' (monitor time/60Hz, seconds relative to trial onset (start of 'stop'))

clear onsets
clear i 

% making stimulus onset times relative to trial onset
t0 = allStop(1).frameT(1); % take the first frame after "the mouse stops" for the FIRST time (1st trial onset)

for i = 1:length(allResp) % I think response period is when the stim comes on until mouse answers
    
    onsets(i) = allResp(i).frameT(1)-t0; % onsets is in seconds
    
end % now you have a list of the first frames during the resposne period
% in time that is relative to when the very FIRST trial started/"mouse stoppoed the ball"


%% making variable 'onsetFrame', gets the index for the 1st imaging frame after the stimulus onset
% these indicies are for frames that are 10hz apart, but we've only got a
% collection of the first one (frame) after each onset

clear onsetFrame
clear i

% collecting the index of the first imaging frame that follows each stim onset
for i = 1:length(onsets); % for each onset time of each stimulus/response period
  
    onsetFrame(i) = find(diff(frameT>onsets(i))); % onsetFrame is the frame index for the 
    % imaging frame frame that matches up with the onset of the stim (onsets(i))
    
end

%% UNCOMMENT if you need to filter trials to allow only trials that meet criteria
% regarding how many frames proceed and follow that stimulus onest frame

% preStimframes = 4;
% postStimframes = 10;

% % get indicies for onset frames that meet the criteria
% idxOnsetFramesEnuffB4StimOnset = find(onsetFrame>preStimframes);
% idxOnsetFramesEnuffAfterStimOnset = find(onsetFrame+postStimframes<max(onsetFrame));
% idxOnsetFramesMeetBothCriteria = intersect(idxOnsetFramesEnuffB4StimOnset,idxOnsetFramesEnuffAfterStimOnset);
% 
% % redefine onsets
% onsetFrame = onsetFrame(idxOnsetFramesMeetBothCriteria);

%% making variable 'onsetDf'

% LOOKS LIKE I'm going to want to be changing the range around depending on
% what figures I'm making - less frames for activation image than for
% pixel wise images of baseline subtra

% change these values based on figures you're making
numPreStimFrames = 4;
numPostStimFrames = 18;

clear i
clear onsetDf

for i = 1:length(onsetFrame)

    % then select only the imaging frames right before & after the onset imaging frame of each stim
    onsetDf(:,:,:,i) = dfCROP(:,:,onsetFrame(i)-numPreStimFrames:onsetFrame(i)+numPostStimFrames);
end

%% looking at the average trace over time for onsetFrame

% mean across whole image, all trials/conditions
mnOnsetChunk = mean(squeeze(mean(squeeze(mean(onsetDf,1)))),2)';

numFrames = length(mnOnsetChunk);
numSec = (numFrames)*0.1;

figure
plot(mnOnsetChunk)
title(sprintf('mean abs dfof across entire image for 1st %0.00f frames/%0.00f sec',numFrames4title,numMins4title)); 
xlabel('frame') 
ylabel('df/f')
xlim([0 numFrames])

%% let's try to baseline that:

% baselineIdx is only based on stimOnsetNum, defined in baselindGraphical1
% script   
allBaseMnOnsetChunk = mnOnsetChunk(1,baselineIdx);

% get mean for 1st 4 frames
meanBaseOnsetChunk = mean(allBaseMnOnsetChunk,2);

%subtract mean from each cell in mnChunkOnset vector
baselinedMnOnsetChunk = mnOnsetChunk-meanBaseOnsetChunk;

clear x_axis
x_axis = 1:length(baselinedMnOnsetChunk);
figure
plot(x_axis,baselinedMnOnsetChunk)
title('mean trace across whole onset chunk w/BASELINE subtracted')


