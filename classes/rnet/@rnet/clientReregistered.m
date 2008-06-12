function reregstate = clientReregistered(r,client)
reregstate = r.server.checkAndResetReconnectState(client);