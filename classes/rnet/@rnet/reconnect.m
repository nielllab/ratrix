function reconnect(r,timeout)
% reconnect to the server
% timeout - in milliseconds

% if no timeout is set, set it to zero
if ~exist('timeout','var')
    timeout = 0
end

switch r.type
    case r.constants.nodeTypes.SERVER_TYPE
        error('Server objects do not reconnect');
    case r.constants.nodeTypes.CLIENT_TYPE
        r.client.reconnect(timeout);
        thread = java.lang.Thread(r.client);
        thread.start();
    otherwise
        error('Unknown rnet type in reconnnect');
end