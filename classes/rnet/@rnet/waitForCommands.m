function cmd=waitForCommands(r,client,commands,priorities,timeout)
if isempty(priorities)
    ps=getSortedPrioritiesHighestFirst(r);
    priority=ps(end);
    priorities = repmat(priority,1,length(commands));
else
    for i=1:length(priorities)
        if ~isValidPriority(r,priorities(i))
            error('In waitForCommands(), invalid priority')
        end
    end
end
if ~all(size(commands)==size(priorities))
    error('In waitForCommands(), size of commands and priorities is different')
end
jCommands = javaArray('java.lang.Integer',length(commands));
jPriorities = javaArray('java.lang.Integer',length(commands));

for i=1:length(commands)
    jCommands(i) = java.lang.Integer(commands(i));
    jPriorities(i) = java.lang.Integer(priorities(i));
end

switch(r.type)
    case r.constants.nodeTypes.SERVER_TYPE
        jCmd=r.server.waitForCommands(client,jCommands,jPriorities,timeout);
    case r.constants.nodeTypes.CLIENT_TYPE
        jCmd=r.client.waitForCommands(jCommands,jPriorities,timeout);
    otherwise
        error('Invalid rnet type in waitForCommands()');
end

if ~isempty(jCmd)
    % Turn the command into a matlab object command
    'Got a valid command converting to rnetcommand()'
    cmd = rnetcommand(jCmd);
else
    cmd = [];
end