function [idxOnsetsMeetsCriteria,filteredStimOnsets] = filterOnsets_removeEarlyAndLateTrials(stimOnsets,earliestTrial,numLateTrialsSubtract)
% This function filters out the first and last few trials, which takes care
% of a coding error I don't feel like explaining right now...
% There is also a block of code in here that you can uncomment if the
% imaging session stopped before the stimulus or vice versa. 
% earliestTrial & numLateTrialsSubtract are defined in the meta script

    % % let's remove the 1st & last 5 trials

    % get filtered trials indicies *before* you re-define onsets, b/c we need these to index 
    clear idxOnsetsMeetsCriteria
    idxOnsetsMeetsCriteria = [earliestTrial:length(stimOnsets)-numLateTrialsSubtract]; % remove 1st & last 5 trials, because they can cause an error in the code...

    % redefineOnsets
    filteredStimOnsets = stimOnsets(1,idxOnsetsMeetsCriteria); % if I remove enough beginning & end trials & 
    % if I have my num post stim frames at 10 or less I will not have to change idx that meet
    % criteria b/c I won't have any issues w/onset chunks from dfCROP
    
    sizeOnsetsMeetCriteria = size(filteredStimOnsets)

    % % % for sessions where frameT stops before stim ONLY
    % realNumTrials = 1941;  % don't know any other way to figure out how other
    % % than running onsetFrame code, getting the error to figure out where it stops 
    % % then changing this value manually.. 
    % % get indicies *before* you re-define onsets, b/c we need these to pick 
    % % from the list of all trials later
    % idxOnsetsMeetsCriteria = [60:realNumTrials-1];
    % % remove beginning or end trials that you need to
    % onsets = onsets(1,idxOnsetsMeetsCriteria); % if I remove enough beginning & end trials & 
    % % if I have my num post stim frames at 10 or less I will not have to change idx that meet
    % % criteria b/c I won't have any issues w/onset chunks from dfCROP
    % sizeOnsetsMeetCriteria = size(onsets)

end

