function quit=sendAcknowledge(r,com)
    quit=sendToServer(r,getClientIdent(com),r.constants.priorities.MESSAGE_RECEIPTS_PRIORITY,r.constants.stationToServerCommands.C_CMD_ACK,{getUID(com)});