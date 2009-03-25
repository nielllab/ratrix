function datanet = stop(datanet)
% this function takes in a datanet with a con (connection) and stops recording, and shuts down the data listener
% and starts recording from NIDAQ

gotAck = 0;

% stop recording
commands=[];
constants = getConstants(datanet);
commands.cmd = constants.stimToDataCommands.S_STOP_RECORDING_CMD;
[trialData, gotAck] = sendCommandAndWaitForAck(datanet, datanet.con, commands);
if ~gotAck
    error('error in stopping datanet - stop recording failed to receive ack');
end
% shutdown
commands=[];
commands.cmd = constants.stimToDataCommands.S_SHUTDOWN_CMD;
[trialData, gotAck] = sendCommandAndWaitForAck(datanet, datanet.con, commands);
if ~gotAck
    error('error in stopping datanet - shutdown failed to receive ack');
end
pnet('closeall');

datanet.con=[];
datanet.sockcon=[];
    
end % end function