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
			filename=cparams.filename;
			fullFilename = fullfile(datanet.storepath, 'neuralRecords', filename);
            if ~isempty(params.ai)
                samplingRate=params.samplingRate;
                save(fullFilename, 'samplingRate');
            end
			retval(end).fullFilename = fullFilename; % return filename for appending by physServer
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
                    saveNidaqChunk(params.fullFilename,neuralData,neuralDataTimes([1 end]),params.chunkCount,GetSecs()-params.startTime,params.samplingRate);
                    clear neuralData neuralDataTimes;
                    flushdata(params.ai);
                catch ex
                    getReport(ex)
                    disp('failed to get neural records');
                    keyboard
                end
            end
            
            fprintf('got trial end command from ratrix\n')
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

% % % ========================================================================================
% % % ENTERING LISTENER LOOP
% % try
    % % while ~quit
        % % success = false;
        % % received = pnet(datacon,'read',CMDSIZE,'double','noblock');

        % % if ~isempty(received) % if we received something, decide what to do with the command
            % % size(received)
            % % received
            % % if ~isempty(specificCommand) && received~=specificCommand
                % % error('received a faulty command %d when waiting for the specific command %d', received, specificCommand);
            % % end
            % % switch received % decide what to do based on what command was received
                % % case constants.startConnectionCommands.S_START_DATA_LISTENER_CMD
                    % % success = true;
                    % % fprintf('we got a command to start the data listener\n');
                    % % message = constants.startConnectionCommands.D_LISTENER_STARTED;



                % % case constants.stimToDataCommands.S_SET_AI_PARAMETERS_CMD
                    % % params = pnet_getvar(datacon);
                    % % datanet.ai_parameters = params;
                    % % success = true;
                    % % message = constants.dataToStimResponses.D_AI_PARAMETERS_SET;
                % % case constants.stimToDataCommands.S_SET_LOCAL_PARAMETERS_CMD
                    % % parameters = pnet_getvar(datacon);
                    % % success = true;
                    % % message = constants.dataToStimResponses.D_LOCAL_PARAMETERS_SET;
                % % case constants.stimToDataCommands.S_START_RECORDING_CMD
                    % % success = true;
                    % % % do something here to start recording (turn on NIDAQ)
                    % % % START NIDAQ HERE
                    % % % =================================================================================================
                    % % % get parameters from datanet object field ai_parameters, or use defaults
                    % % ai_parameters = datanet.ai_parameters;
                    % % if isfield(ai_parameters, 'numChans')
                        % % numChans = ai_parameters.numChans;
                    % % else
                        % % numChans = 3;
                    % % end
                    % % if isfield(ai_parameters, 'sampRate')
                        % % sampRate = ai_parameters.sampRate;
                    % % else
                        % % sampRate = 40000;
                    % % end
                    % % if isfield(ai_parameters, 'inputRanges')
                        % % inputRanges = ai_parameters.inputRanges;
                    % % else
                        % % inputRanges = repmat([-1 6],numChans,1);
                    % % end
                    % % if isfield(ai_parameters, 'recordingFile')
                        % % recordingFile = ai_parameters.recordingFile;
                    % % else
                        % % recordingFile = [];
                    % % end
                    % % % start NIDAQ
                    % % sprintf('starting NIDAQ with %d channels %d sampRate',numChans,sampRate)
                    % % inputRanges

                    % % [ai chans recordingFile]=openNidaqForAnalogRecording(numChans,sampRate,inputRanges,recordingFile);
                    % % ai
                    % % set(ai)
                    % % get(ai)
                    % % get(ai,'Channel')
                    % % daqhwinfo(ai)
                    % % chans
                    % % set(chans(1))
                    % % get(chans(1))
                    % % start(ai);
                    % % % =================================================================================================
                    % % fprintf('we got a command to start recording and sent ack\n');
                    % % message = constants.dataToStimResponses.D_RECORDING_STARTED;
                % % case constants.stimToDataCommands.S_TIMESTAMP_CMD
                    % % success = true;
                    % % % do something here to store local timestamp
                    % % % INSERT TIMESTAMP HERE
                    % % % =================================================================================================
                    % % % get a single sample using getdata (okay to extract from engine b/c streamed to disk)
                    % % flushdata(ai);
                    % % % start a matlab-based local timestamp to also keep track of roughly how long a trial records for
                    % % matlabTimeStamp = GetSecs();
                    % % % =================================================================================================
                    % % fprintf('we got a command to store a local timestamp\n');
                    % % message = constants.dataToStimResponses.D_TIMESTAMPED;
                    % % [timestampData,timestamp] = getdata(ai,1);
                % % case constants.stimToDataCommands.S_SAVE_DATA_CMD
                    % % % we got a S_SAVE_DATA_CMD - try to read filename now
                    % % filename=pnet(datacon,'read',MAXSIZE,'char','noblock');
                    % % while isempty(filename)
                        % % success=false;
                        % % filename=pnet(datacon,'read',MAXSIZE,'char','noblock');
                    % % end
                    % % success = true;
                    % % % got a filename - save to it

                    % % % do something here to get data from NIDAQ using local timestamp variable
                    % % % GET DATA HERE
                    % % % =================================================================================================
                    % % samplingRate = get(ai,'SampleRate');
                    % % estimatedElapsedTime = GetSecs() - matlabTimeStamp; % estimated time of recording to retrieve
                    % % estimatedNumberOfSamples = (estimatedElapsedTime+1)*samplingRate; % estimated number of samples to get - add a 1sec buffer
                    % % if estimatedNumberOfSamples > get(ai,'SamplesAvailable')
                        % % estimatedNumberOfSamples
                        % % newnum=get(ai,'SamplesAvailable')
                        % % warning('we requested more samples from the nidaq than available - resetting to max available!!');
                        % % estimatedNumberOfSamples=newnum;
                    % % end
                    
                    % % fullFilename = fullfile(datanet.storepath, 'neuralRecords', filename);
                    
                    % % try
                        % % maxSamples=5000000; % MATLAB memory limitations - only do 5million samples
                        % % numUnsavedSamples=0;
                        % % doSave=true;
                        % % while estimatedNumberOfSamples>maxSamples
                            % % [neuralData, neuralDataTimes] = getdata(ai, maxSamples);
                            % % if doSave
                                % % % now go through and throw out trialData that is past our timestamp
                                % % firstGoodSample=find(neuralDataTimes>=timestamp,1,'first');
                                % % if firstGoodSample~=1 % this means we have samples to throw away from the front
                                    % % neuralData(1:firstGoodSample-1,:)=[];
                                    % % neuralDataTimes(1:firstGoodSample-1)=[];
                                % % end
                                % % firstNeuralDataTime = neuralDataTimes(1);
                                % % save(fullFilename, 'neuralData', 'neuralDataTimes', 'samplingRate', 'matlabTimeStamp',...
                                    % % 'firstNeuralDataTime', 'parameters');
                            % % else
                                % % numUnsavedSamples=numUnsavedSamples+maxSamples;
                            % % end
                            % % clear neuralData neuralDataTimes;
                            % % doSave=false;
                            % % estimatedNumberOfSamples=estimatedNumberOfSamples-maxSamples;
                        % % end
                        % % % now we have the last bit < maxSamples - append
                        % % % start/stop to file
                        % % [neuralData,neuralDataTimes]=getdata(ai,estimatedNumberOfSamples);
                        % % lastNeuralDataTime = neuralDataTimes(end);
                        % % if doSave
                            % % % this means we requested less than maxSamples
                            % % % samples, so do the timestamp filtering and
                            % % % saving
                            % % firstGoodSample=find(neuralDataTimes>=timestamp,1,'first');
                            % % if firstGoodSample~=1 % this means we have samples to throw away from the front
                                % % neuralData(1:firstGoodSample-1,:)=[];
                                % % neuralDataTimes(1:firstGoodSample-1)=[];
                            % % end
                            % % firstNeuralDataTime = neuralDataTimes(1);
                            % % save(fullFilename, 'neuralData', 'neuralDataTimes', 'samplingRate', 'matlabTimeStamp',...
                                % % 'firstNeuralDataTime', 'parameters');
                        % % else
                            % % numUnsavedSamples=numUnsavedSamples+estimatedNumberOfSamples;
                        % % end
                        % % saveStr=sprintf('save %s lastNeuralDataTime numUnsavedSamples -append',fullFilename);
                        % % eval(saveStr);
                        % % flushdata(ai);                        
                    % % catch
                        % % keyboard
                    % % end
                    % % % CHANGE MESSAGE TO BE neuralDataTimes, not a random data

                    % % % =====================================================
                    % % % ============================================
                    % % fprintf('we got a command to send a trial''s worth of data\n');
                    % % message = constants.dataToStimResponses.D_DATA_SAVED;
                % % case constants.stimToDataCommands.S_SEND_EVENT_DATA_CMD
                    % % % get events from events_data
                    % % success=true;
                    % % neuralEvents=events_data(eventsToSendIndex:end);
                    % % eventsToSendIndex=length(events_data)+1;
                    % % specificCommand=constants.stimToDataCommands.S_ACK_EVENT_DATA_CMD;
                    % % pnet_putvar(datacon,neuralEvents);
                    % % message = constants.dataToStimResponses.D_EVENT_DATA_SENT;
                % % case constants.stimToDataCommands.S_STOP_RECORDING_CMD
                    % % success = true;
                    % % % do something here to stop recording (turn off NIDAQ)
                    % % % STOP NIDAQ HERE
                    % % % =================================================================================================
                    % % stop(ai);
                    % % delete(ai)
                    % % clear ai
                    % % % =================================================================================================
                    % % fprintf('we got a command to stop recording\n');
                    % % message = constants.dataToStimResponses.D_RECORDING_STOPPED;
                % % case constants.stimToDataCommands.S_SHUTDOWN_CMD
                    % % success = true;
                    % % fprintf('we got a command to shutdown\n');
                    % % quit = true;
                    % % message = constants.dataToStimResponses.D_SHUTDOWN;
                % % case constants.stimToDataCommands.S_SET_STOREPATH_CMD
                    % % path=pnet(datacon,'read',MAXSIZE,'char','noblock');
                    % % while isempty(path)
                        % % success=false;
                        % % path=pnet(datacon,'read',MAXSIZE,'char','noblock');
                    % % end
                    % % success=true;
                    % % datanet.storepath = path;
                    % % % 11/5/08 - move directory creation here (create dirs when we set the path)
                    % % %                 mkdir(path);
                    % % mkdir(fullfile(path, 'eyeRecords'));
                    % % mkdir(fullfile(path, 'neuralRecords'));
                    % % mkdir(fullfile(path, 'stimRecords'));
                    % % fprintf('we got a command to set the storepath to %s\n', path);
                    % % message = constants.dataToStimResponses.D_STOREPATH_SET;
                % % case constants.stimToDataCommands.S_ACK_EVENT_DATA_CMD
                    % % success=true;
                    % % fprintf('we received an event data ack from stim, resetting specificCommand to []\n');
                    % % specificCommand=[];
                    % % message = constants.dataToStimResponses.D_EVENT_DATA_ACK_RECVD;
                % % otherwise
                    % % success = false;
                    % % received
                    % % fprintf('we got an unrecognized command\n');
            % % end
        % % else  % if nothing received, then use pnet('status') to check for disconnect
            % % stat=pnet(datacon,'status');
            % % if stat==0
                % % stop(ai)
                % % delete(ai)
                % % clear ai
                % % fprintf('NIDAQ recording stopped due to error on ratrix machine!\n');
                % % quit=true;
                % % fprintf('status revealed a disconnect from ratrix machine - quitting!\n');
            % % end
        % % end


        % % % now send appropriate message to the stim computer (ack or fail)
        % % if success
            % % pnet(datacon,'write',message);
        % % elseif ~success % dont write anything when fails
            % % %             pnet(con,'write',-1);
        % % else
            % % error('if neither successful nor unsuccessful then what is this?')
        % % end
    % % end
% % catch ex
    % % disp(['CAUGHT ER: ' getReport(ex)]);
    % % pnet('closeall');
    % % clear all; % is this the only way to guarantee that we stop the NIDAQ?
% % end

% % pnet('closeall'); % close all sockets/connections before exiting the listener loop
% % % should we do this? or do we want the datanet obj to be reuseable?
% % end % end function