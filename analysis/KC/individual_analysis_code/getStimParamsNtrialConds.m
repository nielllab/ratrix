function [conOrderedByTrialMeetCriteria,uniqueContrasts,durOrderedByTrialMeetCriteria,uniqueDurations,conAndDurOrderedByTrialMeetCriteria] = getStimParamsNtrialConds(stimDetails,trialCond,idxOnsetsMeetsCriteria)
% This function takes in stim details, extracts stiim conditons, indexes
% into it w/trialCond to get stim conditions in order of presentation. Then
% slect for trials that met criteria in onsets step. Then make vector of
% unique contrasts & durations, for looping over. Outputs variables

    % VARS 4 FIGS - need indicies for trials that meet criteria, & list of
    % unique stim params

    % this part needed for any loops involving looping over CONTRAST:

    % extract contrast field values from stimDetails
    for i=1:length(stimDetails); % 1x # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
        con(i) = stimDetails(i).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
    end

    conOrderedByTrial = con(trialCond); % trial cond is all conditions ordered by trial..it is indicies for rows in stimDetail
    % in case: conOrderedByTrial = con(idxOnsetsMeetBothCriteria)
    conOrderedByTrialMeetCriteria = conOrderedByTrial(:,idxOnsetsMeetsCriteria); % select only the index that meet criters (done in a previos function)
    uniqueContrasts = unique(con); % vector with each unique contrast value, for looping over contrast values later

    % this part needed for any loops involving looping over DURATION:

    % extract duration field from stimDetails
    for i=1:length(stimDetails); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
        dur(i) = stimDetails(i).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
    end

    durOrderedByTrial = dur(trialCond); % index to get stim conditions in order of trial
    durOrderedByTrialMeetCriteria = durOrderedByTrial(:,idxOnsetsMeetsCriteria);
    uniqueDurations = unique(dur);

    % CON & DUR TOGETHER

    % putting together dur & con so that I can index into the trials in order w/trialCond
    conAndDur = [con; dur];
    % put it in order of trial presentation:
    conAndDurOrderedByTrial = conAndDur(:,trialCond); % gives 2 x #trials
    conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,idxOnsetsMeetsCriteria); 

end

