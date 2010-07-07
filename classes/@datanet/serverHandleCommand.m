function [quit specificCommand response retval] = serverHandleCommand(datanet,con,cmd,specificCommand,params)
% This function gets called by handleCommands, which loops through available commands. This function just does the switch statement on cmd
% and decides what to execute on the data (server) side.
% INPUTS:
%	datanet - the server-side datanet object; should already have a pnet connection with proper timeouts set
%	cmd - the command from the server side to handle
%	specificCommand - if nonempty, a specificCommand that is expected by the client (set during handleCommands by previous call to serverHandleCommand)
%   params - a struct containing additional parameters passed from handleCommands
% OUTPUTS:
%	quit - not sure what this quit flag means just yet...
%	specificCommand - return to handleCommands if the current cmd requires a specific command be the next in line
%	response - a response message to send to the client (usually an ack)
%	retval - something from the client that needs to be saved by the server (typically an element of events_data)

quit = false;
constants = getConstants(datanet);
response = [];
retval=[];
MAXSIZE=1024*1024;
CMDSIZE=1;

% ===================================================
if strmatch(datanet.type, 'stim')
    error('must be called on datanet of type ''data''');
end

% ===================================================
try
	success=false;
	if ~isempty(specificCommand) && cmd~=specificCommand
		error('received a faulty command %d when waiting for the specific command %d',cmd,specificCommand);
	end
	switch cmd
		case constants.stimToDataCommands.S_TRIAL_START_EVENT_CMD
			% mark start of trial - how do we add an event to events_data, which is all the way out in physiologyServer?
			response=constants.dataToStimResponses.D_TRIAL_START_EVENT_ACK;
            retval(end+1).type='trial start';
            if ~isempty(params.ai)
                flushdata(params.ai);
            end
			
			% create the neuralRecords file with that will get appended to by physServer in 30sec chunks
			cparams=pnet_getvar(con);
            retval(end).time=cparams.time; % should also have a timestamp from client
			filename=cparams.neuralFilename;
			fullFilename = fullfile(datanet.storepath, 'neuralRecords', filename);
            if ~isempty(params.ai)
                samplingRate=params.samplingRate;
                save(fullFilename, 'samplingRate');
            end
			retval(end).neuralFilename = fullFilename; % return filename for appending by physServer
            retval(end).stimFilename = fullfile(datanet.storepath,'stimRecords',cparams.stimFilename);
            retval(end).trialNumber=cparams.trialNumber;
            retval(end).stimManagerClass=cparams.stimManagerClass;
            retval(end).stepName=cparams.stepName;
            retval(end).stepNumber=cparams.stepNumber;
            fprintf('got trial start command from ratrix\n')
		case constants.stimToDataCommands.S_TRIAL_END_EVENT_CMD
			% mark end of trial - how do we add an event to events_data, which is all the way out in physiologyServer?
			response=constants.dataToStimResponses.D_TRIAL_END_EVENT_ACK;
            cparams=pnet_getvar(con);
            retval(end+1).time=cparams.time; % timestamp from client
            retval(end).type='trial end';
            
			% 4/11/09 - send remaining neural data for this trial (from last 30sec chunk time to now end of trial event)
            if ~isempty(params.ai)
                try
                    numSampsToGet=get(params.ai,'SamplesAvailable');
                    [neuralData,neuralDataTimes]=getdata(params.ai,numSampsToGet);
                    % we dont need to use the function saveNidaqChunk here
                    % because we are not in a static workspace
                    % but should we anyways for sake of consistency?
                    saveNidaqChunk(params.neuralFilename,neuralData,neuralDataTimes([1 end]),params.chunkCount,GetSecs()-params.startTime,params.samplingRate,params.ai_parameters);
                    clear neuralData neuralDataTimes;
                    flushdata(params.ai);
                catch ex
                    getReport(ex)
                    disp('failed to get neural records');
                    keyboard
                end
            end
            
            fprintf('got trial end command from ratrix\n')
        case constants.stimToDataCommands.S_ERROR_RECOVERY_METHOD
            % whether client pressed 'Restart' or 'Quit'
            response=constants.dataToStimResponses.D_ERROR_METHOD_RECEIVED;
            cparams=pnet_getvar(con);
            retval(end+1).errorMethod=cparams.method;
            fprintf('got error recovery method from client\n')
        case constants.omniMessages.END_OF_DOTRIALS
            % this handles a k+q from the client
            quit=true;
            fprintf('we got a client kill!\n');
            
		otherwise
			error('unknown command');
	end
	
	% now check to see if another command is available
	cmd=pnet(con,'read',CMDSIZE,'double','noblock');
	if isempty(cmd) % no commands available, so just return
		return;
	else
		commandAvailable=true;
    end
catch ex
	disp(['CAUGHT ER: ' getReport(ex)]);
    % do some cleanup here
end


end % end function
