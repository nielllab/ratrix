function showPixWisePeakActivityPerStimCond(date,subjName,uniqueContrasts,uniqueDurations,conAndDurOrderedByTrialMeetCriteria,peakFrameIdx,onsetDf,baselineIdx)
% UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    % SHOW IMAGES for each STIM COND (con dur combo) at PEAK response
    
    % SELECT RANGE for IMAGESC to SHOW PIX WISE IMAGES
    range = input('FIG 1: from 0-1, what range values to use? Enter in bracket form with low & high end values: ') % don't need to save range var out cuz don't need it in following functions/code, just display it 
    colorMapOrNot = input('use colormap jet or no (yes = 1, no = 2)?: ')

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
             subplot(length(uniqueContrasts),length(uniqueDurations),subplotNum)
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

    % Give common xlabel & ylabel
    han=axes(fig,'visible','off'); 
    han.XLabel.Visible='on';
    han.YLabel.Visible='on';
    ylabel(han,'contrast');
    xlabel(han,'duration');

end

