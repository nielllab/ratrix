function [trialData, gotAck] = sendCommandAndWaitForAck(datanet, stimcon, commands)
% this function sends a command to the data machine and waits for an ack
% commands must be a struct that contains these fields:
%   cmd - type double: choose from datanet.constants
%   [optional] arg - type char: filename to save to given the r.constants.stimToDataCommands.S_SEND_DATA_CMD
%                  - type double: ai_parameters

MAXSIZE = 1024*1024;
CMDSIZE = 1;
trialData = [];
% getDataFromFile = false; % flag to determine if we need to load from file for certain commands
% if strmatch(datanet.type, 'data')
%     error('must be called on datanet of type ''stim''');
% end

if isstruct(commands)
    % cmd
    if isfield(commands,'cmd') && isscalar(commands.cmd)
        pnet(stimcon,'write', commands.cmd);
        fprintf('writing command %d\n', commands.cmd);
    elseif iscell(commands.cmd) % if cmd is a cell of variables - could be anything, so use putvar and getvar
        pnet_putvar(stimcon, commands.cmd);
    else
        error('unsupported cmd type - must be constant or cell array');
    end
    % args
    if isfield(commands,'arg')
        if ischar(commands.arg)
            pnet(stimcon,'write',commands.arg);
            fprintf('writing arg %s\n', commands.arg);
        elseif isnumeric(commands.arg)
            pnet(stimcon,'write',commands.arg);
            fprintf('writing arg %s\n', commands.arg);
        elseif isstruct(commands.arg) % a struct - use putvar
            pnet_putvar(stimcon, commands.arg);
            fprintf('using putvar for arg\n');
        else
            error('args must be a char or number array');
        end
    end
else
    error('commands must be a struct');
end
    

% wait for acknowledgement from data computer that connection was received
gotAck = false;
constants = getConstants(datanet);
while ~gotAck
    % need a switch here depending on commands.cmd
    % most cases, just do the below,
    % but in case we need to use a pnet_getvar, this has to come BEFORE any
    % pnet('read') ops b/c pnet works that way dammit
    % for now, whenever commands.cmd==4 (getting neural events data)
    if ismember(commands.cmd, constants.pnetGetvarCommands) % getting neural events
        disp('trying pnet_getvar to get neural events');
        trialData=pnet_getvar(stimcon);
    end
    received = pnet(stimcon,'read',MAXSIZE,'double','noblock');
    if ~isempty(received) % if we received something from data computer (ack or fail)
        disp('received something')
        received
        receivedIsAck = isAck(datanet,received,constants);
        if receivedIsAck
            gotAck = true; 
            % try using pnet_getvar
            % this needs to be done using a switch on the commands.cmd field
            % (only should be done in certain cases)
            % b/c this depends on what kind of ack you expect to get back

            % try to load from file if getDataFromFile is set
%             if getDataFromFile
%                 t = GetSecs();
%                 load(fullfile(datanet.storepath,commands.arg));
%                 timeToLoad = GetSecs() - t;
%                 fprintf('took %d seconds to load file\n',timeToLoad);
%             end
        elseif ~isempty(received) % received is not empty but it is not an ack - must be trialData
            trialData = received;
            gotAck = true;
            disp('reading received first time')
            % if we didn't finish reading - because pnet('read') has a maxsize limit of stuff it can read
            while ~isempty(received)
                disp('reading received again')
                received = pnet(stimcon,'read',MAXSIZE,'double','noblock');
                trialData = [trialData received];
            end
        else
            error('if received isnt empty and isnt an ack, then what is it?');
        end
    else % didnt receive anything yet, so keep listening

    end
end


end % end function



% =====================================================================================
function ack = isAck(datanet,data,constants)
% this subfunction determines if the value returned from data is a success
% acknowledgement (based on constants.dataToStimResponses)
ack = false;
responses = fields(constants.dataToStimResponses);
for i=1:length(responses)
    if data == constants.dataToStimResponses.(responses{i})
        ack = true;
    end
end

end % end function