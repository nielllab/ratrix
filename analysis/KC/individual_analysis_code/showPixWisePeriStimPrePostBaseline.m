function showPixWisePeriStimPrePostBaseline(conOrderedByTrialMeetCriteria,uniqueContrasts,onsetDf,baselineIdx,date,subjName)
% shows pix wise peri-stim activity pre & post baseline subtaction

    % take only the highest contrast value stim conditions, regardless of duration 
    % (you could seperate by duration but I just wanted a strong flurescence response to plot)
    highestConAllDurTrials = conOrderedByTrialMeetCriteria == max(uniqueContrasts); 
    %highestConAllDurTrials = highestConAllDurTrials(1,1:2043);
    % PRE-BASELINE SUBTRACTION
    
    % SELECT RANGE for IMAGESC to SHOW PIX WISE PRE PERI-STIM FRAMES BASELINE
    range = input('Fig 1: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
    colorMapOrNot = input('use colormap jet or no (yes = , no = 2)?: ')

    figure % one figure w/each frame as a subplot
    titleText = sprintf('\n peri-stim frames, no baseline subtraction, highest Con');
    %suptitle(sprintf('%s ',date,subjName,titleText))
        
    % for each frame, plot pix wise image for highest con trials
    clear f
    for f = 1:size(onsetDf,3); % need to use size here cuz longest dim is trials, not frames for onsetDf 

         subplot(4,6,f) % CHANGE if chenge num pre & post sim frames in onsetDf
         imagesc(mean(onsetDf(:,:,f,highestConAllDurTrials),4),range); % show each frame for highest contrials
         %title(f);
         
         if colorMapOrNot == 1
            colormap jet
         end 

         axis off;
         axis image;

    end
    
    
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
    
    
    % BASLINED
    
    figure
    titleText = sprintf('\n peri-stim frames, BASELINED, highest Con');
    suptitle(sprintf('%s ',date,subjName,titleText))

    % for every frame, subtract the baseline frame
    clear f
    for f = 1:size(onsetDf,3);

        subplot(4,6,f)
        imagesc(mean(onsetDf(:,:,f,highestConAllDurTrials ),4)-meanBaselineImageHiConTrials,range) % trials defined in 1st step of this code

         if colorMapOrNot == 1
            colormap jet
         end 

        axis off;
        axis image;

    end
        
end

