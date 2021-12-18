function [durOrderedByTrialMeetCriteria,uniqueDurations,conOrderedByTrialMeetCriteria,uniqueContrasts,conAndDurOrderedByTrialMeetCriteria] = getStimParams4loops(groupStimDetails,groupTrialCond,groupIdxOnsetsMeetsCriteria)
% gets unique durations & contrasts for the group analysis

    % NEED this for UNIQUE CONS & DURS for C & D loops:

    % EXTRACT stimDetails , trialCond, & idxOnsetsMeetCriteria
    % VARS from 1st SESSION in GROUP CELL ARRAYS
    clear n
    n = 1
    nthStimDetailsStruct = groupStimDetails{n};
    nthTrialCond = groupTrialCond{1,n};
    nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n};
    
    % CONTRAST calc's
    clear con
    clear conOrderedByTrial  
    clear conOrderedByTrialMeetCriteria 
    clear uniqueContrasts
    % extract contrast field from stimDetails
    clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
    for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
        con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
    end
    % order by trial, fileter for criteria, get unique list
    conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
    conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
    uniqueContrasts = unique(con); % for looping over contrast values later

    %  DURATION Calc's
    clear dur
    clear durOrderedByTrial  
    clear durOrderedByTrialMeetCriteria 
    clear uniqueDurations
    % extract duration field from stimDetails
    clear durs
    for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
        dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
    end
    % order by trial, filter for criteria, get unique list
    durOrderedByTrial = dur(nthTrialCond); 
    durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
    uniqueDurations = unique(dur);
    
    % CON & DUR TOGETHER
    clear conAndDur 
    clear conAndDurOrderedByTrial 
    clear conAndDurOrderedByTrialMeetCriteria
    conAndDur = [con; dur];
    conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
    conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);

end

