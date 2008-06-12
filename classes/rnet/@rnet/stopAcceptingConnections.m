function r=stopAcceptingConnections(r)
constants=r.constants;

switch r.type
    case r.constants.nodeTypes.SERVER_TYPE
        r.server.stopAcceptingNewConnections();
    case r.constants.nodeTypes.CLIENT_TYPE
        error('Only server types accept connections');
    otherwise
        error('Unknown rnet type in stopAcceptingConnections');
end
