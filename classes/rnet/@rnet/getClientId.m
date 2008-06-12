function id = getClientId(r)
if r.type==r.constants.nodeTypes.CLIENT_TYPE
    id=r.client.getClientId();
else
    error('Only client type should ask for their own client id');
end