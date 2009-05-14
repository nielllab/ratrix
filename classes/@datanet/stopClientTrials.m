function [gotAck retval] = stopClientTrials(datanet,subjectID,params)
% This function sends a command to the client to stop running trials, and waits for an ack.
% INPUTS:
%	datanet - the server-side datanet object; should have a valid pnet connection with parameters (timeout) already set
%	subjectID - the ID string of the subject to start
%		(pass to station.doTrials or whoever sets quit on ratrix side - just to make sure this is the correct subject to stop)
%   params - the struct of params that includes the ai object so we can get the last trial's data
% OUTPUTS:
%	gotAck - true if we get an ack from the client
%   retval - the event returned by handleCommands on the last trial's TRIAL_END_EVENT_CMD

% tell client computer to stop running trials and send an ack
gotAck = false;
constants=getConstants(datanet);

commands=[];
commands.cmd=constants.dataToStimCommands.D_STOP_TRIALS_CMD;
subjParams=[];
subjParams.id=subjectID;
commands.arg=subjParams;

gotAck = sendCommandAndWaitForAck(datanet,commands);

% now wait for this last trial's TRIAL_END_EVENT_CMD from client and save last neuralRecord
retval=[];
while isempty(retval) % wait until we get something from handling tm.doTrial's call to save neuralData
    [garbage quit retval] = handleCommands(datanet,params);
end

% now wait for the END_OF_DOTRIALS omni-message which gets sent after doTrials finishes in clientHandleCommand 
% (to indicate that client finished executing doTrials)
gotAck = sendCommandAndWaitForAck(datanet,[]);


end % end function