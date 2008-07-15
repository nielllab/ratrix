function quit=sendAcknowledge(r,com)
    quit=sendToServer(r,getReceivingNode(com),r.constants.priorities.MESSAGE_RECEIPTS_PRIORITY,r.constants.stationToServerCommands.C_CMD_ACK,{getUID(com)});