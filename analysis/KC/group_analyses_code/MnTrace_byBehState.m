function [mnTraceAllConsDursPts] = MnTrace_byBehState(nGroup,state,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria,groupPTSdfof,groupPeakFrameIdx,groupBaselineIdx,groupIdxStatTrials,groupIdxRunTrials,groupIdxSmallPupilTrials,groupIdxLargePupilTrials,visArea,durat,cont,conAndDurOrderedByTrialMeetCriteria,uniqueContrasts,uniqueDurations)

clear mnTraceAllConsDursPtsSess % start new group matrix each time

% for each session
clear n
for n = 1:nGroup
    
    clear mnTraceAllConsDursPts % re-use pts collector

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
    
    % for each area
    clear i
    for i = visArea % can be 1 area or length of xPts
        
        clear mnTraceAllConsDurs % reuse durs collectot
              
        % for each duration
        clear d
        for d = durat % at each duration
            
            clear mnTraceAllCons % reuse cons collector
            
            % for each contrast
            clear c
            for c = cont 

                % SELECT TRIALS for specified pupil state & stim params
                [idxTrials] = getTrials(conAndDurOrderedByTrialMeetCriteria,c,d,uniqueContrasts,uniqueDurations,nthIdxBehStateTrials);
                
                % INDEX ALL FRAMES of SELECTED TRIALS in PTSDFOF, retunrs 1 x #frames
                mnTrace = mean(squeeze(nthPTSdfof(i,:,idxTrials)),2)';
                
                % BASELINE
                % mean over trials
                baselineFramesTrace = mean(squeeze(nthPTSdfof(i,nthBaselineIdx,idxTrials)),2)';
                % mean over frames
                baselineFramesTrace = mean(baselineFramesTrace,2);
                
                % do BASEline CORRECTION
                baselinedMnTrace = mnTrace-baselineFramesTrace;
                
                % COLLECT MEAN TRACE for each CONTRAST
                mnTraceAllCons(c,:) = baselinedMnTrace;
                
                % STDERR
                % calulate the StdErr for each CRF point calulated above (one err value for each contrast)
                % that means I want the error over trials, not over frames - that info is in the 'meanOverFramesSq5FramesOverTrialsPTSdfof' variable (1 x # trials)
                %clear stdErr
                %stdErr = std(squeeze(nthPTSdfof(i,:,idxTrials))')/sqrt(length(idxTrials)); % check: length or sum?
                %%CRF_err(1,c) = stdErr; % clear outside j loop
                
                %numTrials = length(idxTrials);
                %numTrialsEachCon_CRF(1,numTrials) = numTrials;
                
            end % end c loop
            
            mnTraceAllConsDurs(:,:,d) = mnTraceAllCons;
            
            % collect CRF & err for each duration
            %allDurs_CRF(d,:) = CRF;
            %allDurs_CRF_err(d,:) = CRF_err;
            %numTrialsEachConAllDurs_CRF(d,:) = numTrialsEachCon_CRF;

        end % end d loop
        
        mnTraceAllConsDursPts(:,:,:,i) = mnTraceAllConsDurs;
        
       % collect all pts all durs CRFs
       %allPtsAllDurs_CRF(:,:,i) = allDurs_CRF;  
       %allPtsAllDurs_CRF_err(:,:,i) = allDurs_CRF_err;
       %numTrialsEachConAllDursAllPts_CRF(:,:,i) = numTrialsEachConAllDurs_CRF;

    end % end i loop
    
    % con x frames x dur x points x sessions
    mnTraceAllConsDursPts(:,:,:,:,n) = mnTraceAllConsDursPts;
    % save nth CRF matrix (all durs)
    %allSessAllPtsAllDurs_CRF(:,:,:,n) = allPtsAllDurs_CRF;
    %allSessAllPtsAllDurs_CRF_err(:,:,:,n) = allPtsAllDurs_CRF_err;
    %numTrialsEachConAllDursAllPtsAllSess_CRF(:,:,:,n) = numTrialsEachConAllDursAllPts_CRF;
    
    %stdErr = std(squeeze(nthPTSdfof(i,:,idxTrials))')/sqrt(length(idxTrials))
    
end % end n loop

end

