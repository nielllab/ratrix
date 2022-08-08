function [baselinedActIm,range,colorMapOrNot] = pickPeakActIm4Points(conAndDurOrderedByTrialMeetCriteria,uniqueContrasts,uniqueDurations,peakFrameIdx,onsetDf,baselineIdx)
% This function makes the peak activity image that will be used to pick points from. 
% outputs 'meanActImFrames' & range & colorMap which are used in next step to pick points. 

    % PICKING PEAK ACTIVATION IMAGE 
    % (image of highest contrast & duration during peak response, used to pick points in next step)
    
    % SELECT RANGE for IMAGESC to SHOW PIX WISE IMAGES
    range = input('FIG 1: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
    colorMapOrNot = input('use colormap jet or no (yes = 1, no = 2)?: ')

    % selelct max con dur trials
    clear maxConDurTrials % use the trials with the strongest reaponse b/c it makes it easiest to identify visual areas
    maxConDurTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == max(uniqueContrasts) & conAndDurOrderedByTrialMeetCriteria(2,:) == max(uniqueDurations);

    % peak frame idx
    % Q; still true?: within the chunk of frames in onsetDf, which do you want indexed/averaged over? always pick the 4th, 5th, 6th, & 7th frames 
    % following stim onset, b/c that shows "imprint" of vis ctx best 
    clear actImIdx
    % actImIdx = [stimOnsetFrame+4,stimOnsetFrame+5,stimOnsetFrame+6,stimOnsetFrame+7]; % stimOnsetFrame defined in making onsetDf code
    actImIdx = peakFrameIdx;

    % get peak activity frames for highest c & d trials
    clear allActImFrames
    allActImFrames = onsetDf(:,:,actImIdx,maxConDurTrials); 

    % take the average of the image across peak frames and across highest stim param value trials
    clear meanActIm
    meanActIm = squeeze(mean(allActImFrames,3)); % mean across frames
    meanActIm = mean(meanActIm,3); % mean across trials

    % get BASEline IMAGE at max con dur trials
    allBaseFramesMaxConDurTrials = onsetDf(:,:,baselineIdx,maxConDurTrials); % index
    meanBaseFrameMaxConDurTrials = mean(allBaseFramesMaxConDurTrials,3); % mean over baseline frames
    meanBaseFrameMaxConDurTrials = squeeze(meanBaseFrameMaxConDurTrials); % squeeze
    meanBaseFrameMaxConDurTrials = mean(meanBaseFrameMaxConDurTrials,3); % mean over trials
    meanBaseImageMaxConDurTrials = squeeze(meanBaseFrameMaxConDurTrials); % squeeze

    % SUBTRACT BASELINE from MEAN PEAK ACTIVITY IMAGE for CTHDTH TRIALS
    % just subtracting an image from an image here, not subtracting one baseline value from each cell in a trace
    baselinedActIm = meanActIm - meanBaseImageMaxConDurTrials;

    % plot the mean peak activation image 

    figure
    %suptitle('points picked over peak activation')

    imagesc(baselinedActIm,range)

    if colorMapOrNot == 1
        colormap jet
    end 

    axis equal

end

