function [onsetDf_allConsDurs] = pixWiseByState(cont,durat,groupIdxSmallPupilTrials,groupIdxLargePupilTrials,groupIdxStatTrials,groupIdxRunTrials,state,groupStimOnsetFrame,groupOnsetDf,groupBaselineIdx,nGroup,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria)
clear mnBaselinedOnsetDf_allConsDurs

% for each session
clear n
for n = 1:nGroup
    
    %clear mnBaselinedOnsetDf_allConsDurs % re-use dur collector

    % EXTRACT list of stim params & stim conditions in order of trial 
    [durOrderedByTrialMeetCriteria,uniqueDurations,conOrderedByTrialMeetCriteria,uniqueContrasts,conAndDurOrderedByTrialMeetCriteria] = getStimParams4loops(n,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria);
    
    % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
    nthOnsetDf = groupOnsetDf{1,n};
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
            
    clear mnBaselinedOnsetDf_allCons % reuse cons collector
          
    % for each duration
    clear d
    for d = durat % at each duration
        
        clear nthMnBaselinedOnsetDf % reuse frames collector
        
        % for each contrast
        clear c
        for c = cont 

            % SELECT TRIALS for specified pupil state & stim params
            [idxTrials] = getTrials(conAndDurOrderedByTrialMeetCriteria,c,d,uniqueContrasts,uniqueDurations,nthIdxBehStateTrials);
                      
            % for each peri-frame, plot pix wise image for selected trials
            clear f
            %for f = 1:size(onsetDf,3); % need to use size here cuz longest dim is trials, not frames for onsetDf 
            % STIM ONSET FRAME SHOULD BE SAME W/IN EACH SESSION
            % 3rd DIM ONSET DF SAME IN EACH SESS (pix x pix x frames x trials)
            for f = groupStimOnsetFrame{1}+1:size(groupOnsetDf{1},3)-3 % stim onset til end of onsetDf segment
                
                % CALCULATE MEAN BASELINE IMAGE
                    
                % get baseline frames, across all points, selected trials
                clear allBaselineFrames
                nthAllBaselineFrames = nthOnsetDf(:,:,nthBaselineIdx,idxTrials);
                
                % take mean over frames for baseline frames of selected trials
                clear meanBaselineFrames
                nthMnBaselineFrames = mean(nthAllBaselineFrames,3); % 3rd dim is frames
                nthMnBaselineFrames = squeeze(nthMnBaselineFrames);
            
                % average over trials
                clear meanBaselineImage
                nthMnBaselineImage = mean(nthMnBaselineFrames,3); % this is the "mean baseline image"
                
                % baseline here - subtract mean baseline image from each frames
                nthMnBaselinedOnsetDf_oneFrame = mean(nthOnsetDf(:,:,f,idxTrials),4)-nthMnBaselineImage;
        
                % collect each baselined frame 
                nthMnBaselinedOnsetDf(:,:,f) = nthMnBaselinedOnsetDf_oneFrame;
                
            end % end frames loop
            
            % collect baselined nthOnsetDf for each contrast in nth session 
            mnBaselinedOnsetDf_allCons(:,:,:,c) = nthMnBaselinedOnsetDf;
        
        end % end c loop
        
        % Q; why no dur if dur = 1?
        % collect for dur
        mnBaselinedOnsetDf_allConsDurs(:,:,:,:,d) = mnBaselinedOnsetDf_allCons;

    end % end d loop
    
end % end n loop

onsetDf_allConsDurs = mnBaselinedOnsetDf_allConsDurs;

end

