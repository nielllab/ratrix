function [stimOnsets] = onsetsOfStimEachTrialTimestamps(allStop,allResp)
% % SELECT ONSET FRAME CHUNKS
% for each trial, get the timestamp for the monitor frame when the stimulus first came on (rows in allresp.frameT) 
% and set the time relative to first frame of first trial (which is the very first monitor frame of the recording session)
% time stamps are in seconds. monitor displays at 60 Hz.

    % making stimulus onset times relative to 1st frame of 1st trial
    clear stimOnsets

    % take the first frame after "the mouse stops" for the FIRST time 
    % (1st trial onset becomes t = 0 for monitor time)
    t0 = allStop(1).frameT(1); % 1st frame for 1st trial 

    clear i 
    for i = 1:length(allResp) % I think response period is when the stim comes on until mouse answers
        % get the first frame after the stimulus comes on, subtract
        % t0, the time of the first trial onset. 
        stimOnsets(i) = allResp(i).frameT(1)-t0; % onsets is in seconds

    end % now you have the timestamps of the first frames during the resposne/stimulus presetation period for 
    % each trial, relative to when the very FIRST trial started

    sizeOfOnsets = size(stimOnsets)

end

