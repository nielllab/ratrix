% for each beh state,
% for each duration (only 1 tho),
% for each visual area, 
% take the mean df at each contrast across all mice (mean of mean)
% for each con, use t test to compare mean df between c = 0 and cth con
% collect in 1 x 7 output vector for each beh state

state = 'loRun'

visArea = 1;
durat = 1;
cont = 1; % max cont

% for each beh state, run this function, 
% then plot the outputs in seperate code

% ,groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria,groupPTSdfof,groupPeakFrameIdx,
% groupBaselineIdx,groupIdxStatTrials,groupIdxRunTrials,
% conAndDurOrderedByTrialMeetCriteria,uniqueContrasts,uniqueDurations

%%
function [mnCRF_acrossSess_AllDurAllPts_1behState] = mean_CRF_AcrossSessions(behState_allSessAllPtsAllDurs_CRF,visArea,durat,cont,)
% general CRF for 1 beh state ...

% our input variable has the mean CRF for each session in a group analysis
% for one state (ex: hi run speed state)
% 'behState_allSessAllPtsAllDurs_CRF' is durs x cons x pts x sess
% 'behState_allSessAllPtsAllDurs_CRF'is already state specific - no need
% for 'state' var input to this function
% we just need the mean df's to each con across sessions for this beh state

% for each duration (only 1 tho),
% for each visual area, 
% take the mean df at each contrast across all mice (mean of mean)

% getting the CRF across sessions for each duration and visual area
clear mnCRF_acrossSess_AllDurAllPts_1behState

clear d
for d = durat
    
    % for each new duration, we calulate a new visArea x contrast grid
    clear mnDthAllPtsCRF_acrossSess_1behState
    
    clear i
    for i = visArea
        
        % different mean group CRF for each visual area:
        mnDthIthCRF_acrossSess_1behState
        
        clear c
        for c = cont
            
            % take mean of df response to cth contrast, across sessions
            mnDF_acrossSess_dthIthCthCon_1behState = mean(squeeze(behState_allSessAllPtsAllDurs_CRF(d,c,i,:))');
            
        end % end c loop so that the collector variable doesnt re-write w/leadsing zeros each time]
        
        mnDthIthCRF_acrossSess_1behState(1,c)= mnDF_acrossSess_dthIthCthCon_1behState;
        
    end % end points loop
    
    % collect each 1 x contrast vectors into a visArea x contrast grid
    mnDthAllPtsCRF_acrossSess_1behState(visArea,:) = mnDthIthCRF_acrossSess_1behState;
    
end % end dur loop 

% collect each visArea x contrast grid into a cube w/duration as the 3rd
% dim
mnCRF_acrossSess_AllDurAllPts_1behState(:,:,durat) = mnDthAllPtsCRF_acrossSess_1behState;

end % end the function

