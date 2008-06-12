function removeAllDisconnectedClients(r)
% Attempt to disconnect all clients
clients = listClients(r);
for i=1:length(clients)
    if ~isConnected(r,clients(i))
        removeDisconnectedClient(r,clients(i));
    end
end