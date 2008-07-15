function id = getClientIdent(r)
if r.type==r.constants.nodeTypes.CLIENT_TYPE
    id=r.client.getLocalNodeId();
else
    error('Only client type should ask for their own client id');
end