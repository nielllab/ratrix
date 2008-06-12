function reregstate = isClientReregistered(r,client)
reregstate = r.server.checkReconnectState(client);