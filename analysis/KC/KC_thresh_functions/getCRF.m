function [allPtsAllDurs_CRF,allPtsAllDurs_CRF_err] = getCRF(visArea,durat,cont,uniqueContrasts,uniqueDurations,conAndDurOrderedByTrialMeetCriteria,idxPupTrials,nthPeakFrameIdx,nthPTSdfof,nthBaselineIdx)
% gets CRF

    % for each POINT, for each DUR, get CRF for desired pupil state trials, store in group/sessions matrix
        
    clear i
    for i = visArea % can be 1 area or length of xPts
        
        % new all durs CRF matrix for each point
        clear allDurs_CRF
        clear allDurs_CRF_err

        clear d
        for d = durat % at each duration

            % new crf for each dur
            clear CRF
            clear CRF_err
            
            clear c
            for c = cont % for each duration at each contrast

                 % SELECT TRIALS for specified pupil state & stim params
                 [idxTrials] = getTrials(conAndDurOrderedByTrialMeetCriteria,c,d,uniqueContrasts,uniqueDurations,idxPupTrials);

                 % start of CRF code - getting mean dfof for cth dth stim trials, nth pup trials

                 % index into PEAK FRAMES of trials, returns # frames by # trials
                 sq5FramesOverTrialsPTSdfof = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxTrials));
                 % take the mean over frames, returns 1 x # trials
                 meanOverFramesSq5FramesOverTrialsPTSdfof = mean(sq5FramesOverTrialsPTSdfof,1);
                 % now take the mean over trials 
                 meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof = mean(meanOverFramesSq5FramesOverTrialsPTSdfof);
                 cthCRFvalue = meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof ;

                 % GET mean BASEline (the baseline for each CRF value is the mean of the baseline frames for seelcted trials)
                 % get basline frames for each trial, gives frames x trials
                 baselineFrames = squeeze((nthPTSdfof(i,nthBaselineIdx,idxTrials)));
                 % take mean across trials 
                 meanBaselineFrames = mean(baselineFrames,2);
                 % take mean across frames
                 meanBaselineFrames = mean(meanBaselineFrames,1);
                 
                 % do BASEline CORRECTION
                 % subtract the cth baseline from the flourescence at each c
                 baselinedCthCRFvalue = cthCRFvalue-meanBaselineFrames; % clear this var in between subplots

                 % COLLECT CRF for each contrast
                 CRF(1,c) = baselinedCthCRFvalue;

                % STDERR
                % calulate the StdErr for each CRF point calulated above (one err value for each contrast)
                % that means I want the error over trials, not over frames - that info is in the 'meanOverFramesSq5FramesOverTrialsPTSdfof' variable (1 x # trials)
                clear stdErr
                stdErr = std(meanOverFramesSq5FramesOverTrialsPTSdfof)/sqrt(length(idxTrials)); % check: length or sum?
                CRF_err(1,c) = stdErr; % clear outside j loop

            end % end c loop

        end % end d loop

        % collect CRF & err for each duration
        allDurs_CRF(d,:) = CRF;
        allDurs_CRF_err(d,:) = CRF_err;

    end % end i loop

    % collect all pts all durs CRFs
    allPtsAllDurs_CRF(:,:,i) = allDurs_CRF;  
    allPtsAllDurs_CRF_err(:,:,i) = allDurs_CRF_err;

end

