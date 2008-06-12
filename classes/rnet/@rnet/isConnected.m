function status = isConnected(r,client)
if r.type==r.constants.nodeTypes.CLIENT_TYPE
    status = r.client.isConnected();
elseif r.type==r.constants.nodeTypes.SERVER_TYPE
    status = r.server.clientIsConnected(client);
else
    error('isConnected(): Unknown node type');    
end
