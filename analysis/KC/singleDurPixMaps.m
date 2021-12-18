 % PIXEL-WISE by DURATION minus BASEline
 
 
 
    clear frameRange % define this up here cuz gets used in following d loop
    frameRange = [stimOnsetFrame:1:stimOnsetFrame+14] % index of each frame to be plotted

    % subplot images for each framerange frame are calulated & plotted per con/dur, 
    % so need figure outside c/d loop
    figure % make one figure for all subplots

    clear titleText
    titleText = ': peri-stimulus cortical response to varying durations'; % making char variables for sprintf/title later
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
            
            subplot(1,12,newF)
            %subplot(length(uniqueDurations),length(frameRange),newF) 
            imagesc(allBaselinedStimOnsetDf(:,:,f),range)

            if colorMapOrNot == 1
                colormap jet
            end 

            axis off;
            axis image;

            hold on % keep plotting each new frame on same fig

        end % end f loop

    end % end c loop 
    
%% peak per stim cond

clear subplotNum
    subplotNum = 1; % using subplotNum to index subplots since neither uniqueCon or uniqueDur have the right values

    clear fig
    fig = figure; % one fig all images % need fig var to alter axes later

    clear titleText
    titleText = ': PEAK cortical response to each UNIQUE stim condition'; % making char variables for sprintf/title later
    %suptitle(sprintf('%s', date, subjName, titleText));

    % index into trials for each combo of DUR & CON @ peak frames

    % for each contrast (row):
    for c = 1:length(uniqueContrasts)

        % going to show pix wise image for cth contrast (row) at each duration (column)
        for d = 1:length(uniqueDurations)

            % select for trials at the cth contrast & dth duration
            clear cthDthTrials 
            cthDthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
            %numCthDthTrials = sum(cthDthTrials)

             clear cthDthPeakImage
             % get MEAN PEAK activity IMAGE across CTHDTH TRIALS
             allPeakFramesCthDthtrialsOnsetDf = onsetDf(:,:,peakFrameIdx,cthDthTrials); % index into peak frames & cth dth trials
             mnPeakFramesCthDthtrialsOnsetDf = mean(allPeakFramesCthDthtrialsOnsetDf,3); % mean over peak frames
             mnPeakFramesCthDthtrialsOnsetDf = squeeze(mnPeakFramesCthDthtrialsOnsetDf); % squeeze
             mnPeakFramesMnCthDthtrialsOnsetDf = mean(mnPeakFramesCthDthtrialsOnsetDf,3); % mean over cthdth trials
             meanPeakImageCthDthTrials = squeeze(mnPeakFramesMnCthDthtrialsOnsetDf); % squeeze

             % get BASEline IMAGE at cthdth trials
             allBaseFramesCthDthtrials = onsetDf(:,:,baselineIdx,cthDthTrials); % index
             meanBaseFramesCthDthtrials = mean(allBaseFramesCthDthtrials,3); % mean over baseline frames
             meanBaseFramesCthDthtrials = squeeze(meanBaseFramesCthDthtrials); % squeeze
             meanBaseFramesCthDthtrials = mean(meanBaseFramesCthDthtrials,3); % mean over trials
             meanBaseImageCthDthtrials = squeeze(meanBaseFramesCthDthtrials); % squeeze

             % SUBTRACT BASELINE from MEAN PEAK ACTIVITY IMAGE for CTHDTH TRIALS
             % just subtracting an image from an image here, not subtracting one baseline value from each cell in a trace
             baselinedPeakImageCthDthTrials =  meanPeakImageCthDthTrials-meanBaseImageCthDthtrials;

             % PLOT BASElined PEAK image
             subplot(1,7,c)
             %subplot(length(uniqueContrasts),length(uniqueDurations),subplotNum)
             imagesc(baselinedPeakImageCthDthTrials,range)

             if colorMapOrNot == 1
                colormap jet
             end 

             axis off;
             axis image;

             subplotNum = subplotNum+1; % use this to index subolots because it 
             % increases by every time a stim cond is plotted

             hold on % plotting all stim conditions on same fig, diff subplots (subplotNum)

        end % end d loop

     end % end c loop   

%     % Give common xlabel & ylabel
%     han=axes(fig,'visible','off'); 
%     han.XLabel.Visible='on';
%     han.YLabel.Visible='on';
%     ylabel(han,'contrast');
%     xlabel(han,'duration');

%% stim pics figs

addpath 'F:\Kristen\Widefield2\stimPics'

figure

subplot(1,7,1)
imshow('Con0.png')
hold on

subplot(1,7,2)
imshow('ConPt03.png')
hold on

subplot(1,7,3)
imshow('ConPt0625.png')
hold on

subplot(1,7,4)
imshow('ConPt125.png')
hold on

subplot(1,7,5)
imshow('ConPt25.png')
hold on

subplot(1,7,6)
imshow('ConPt5.png')
hold on

subplot(1,7,7)
imshow('Con1.png')