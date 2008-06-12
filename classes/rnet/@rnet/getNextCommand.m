function cmd = getNextCommand(r,client,priority)

ps=getSortedPrioritiesHighestFirst(r);
if exist('priority','var')
    if ~isValidPriority(r,priority)
        error('invalid priority')
    end
else
    priority=ps(end);
end

if ~exist('client','var')
    client=[];
end

cmd=[];
for p=1:length(ps)
    if isSameOrHigherPriority(r,ps(p),priority) && commandsAvailable(r,ps(p),client)
        cmd=checkForSpecificPriority(r,client,ps(p));
        break;
    end
end

% if r.type == r.constants.SERVER_TYPE
%     if ~exist('client','var')
%         cmd = r.server.getNextCommand();
%     else
%         cmd = r.server.getNextCommand(client);
%     end
% elseif r.type == r.constants.CLIENT_TYPE
%     cmd = r.client.getNextCommand();
% end

if isempty(cmd)
    %error('no command available')
    %now this is expected behavior
else
    % Turn the command into a matlab object command
    cmd = rnetcommand(cmd);
end