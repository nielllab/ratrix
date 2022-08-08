function [stimOnsetFrame,baselineIdx] = subtractBaseline(numPreStimFrames,conOrderedByTrialMeetCriteria,uniqueContrasts,date,subjName,onsetDf) 
% The purpose of this code is to display the pixel wise images for each frame of onsetDf (peri-stim activity),
% then choose the basline frames (usually the same as numPreStimFrames, but you can change that in this code if needed),
% display the man baseline image, then subtract that image from each frame in onsetDf, then display the baslined figure.   
% The point of all that is to visually assess that the baselining method is working, and that the mean activity 
% during the basline period is close to zero, as it should be since there's no stim presented yet.
    
    % PLOT PRE-baselined peri-stim pix wise onsetDf images for highest contrast trials

    % get onsetDf INDEX for baseline frames
    baselineIdx = 1:numPreStimFrames % can change this if you want different/a subsection of baseline frames
    stimOnsetFrame = numPreStimFrames+1 % stim onset is always 1 frame ahead of the last baseline frame... not sure if need this var but nice to have stored out...

    % first let's plot the pixel-wise images of each frame in onsetDf (peri-stim 'chunk')*pre*-baseline, so we can later compare

    % take only the highest contrast value stim conditions, regardless of duration 
    % (you could seperate by duration but I just wanted a strong flurescence response to plot)
    highestConAllDurTrials = conOrderedByTrialMeetCriteria == max(uniqueContrasts); 
    
    Loop = true;
    while(Loop) % so long as the loop var = true, the next set of code will continue to loop thru...
    % this is so you can choose a new range if you want. I need this w/in
    % the function b/c I need to get this fig right before moving onto more
    % figs that this same function makes
    
        % SELECT RANGE for IMAGESC to SHOW PIX WISE PRE PERI-STIM FRAMES BASELINE
        range = input('Fig 1: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
        colorMapOrNot = input('use colormap jet or no (yes = , no = 2)?: ')
    
        figure % one figure w/each frame as a subplot
        titleText = sprintf('\n peri-stim frames, no baseline subtraction, highest Con');
        suptitle(sprintf('%s ',date,subjName,titleText))
        
        % for each frame, plot pix wise image for highest con trials
        clear f
        for f = 1:size(onsetDf,3); % need to use size here cuz longest dim is trials, not frames for onsetDf 

             subplot(4,6,f) % CHANGE if chenge num pre & post sim frames in onsetDf
             imagesc(mean(onsetDf(:,:,f,highestConAllDurTrials),4),range); % show each frame for highest contrials
             title(f);

             axis off;
             axis image;

        end
        
        if colorMapOrNot == 1
            colormap jet
        end 

        % to make figure code repeat if want new range
        repeatCodeOrNot = input('do you want to make this figure again, but with a different range? 1 = yes 2 = no: ')

        if repeatCodeOrNot == 2;   
            Loop = false;   
        end
    
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

    % SHOW MEAN BASELINE IMAGE
    
    % Now let's plot the basline image w/a very narrow range, just to see
    % that the activity distribution is fairly even and very close to zero
    
    Loop = true;
    while(Loop) 
    
        % SELECT RANGE for IMAGESC to SHOW PIX WISE PRE PERI-STIM MEAN BASELINEFRAMES
        range = input('FIG 2: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
        colorMapOrNot = input('use colormap jet or no (yes = , no = 2)?: ')

        figure
        titleText = sprintf('\n MEAN BASELINE IMAGE, highest Con');
        title(sprintf('%s ',date,subjName,titleText))
        
        imagesc(meanBaselineImageHiConTrials,range) 
        
        if colorMapOrNot == 1
            colormap jet
        end 
        
        % to make figure code repeat if want new range
        repeatCodeOrNot = input('do you want to make this figure again, but with a different range? 1 = yes 2 = no: ')

        if repeatCodeOrNot == 2;   
            Loop = false;   
        end 
        
    end 
    
    % plot peri-stim onsetDf for hi con trials with mean BASELINE SUBTRACTED
    
    Loop = true;
    while(Loop) % so that I can adjust the range
    
        % SELECT RANGE for IMAGESC 
        range = input('FIG 3: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
        colorMapOrNot = input('use colormap jet or no (yes = , no = 2)?: ')

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
        
        % to make figure code repeat if want new range
        repeatCodeOrNot = input('do you want to make this figure again, but with a different range? 1 = yes 2 = no: ')

        if repeatCodeOrNot == 2;   
            Loop = false;   
        end
    
    end
