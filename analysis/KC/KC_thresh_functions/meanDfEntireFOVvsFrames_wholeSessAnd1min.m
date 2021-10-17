function meanDfEntireFOVvsFrames_wholeSessAnd1min(df,subjName,date)
% The purpose of this function is to get a braod look at flurescence activity across the entire recording field of view, and across
% 1 minute of recording, ~20,000 frames in. These figures could be used diagnostically. 
% This function takes in df and generates two plots - one of the mean fluorescence across the entire FOV, vs frames, 
% and the other is the same but for only ~1 minute of recording. 
% This function also needs subjName & date for figures.


    % BROAD look at ACTIVITY over WHOLE FOV

    titleText = sprintf('passivie viewing threshold movie \n no baseline subtraction');
    t = suptitle(sprintf('%s: ',date,subjName,titleText));
    %set(t, 'FontSize', 12);

    clear j
    for j = 1:2; % for 2 figures
        if j == 1
            % taking the average of the entire imaging field over WHOLE TIME
            mn = mean(mean(abs(df),2),1); 
            mn = squeeze(mn);
            % plot
            subplot(1,2,j)
            plot(squeeze(mn));  
            xlim([0 size(squeeze(mn),1)])  
            ylim([0 0.075])
            xlabel('frames')
            ylabel('mean dfof of entire FOV') 
            clear numFrames4title
            numFrames4title = length(mn); 
            clear numSecs4title
            numMins4title = (numFrames4title/10/60);
            title(sprintf('mean dfof of entire FOV over %0.00f mins',numMins4title))
        end 
        if j == 2
            % let's look at that average trace over a time scale closer 
            % to our AVG TRIAL LENGTH, ~2,2s / 22 imaging frames
            sqMn = squeeze(mn); % getting rid of singletons
            trSqMn = sqMn'; % transposing
            % select only ~1 minute, in the middle-ish of the recording (@ 10 Hz, 1 min = 600 frames)
            fiveStimsTrSqMn = trSqMn(1,20000:26000);
            numStimPresentations = 5;
            % plot
            subplot(1,2,j)
            plot(fiveStimsTrSqMn ); 
            xlim([0 length(fiveStimsTrSqMn)])
            ylim([0 0.075])
            ylabel('mean abs dfof of entire FOV') 
            xlabel('frame') 
            clear numFrames4title
            numFrames4title = length(fiveStimsTrSqMn); 
            clear numSecs4title
            numSecs4title = (numFrames4title/10);
            title(sprintf('mean dfof of entire FOV for %0.00f secs (%0.00f stim presentations)',numStimPresentations,numSecs4title)); 
        end 
    end 

    numFramesWholeSession = size(mn,1)
    
end

