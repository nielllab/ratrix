function [trialData gotAck] = getTrialData(datanet, stimcon, filename)
% this function gets data from the data process using the given filename as the file to save/load in the defined datanet.storepath
% calls sendCommandAndWaitForAck with the command to send data, and then loads data from file

if ~ischar(filename)
    error('filename must be a string')
end
constants = getConstants(datanet);

% format of filename
% startTrial = 1; % >> Replace with the trialnumber that we started with
% endTrial = 5; % >> Replace with the trialnumber that we ended on
% filename = sprintf('neuralRecords_%d_%d_%s.mat', startTrial, endTrial, datestr(now,30));

% now send command to data process to send data
commands=[];
commands.cmd = constants.stimToDataCommands.S_SAVE_DATA_CMD;
commands.arg = filename;

[trialData, gotAck] = sendCommandAndWaitForAck(datanet, stimcon, commands);
% now load from filename
load(fullfile(datanet.storepath, filename));

end %end function
