function [allTrialsAllSessAllPtsAllDurs_CRF,allTrialsAllSessAllPtsAllDurs_CRF_err] = ALLTRIALS_CRF_byBehState(nGroup,state,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria,groupPTSdfof,groupPeakFrameIdx,groupBaselineIdx,groupIdxStatTrials,groupIdxRunTrials,groupIdxSmallPupilTrials,groupIdxLargePupilTrials,visArea,durat,cont,conAndDurOrderedByTrialMeetCriteria,uniqueContrasts,uniqueDurations)
% general CRF for 1 beh state ...

clear allTrialsAllSessAllPtsAllDurs_CRF
clear allTrialsAllSessAllPtsAllDurs_CRF_err

% for each session
clear n
for n = 1:nGroup

    % EXTRACT list of stim params & stim conditions in order of trial 
    [durOrderedByTrialMeetCriteria,uniqueDurations,conOrderedByTrialMeetCriteria,uniqueContrasts,conAndDurOrderedByTrialMeetCriteria] = getStimParams4loops(n,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria);
    
    % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
    nthPTSdfof = groupPTSdfof{1,n};
    nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
    nthBaselineIdx = groupBaselineIdx{1,n};
    
    if state == 'loRun'
    
        % EXTRACT loRun TRIAL INDICIES
        nthIdxBehStateTrials = groupIdxStatTrials{1,n}; 
        
    end 
    
    if state == 'hiRun'
    
        % EXTRACT hiRun TRIAL INDICIES
        nthIdxBehStateTrials = groupIdxRunTrials{1,n}; 
        
    end
    
    if state == 'loPup'
    
        % EXTRACT hiRun TRIAL INDICIES
        nthIdxBehStateTrials = groupIdxSmallPupilTrials{1,n}; 
        
    end
    
    if state == 'hiPup'
    
        % EXTRACT hiRun TRIAL INDICIES
        nthIdxBehStateTrials = groupIdxLargePupilTrials{1,n}; 
        
    end
    
    clear allPtsAllDurs_CRF
    clear allPtsAllDurs_CRF_err
    
    % for each area
    clear i
    for i = visArea % can be 1 area or length of xPts

        % new all durs CRF matrix for each point
        clear allDurs_CRF
        clear allDurs_CRF_err
        
        % for each duration
        clear d
        for d = durat % at each duration

            % new crf for each dur
            clear CRF
            clear CRF_err
            
            % for each contrast
            clear c
            for c = cont 

                % SELECT TRIALS for specified pupil state & stim params
                [idxTrials] = getTrials(conAndDurOrderedByTrialMeetCriteria,c,d,uniqueContrasts,uniqueDurations,nthIdxBehStateTrials);
                
                % INDEX PEAK FRAMES of SELECTED TRIALS in PTSDFOF, returns # frames by # trials
                sq5FramesOverTrialsPTSdfof = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxTrials));
                
                % start of CRF code - getting mean dfof for cth dth stim trials,nth pup/run trials
                
                % take the mean over frames, returns 1 x # trials
                meanOverFramesSq5FramesOverTrialsPTSdfof = mean(sq5FramesOverTrialsPTSdfof,1);
                % now take the mean over trials 
                %meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof = mean(meanOverFramesSq5FramesOverTrialsPTSdfof);
                %cthCRFvalue = meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof ;
                
                % GET mean BASEline (the baseline for each CRF value is the mean of the baseline frames for seelcted trials)
                % get basline frames for each trial, gives frames x trials
                baselineFrames = squeeze((nthPTSdfof(i,nthBaselineIdx,idxTrials)));
                % take mean across trials 
                meanBaselineFrames = mean(baselineFrames,2);
                % take mean across frames
                meanBaselineFrames = mean(meanBaselineFrames,1);

                % do BASEline CORRECTION
                % for each trial, subtract the cth baseline from the flourescence at each c
                baselinedCthCRFvalues = meanOverFramesSq5FramesOverTrialsPTSdfof-meanBaselineFrames; % clear this var in between subplots
                
                % COLLECT CRF for each contrast at dth duration
                CRF{c}= baselinedCthCRFvalues;
                
                % STDERR
                % calulate the StdErr for each CRF point calulated above (one err value for each contrast)
                % that means I want the error over trials, not over frames - that info is in the 'meanOverFramesSq5FramesOverTrialsPTSdfof' variable (1 x # trials)
                clear stdErr
                stdErr = std(baselinedCthCRFvalues)/sqrt(sum(idxTrials)); % check: length or sum?
                CRF_err(1,c) = stdErr; % clear outside j loop
                
                numTrials = length(idxTrials);
                %numTrialsEachCon_CRF(1,numTrials) = numTrials;

            end % end c loop
            
            % collect CRF & err for each duration
            % c {cell of trials} x d:
            allTrialsAllDurs_CRF{:,d} = CRF;
            allTrialsAllDurs_CRF_err(:,:,d) = CRF_err;
            %numTrialsEachConAllDurs_CRF(d,:) = numTrialsEachCon_CRF;

        end % end d loop
        
       % collect all pts all durs CRFs
       % c x trials x d x i:
       allTrialsAllPtsAllDurs_CRF(:,:,i) = allTrialsAllDurs_CRF;  
       allTrialsAllPtsAllDurs_CRF_err(:,:,:,i) = allTrialsAllDurs_CRF_err;
       %numTrialsEachConAllDursAllPts_CRF(:,:,i) = numTrialsEachConAllDurs_CRF;

    end % end i loop
    
    % save nth CRF matrix (all durs)
    % c x trials x d x i x n:
    allTrialsAllSessAllPtsAllDurs_CRF(:,:,:,n) = allTrialsAllPtsAllDurs_CRF;
    allTrialsAllSessAllPtsAllDurs_CRF_err(:,:,:,:,n) = allTrialsAllPtsAllDurs_CRF_err;
    %numTrialsEachConAllDursAllPtsAllSess_CRF(:,:,:,n) = numTrialsEachConAllDursAllPts_CRF;
    
end % end n loop

end