function clients = listClients(r)
clients = [];
listClients = r.server.listClients();
iterClients = listClients.iterator();
while iterClients.hasNext()
    client = iterClients.next();
    clients = [clients client];
end
