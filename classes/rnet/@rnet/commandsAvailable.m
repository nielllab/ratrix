function numCommands = commandsAvailable(r,priority,client)

import rlab.net.*;


if ~exist('priority','var') || isempty(priority)
    %     if r.type == r.constants.SERVER_TYPE
    %         if ~exist('client','var') || isempty(client)
    %             numCommands = r.server.incomingCommandsAvailable();
    %         else
    %             numCommands = r.server.incomingCommandsAvailable(client);
    %         end
    %     elseif r.type == r.constants.CLIENT_TYPE
    %         numCommands = r.client.commandsAvailable();
    %     else
    %         error('Unknown rnet.type value');
    %     end

    switch r.type
        case r.constants.nodeTypes.SERVER_TYPE
            if ~exist('client','var') || isempty(client)
                numCommands = r.server.incomingCommandsAvailable();
            else
                numCommands = r.server.incomingCommandsAvailable(client);
            end
        case r.constants.nodeTypes.CLIENT_TYPE
            numCommands = r.client.incomingCommandsAvailable();
        otherwise
            error('Unknown rnet.type value');
    end

else
    %     if r.type == r.constants.SERVER_TYPE
    %         if ~exist('client','var') || isempty(client)
    %             %class(priority)
    %             numCommands = r.server.incomingCommandsAvailable(priority);
    %         else
    %             numCommands = r.server.incomingCommandsAvailable(client,priority);
    %         end
    %     elseif r.type == r.constants.CLIENT_TYPE
    %         numCommands = r.client.commandsAvailable(priority);
    %     else
    %         error('Unknown rnet.type value');
    %     end

    switch r.type
        case r.constants.nodeTypes.SERVER_TYPE
            if ~exist('client','var') || isempty(client)
                numCommands = r.server.incomingCommandsAvailable(priority);
            else
                numCommands = r.server.incomingCommandsAvailable(client,priority);
            end
        case r.constants.nodeTypes.CLIENT_TYPE
            numCommands = r.client.incomingCommandsAvailable(priority);
        otherwise
            error('Unknown rnet.type value');
    end

end


