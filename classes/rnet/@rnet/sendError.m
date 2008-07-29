function quit=sendError(r,com,errType,errMsg)
if isValidError(r,errType)
    fprintf('%s: sending error to server: %s\n',datestr(now),errMsg)
    quit=sendToServer(r,getReceivingNode(com),r.constants.priorities.IMMEDIATE_PRIORITY,r.constants.stationToServerCommands.C_CMD_ERR,{errType,errMsg});
    %used to be MESSAGE_RECEIPTS_PRIORITY, but then errors don't make it through waitForSpecific
else
    error('bad errType')
end