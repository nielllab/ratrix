function [datanet gotAck] = setStorePath(datanet, stimcon, path)
% this function sets the storepath field of both the data and stim datanet objects to the input 'path'

if ~ischar(path)
    error('path must be a string')
end
constants = getConstants(datanet);

datanet.storepath = path; % set local storepath
% now send command to data process to set same storepath
commands=[];
commands.cmd = constants.stimToDataCommands.S_SET_STOREPATH_CMD;
commands.arg = path;

[trialData, gotAck] = sendCommandAndWaitForAck(datanet, stimcon, commands);

end %end function
