function bool = resetRequested(r)
if r.type == r.constants.nodeTypes.SERVER_TYPE
    bool = r.server.resetRequested();
else
    error('Can only check reset request on server');
end