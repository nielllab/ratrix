function quit=waitForAck(r,com,timeout,str)
[quit ackCom ackCmd ackArgs]=waitForSpecificCommand(r,getReceivingNode(com),r.constants.stationToServerCommands.C_CMD_ACK,timeout,sprintf('waiting for ACK: %s',str),[]);

if ~quit

    
    if any([isempty(ackCom) isempty(ackCmd) isempty(ackArgs)])
        str
        warning('timed out waiting for ack')
        quit=true;
    end

    if ~checkAck(r,com,ackCom)
        str
        warning('got ACK for wrong command')
        quit=true;
    end
end