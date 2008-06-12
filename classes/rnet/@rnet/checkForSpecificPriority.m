function cmd=checkForSpecificPriority(r,client,priority)

cmd=[];

switch r.type
    case r.constants.nodeTypes.SERVER_TYPE
        if isempty(client)
            cmd = r.server.checkForSpecificPriority(priority);
        else
            cmd = r.server.checkForSpecificPriority(client,priority);
        end
    case r.constants.nodeTypes.CLIENT_TYPE
        cmd = r.client.checkForSpecificPriority(priority);
    otherwise
        error('bad rnet node type')
end

if ~isempty(cmd)
    % Turn the command into a matlab object command
    cmd = rnetcommand(cmd);
end