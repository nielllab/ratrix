function [datanet quit retval] = handleCommands(datanet,params)
% This function gets called by the client's bootstrap function, and also at the doTrial/runRealTimeLoop level to handle any available
% server commands. also gets called during physiologyServer's doServerIteration (to handle any commands sent from ratrix side)
% INPUTS:
%	datanet - a datanet object (either stim or data)
%   params - a struct containing additional information that may be needed to process commands
%       for now, this is a timestamp that was taken during 'trial start' and passed to 'trial end' for serverHandleCommand
% OUTPUTS:
%	quit - a quit flag (not sure if this will be doTrial's stopEarly or realtimeloop's quit), but something to tell ratrix to stop running trials!
%	retval - some return value (in the case of doServerIteration, should be an event to add to events_data), may be other stuff....

quit = false;
retval=[];
ret=[];
CMDSIZE=1;
commandAvailable=false;
specificCommand=[];

% ===================================================
type=datanet.type;
cmdCon=getCmdCon(datanet);
ackCon=getAckCon(datanet);

% ===================================================
% try to get the first available command
try
	cmd=pnet(cmdCon,'read',CMDSIZE,'double','noblock');
	if isempty(cmd) % no commands available, so just return
%         fprintf('no commands found!\n')
		return;
	else
		commandAvailable=true;
        fprintf('we found a command (%d)!\n',cmd)
	end
catch ex
    keyboard
	disp(['CAUGHT ER: ' getReport(ex)]);
    % do some cleanup here
end

% ===================================================
% now loop while commandAvailable and use a switch statement on possible cmds received
try
	while commandAvailable && ~quit
		success=false;
		if ~isempty(specificCommand) && cmd~=specificCommand
			error('received a faulty command %d when waiting for the specific command %d',cmd,specificCommand);
		end
		
		if strcmp(type,'stim')
			[datanet quit specificCommand response] = clientHandleCommand(datanet, cmdCon, cmd, specificCommand, params);
		else
			[quit specificCommand response ret] = serverHandleCommand(datanet, cmdCon, cmd, specificCommand, params);
		end
		
		% this means only one retval per server iteration for now...how to fix?
		if ~isempty(ret)
            if isempty(retval)
                retval=ret;
            else
                retval(end+1)=ret;
            end
		end
		
		% give a response (usually an ack)
		if ~isempty(response)
            fprintf('writing response %d\n',response)
			pnet(ackCon,'write',response);
		end
		
		if quit
			return
		end
		
		% now check to see if another command is available
		cmd=pnet(cmdCon,'read',CMDSIZE,'double','noblock');
		if isempty(cmd) % no commands available, so just return
			return;
		else
			commandAvailable=true;
		end
	end
catch ex
	disp(['CAUGHT ER (at handleCommands): ' getReport(ex)]);
    rethrow(ex);
    % do some cleanup here
end


end % end function
