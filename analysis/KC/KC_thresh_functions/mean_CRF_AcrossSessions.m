function [mnCRF_acrossSess_AllDurAllPts_1behState] = mean_CRF_AcrossSessions(behState_allSessAllPtsAllDurs_CRF,visArea,durat,cont)

% this functions returns the mean CRF across all sessions for all durs & points, for 1 beh state 

% our input variable has the mean CRF for each session, for one beh state (ex: hi run speed state)
% 'behState_allSessAllPtsAllDurs_CRF' is durs x cons x pts x sess
% 'behState_allSessAllPtsAllDurs_CRF'is already state specific - no need for 'state' var input to this function
% we just need the mean df's to each con across sessions for this beh state

% for each duration (only 1 tho),
% for each visual area, 
% take the mean df at each contrast across all mice (mean of mean CRF per session)

% var to store mean CRF across sessions, for each duration and visual area, for 1 behavioral state:
% visArea x contrast x duration


clear mnCRF_acrossSess_AllDurAllPts_1behState

clear d
for d = durat

    % for each new duration, we calulate a new visArea x contrast grid
    clear mnDthAllPtsCRF_acrossSess_1behState

    clear i
    for i = visArea

        % different mean group CRF for each visual area:
        clear mnDthIthCRF_acrossSess_1behState

        clear c
        for c = cont

            % take mean of df response to cth contrast, across sessions
            mnDF_acrossSess_dthIthCthCon_1behState = mean(squeeze(behState_allSessAllPtsAllDurs_CRF(d,c,i,:))');
            
            % collect each mean df for each con
            mnDthIthCRF_acrossSess_1behState(1,c)= mnDF_acrossSess_dthIthCthCon_1behState;

        end % end c loop 
        
        % collect each 1 x contrast vectors into a visArea x contrast grid
        mnDthAllPtsCRF_acrossSess_1behState(i,:) = mnDthIthCRF_acrossSess_1behState;

    end % end points loop
    
        % collect each visArea x contrast grid into a cube w/duration as the 3rd
        % dim
        mnCRF_acrossSess_AllDurAllPts_1behState(:,:,durat) = mnDthAllPtsCRF_acrossSess_1behState;

end % end dur loop 

end % end the function

