function showPixWisePeriStim_DUR(stimOnsetFrame,date,subjName,uniqueContrasts,conOrderedByTrialMeetCriteria,onsetDf,baselineIdx,uniqueDurations,durOrderedByTrialMeetCriteria);
% The purpose of this function is to plot pixel wise images of peri-stim dfof response according to stim conditions
% Note that the default is set to dispay frames from the stimuls onset to 14 frames after, can change this in the code if need
% Because we are plotting the images by trial first, we select for those trials, get the mean df, and then take the mean baseline 
% across baseline frames *for those same sub-selection of trials*... baselining happens a new for each stim condition

    % PIXEL-WISE by CONTRAST minus BASEline

    % SELECT RANGE for IMAGESC to SHOW PIX WISE IMAGES
    range = input('FIG 1: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
    colorMapOrNot = input('use colormap jet or no (yes = , no = 2)?: ')

    % pick frame range
    clear frameRange % define this up here cuz gets used in following c loop
    frameRange = [stimOnsetFrame:1:stimOnsetFrame+12]; % index of each frame to be plotted

    % subplot images for each framerange frame are calulated & plotted per con/dur, 
    % so need figure outside c/d loop
    figure % make one figure for all subplots

    
    % PIXEL-WISE by DURATION minus BASEline

    %clear frameRange % define this up here cuz gets used in following d loop
    %frameRange = [stimOnsetFrame+1:1:stimOnsetFrame+12] % index of each frame to be plotted

    % subplot images for each framerange frame are calulated & plotted per con/dur, 
    % so need figure outside c/d loop
    figure % make one figure for all subplots

    %clear titleText
    %titleText = ': peri-stimulus cortical response to varying durations'; % making char variables for sprintf/title later
    %supTit = suptitle(sprintf('%s', date, subjName, titleText));
    %set(supTit, 'FontSize', 14)

    % for each duration, get mean pix wise image at that duration for
    % the frame range specified in 'frameRange'
    clear d
    for d = 1:length(uniqueDurations);    

        clear dthTrials
        % take only cdh trials 
        dthTrials = durOrderedByTrialMeetCriteria == uniqueDurations(d);

        % whole peri stim frame range, mean across trials
        clear stimOnsetDf
        stimOnsetDf = mean(onsetDf(:,:,frameRange,dthTrials),4);

        % get BASEline trials & take mean
        baselineStimOnsetDf = mean(onsetDf(:,:,baselineIdx,dthTrials),4); % baseline frames, mean across cth trials
        baselineStimOnsetDf = squeeze(baselineStimOnsetDf);  % squeeze
        meanBaselineStimOnsetDf = mean(baselineStimOnsetDf,3); % mean across baseline frames 

        % DO the BASELINE CORRECTION (get baselined pix wise images for frames in frameRange)

        clear allBaselinedStimOnsetDf % this is what I'll use to plot eventually

        % still w/in the d loop
        clear f
        for f = 1:length(frameRange) 

            % baseline correction, one frame at a time % Q: need do this or could just do element-wise subtraction?
            eachBaselinedStimOnsetDf = stimOnsetDf(:,:,f)-meanBaselineStimOnsetDf; % use f cuz frames are re-indexed in 
            % stimOnsetDf (compared to frameRange), such that stim onset frame becomes frame 1
            allBaselinedStimOnsetDf(:,:,f) = eachBaselinedStimOnsetDf; % store the baselined images for the whole frame range

            % PLOT each baselined frame in frame range, w/row for each con/dur

            % this is a method for dealing with the fact that the subplot number (newF) needs to increase by 1 every time, but
            % neither the c,d, or f have the right values for that...
            newF = d-1; % gonna mult f by 0 if c = 1...
            newF = newF*length(frameRange); % mult by num frames in periStimFrameRange. 
            % So if theres 10 frames it's (c-1)*10, so newF = 0 if c=1, 10 if c = 2, 20 if c = 3... 60 if c = 7
            newF = f+newF; % finally, add f to get the new subplot index 

            subplot(length(uniqueDurations),length(frameRange),newF) 
            imagesc(allBaselinedStimOnsetDf(:,:,f),range)

            if colorMapOrNot == 1
                colormap jet
            end 

            axis off;
            axis image;

            hold on % keep plotting each new frame on same fig

        end % end f loop

    end % end c loop 
    
end

