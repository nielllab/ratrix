function gotAck = startClientTrials(datanet,subjectID,protocol)
% This function sends a command to the client to set the correct datanet_storepath (for stimRecords) and then 
% to start running trials, and waits for an ack.
% INPUTS:
%	datanet - the server-side datanet object; should have a valid pnet connection with parameters (timeout) already set
%	subjectID - the ID string of the subject to start (pass to standAloneRun)
%	protocol - the name of the protocol file to run (pass to standAloneRun)
% OUTPUTS:
%	gotAck - true if we get an ack from the client

% tell client computer to start running trials and send an ack
gotAck = false;
constants=getConstants(datanet);

commands=[];
commands.cmd=constants.dataToStimCommands.D_SET_STOREPATH_CMD;
params=[];
params.storepath=getStorePath(datanet);
commands.arg=params;
gotAck = sendCommandAndWaitForAck(datanet,commands);


commands=[];
commands.cmd=constants.dataToStimCommands.D_START_TRIALS_CMD;
subjParams=[];
subjParams.id=subjectID;
subjParams.protocol=protocol;
commands.arg=subjParams;
gotAck = sendCommandAndWaitForAck(datanet,commands);

end % end function