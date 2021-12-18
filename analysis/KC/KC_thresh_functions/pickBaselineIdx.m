function [stimOnsetFrame,baselineIdx] = pickBaselineIdx(numPreStimFrames,conOrderedByTrialMeetCriteria,uniqueContrasts,date,subjName,onsetDf) 
% the purpose of this function is to pick baseline Idx frames
% range is set inside this function

    % get onsetDf INDEX for baseline frames
    baselineIdx = 1:numPreStimFrames % can change this if you want different/a subsection of baseline frames
    stimOnsetFrame = numPreStimFrames+1 % stim onset is always 1 frame ahead of the last baseline frame... not sure if need this var but nice to have stored out...

    % first let's plot the pixel-wise images of each frame in onsetDf (peri-stim 'chunk')*pre*-baseline, so we can later compare

    % take only the highest contrast value stim conditions, regardless of duration 
    % (you could seperate by duration but I just wanted a strong flurescence response to plot)
    highestConAllDurTrials = conOrderedByTrialMeetCriteria == max(uniqueContrasts); 
    %highestConAllDurTrials  = intersect(idxOnsetsMeetsCriteria,highestConAllDurTrials);
    %highestConAllDurTrials = highestConAllDurTrials(1,1:2043);
    
    % CALCULATE MEAN BASELINE IMAGE
    % get baseline frames, across all points, highest contrast trials only
    clear allBaselineFrameOnsetDf
    allBaselineFramesHiConOnsetDf = onsetDf(:,:,baselineIdx,highestConAllDurTrials);
    % take mean over frames for baseline frames of hiCon trials
    clear meanBaselineImage
    meanBaselineImage = mean(allBaselineFramesHiConOnsetDf,3); % 3rd dim is frames
    meanBaselineImage = squeeze(meanBaselineImage);
    % average over trials
    clear meanBaselineImageHiConTrials 
    meanBaselineImageHiConTrials = mean(meanBaselineImage,3); % this is the "mean baseline image"

    % SHOW MEAN BASELINE IMAGE
    
    % Now let's plot the basline image w/a very narrow range, just to see
    % that the activity distribution is fairly even and very close to zero
  
    % select range & color map or not
    range = [-0.01 0.01]; % change if want
    %colorMapOrNot = input('use colormap jet or no (yes = 1, no = 2)?: ')
    colorMapOrNot = 2; % no color map
    
    figure
    titleText = sprintf('\n MEAN BASELINE IMAGE, highest Con');
    title(sprintf('%s ',date,subjName,titleText))

    imagesc(meanBaselineImageHiConTrials,range) 

    if colorMapOrNot == 1
        colormap jet
    end  
    
end
