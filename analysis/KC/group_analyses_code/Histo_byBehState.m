function [allSess_allConsAllPtsAllDurs_pkDfEachTrial] = Histo_byBehState(nGroup,state,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria,groupPTSdfof,groupPeakFrameIdx,groupBaselineIdx,groupIdxStatTrials,groupIdxRunTrials,groupIdxLargePupilTrials,groupIdxSmallPupilTrials,visArea,durat,cont,conAndDurOrderedByTrialMeetCriteria,uniqueContrasts,uniqueDurations)
% general CRF for 1 beh state ...

%clear allSess_allConsAllPtsAllDurs_pkDfEachTrial 

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
    
    clear allSess_dthIthAllCons_pkDfEachTrial % b/4 each new group analysis,
    % clear struct that holds pk df values for each trial at each con 

    % clear nth all cons struct before each new dur/session
    clear allConsAllPtsAllDurs_pkDfEachTrial

    clear d  % for each duration
    for d = durat % duration variable 

        clear dthAllConsAllPts_pkDfEachTrial

        % for one POINT
        clear i  
        for i = visArea

            clear c % for each contrast
            for c = cont

                % SELECT TRIALS for specified pupil state & stim params
                [idxTrials] = getTrials(conAndDurOrderedByTrialMeetCriteria,c,d,uniqueContrasts,uniqueDurations,nthIdxBehStateTrials);

                % GET DFof for PEAK FRAMES

                % take df/f data for ith pt, peak frames, cth dth stat trials
                allPeakFramesNthDthIthCthCon_allTrials = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxTrials)); 
                meanDfPeakFramesNthDthIthCthCon_allTrials = mean(allPeakFramesNthDthIthCthCon_allTrials,1); % gives 1 x #trials

                % get BASELINE for nth sess, ith point, dth cth state trials
                clear allBaselineFrames
                allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxTrials));
                % get one mean baseline value over all frames & trials
                meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
                meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials

                % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
                meanPeakFramesCthDthTrialsIthPtMinusBase = meanDfPeakFramesNthDthIthCthCon_allTrials-meanBaselineFrames;
                % ^this is a 1 x # trials vector
                % rename:
                clear dthIthCthCon_pkDfEachTrial
                dthIthCthCon_pkDfEachTrial = meanPeakFramesCthDthTrialsIthPtMinusBase;

                % collect trial vectors (diff num trials each contrast & session) in struct array
                dthIthAllCons_pkDfEachTrial{1,c} = dthIthCthCon_pkDfEachTrial;
               
            end % end c loop - move to next contrast/subplot
            
            % collect for all pts
            dthAllConsAllPts_pkDfEachTrial{1,i} = dthIthAllCons_pkDfEachTrial;
                    
        end % end i loop (only 1 point
        
        % colelct for all durs
        allConsAllPtsAllDurs_pkDfEachTrial{1,d} = dthAllConsAllPts_pkDfEachTrial;
        
    end % end d loop (only 1 dur)

% for each session, store the struct w/ pk df for each trial at every con inside another struct
allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n} = allConsAllPtsAllDurs_pkDfEachTrial;
                    
end % end n loop

end



