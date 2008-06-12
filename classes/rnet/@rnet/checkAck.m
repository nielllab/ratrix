function valid = checkAck(r,sentCommand,response)
% Determine if the response is an acknowledgement of the sent command
valid=false;

[good cmd args]=validateCommand(r,response);
if good
    if cmd ~= r.constants.stationToServerCommands.C_CMD_ACK
        error('Response is not an acknowledgement, but it was checked sent to checkAck()');
    else
        ackUID = args{1};
        sentUID = getUID(sentCommand);
        if(ackUID == sentUID)
            valid = true;
        end
    end
end