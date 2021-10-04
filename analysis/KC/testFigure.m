% PIXEL-WISE by DURATION minus BASEline

clear range
range = [0 0.01];

% which frames to plot over? stim onset frame + 10 frames
clear frameRange
frameRange = [stimOnsetFrame:1:stimOnsetFrame+10];

figure

clear titleText
titleText = ': peri-stimulus cortical response to varying durations, con = 1'; % making char variables for sprintf/title later
supTit = suptitle(sprintf('%s', date, subjName, titleText));
%set(supTit, 'FontSize', 14)

clear c
for c = 1; % highest contrast only

    clear d
    for d = 1:length(uniqueDurations);    

        clear cthDthTrials
        conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,idxOnsetsMeetBothCriteria); 
        cthDthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
        
        % whole peri stim frame range, mean across trials
        frameRangeOnsetDf = mean(onsetDf(:,:,frameRange,cthDthTrials),4);
         
        % BASEline trials & mean
        baselineFrameRangeOnsetDf = mean(onsetDf(:,:,baselineIdx,cthDthTrials),4); % baseline frames, mean across cth trials
        baselineFrameRangeOnsetDf = squeeze(baselineFrameRangeOnsetDf); 
        meanBaselineFrameRangeOnsetDf = mean(baselineFrameRangeOnsetDf,3); % mean across baseline frames & cth trials
     
         clear f
         for f = 1:length(frameRange)
         
             % baseline correction, one frame at a time
             eachBaselinedFrameRangeOnsetDf = frameRangeOnsetDf(:,:,f)-meanBaselineFrameRangeOnsetDf;
             allBaselinedFrameRangeOnsetDf(:,:,f) = eachBaselinedFrameRangeOnsetDf; % the whole frame range, baselined
         
             % plot, one frame at a time
             % BUT we need to change the frame/subplot index eaxh row/contrast
             clear newF
             newF = d-1; % gonna mult f by 0 if d = 1, 1 if d = 2...
             newF = newF*length(frameRange); % then mult by num frames in periStimFrameRange. So if 10 frames it's (c-1)*10, so newF = 0 if c=1, 10 if c = 2, 20 if c = 3... 60 if c = 7
             newF = f+newF; % finally, add f to get the new f index
             subplot(length(uniqueDurations),length(frameRange),newF) 
             imagesc(allBaselinedFrameRangeOnsetDf(:,:,f),range)

            axis off;
            axis image;
         
            hold on % keep plotting each new frame on same fig

        end % end f loop
    
    end % end d loop

end % end c loop

display('imagesc range is:')
range 