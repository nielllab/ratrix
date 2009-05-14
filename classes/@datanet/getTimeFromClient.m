function t = getTimeFromClient(d)
% gets a timestamp from the client using pnet
constants=getConstants(d);

commands=[];
commands.cmd=constants.dataToStimCommands.D_GET_TIME_CMD;
[gotAck t] = sendCommandAndWaitForAck(d,commands);

end % end function