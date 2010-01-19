function [datanet quit specificCommand response] = clientHandleCommand(datanet,con,cmd,specificCommand,params)
% This function gets called by handleCommands, which loops through available commands. This function just does the switch statement on cmd
% and decides what to execute on the ratrix (client) side.
% INPUTS:
%	datanet - the client-side datanet object; should already have a pnet connection with proper timeouts set
%	cmd - the command from the server side to handle
%	specificCommand - if nonempty, a specificCommand that is expected by the client (set during handleCommands by previous call to clientHandleCommand)
%   params - a struct containing additional parameters passed from handleCommands
% OUTPUTS:
%   datanet - the input datanet object, possibly modified
%	quit - a quit flag (not sure if this will be doTrial's stopEarly or realtimeloop's quit), but something to tell ratrix to stop running trials!
%	specificCommand - return to handleCommands if the current cmd requires a specific command be the next in line
%	response - a response message to send to the server (usually an ack)

quit = false;
constants = getConstants(datanet);
response = [];
MAXSIZE=1024*1024;
CMDSIZE=1;

% ===================================================
if strmatch(datanet.type, 'data')
    error('must be called on datanet of type ''stim''');
end

% ===================================================
try
	success=false;
	if ~isempty(specificCommand) && cmd~=specificCommand
		error('received a faulty command %d when waiting for the specific command %d',cmd,specificCommand);
	end
	switch cmd
		case constants.dataToStimCommands.D_START_TRIALS_CMD
			% use pnet_getvar to get subjectID and protocol name
			subjParams=pnet_getvar(con);
            % do stuff here that is similar to standAloneRun, but uses the input datanet object (since connection exists there)
% 			% now call standAloneRun with these subjParams
% 			standAloneRun([],subjParams.protocol,subjParams.id);

            rx=getOrMakeDefaultRatrix(false);
            auth='ratrix';
            needToAddSubject=false;
            try
                isSubjectInRatrix=getSubjectFromID(rx,subjParams.id);
            catch ex
                if ~isempty(strfind(ex.message,'request for subject id not contained in ratrix'))
                    needToAddSubject=true;
                else
                    rethrow(ex)
                end
            end
            if needToAddSubject
                sub = subject(subjParams.id, 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
                rx=addSubject(rx,sub,auth);
            end
            
            su=str2func(subjParams.protocol); %weird, str2func does not check for existence!
            rx=su(rx,{subjParams.id});
            
            rx = emptyAllBoxes(rx,'starting trials in datanet mode',auth);
            rx=putSubjectInBox(rx,subjParams.id,1,auth); % only 1 box...
            
            s=getSubjectFromID(rx,subjParams.id);
            b=getBoxIDForSubjectID(rx,getID(s));
            st=getStationsForBoxID(rx,b);
            st=st(1);
            st=setDatanet(st,datanet);
            struct(st)
            struct(struct(st).datanet)

            %see commandBoxIDStationIDs() (need to add stuff for updating logs, keeping track of running, etc.)
            deleteOnSuccess=true; % this is needed otherwise getTrialRecordsForSubjectID gets duplicate (local+permStore) trialRecords
            writeToOracle=false;
            replicateChecker({getStandAlonePath(rx)},'warn')
            replicateTrialRecords({getStandAlonePath(rx)},deleteOnSuccess,writeToOracle); % added 6/9/09 to catch unreplicated records from an error in prev session
            %note: we still have overlapping trials after client hangs...
            %why don't we catch this upon the next start up? the line above
            %should have solved it... maybe the line below will help
            %discover the problem
            replicateChecker({getStandAlonePath(rx)},'keyboard')
                        
            fprintf('About to run trials on new ratrix\n');
            trustOsRecordFiles=true;
            rx=doTrials(st,rx,0,[],trustOsRecordFiles); %0 means repeat forever
            auth='ratrix';
            [rx ids] = emptyAllBoxes(rx,'done running trials in client mode',auth);
            
            replicateTrialRecords({getStandAlonePath(rx)},deleteOnSuccess,writeToOracle);
            
            success=true; % why do we need this?
            %4/10/09 - maybe we should send a 'killed' response here
            % -if k+q on client, then this killed response will be read as
            % a command by doServerIteration (should tell server to stop
            % recording, etc)
            % -if 'stop recording' from server, then this 'killed' response
            % acts as an ack that client got the server kill! (not equiv to
            % S_TRIALS_STOPPED response, which happens at the runRealTimeLoop level)
            response=constants.omniMessages.END_OF_DOTRIALS;
            quit=true;
		case constants.dataToStimCommands.D_STOP_TRIALS_CMD
            % use getvar to get subjectID
            subjID=pnet_getvar(con);
			success=true; % i dont think we need this....
            quit=true;
			response=constants.stimToDataResponses.S_TRIALS_STOPPED;
        case constants.dataToStimCommands.D_SET_STOREPATH_CMD
            params=pnet_getvar(con);
            success=true;
            response=constants.stimToDataResponses.S_STOREPATH_SET;
            datanet=setStorePath(datanet,params.storepath);
            fprintf('setting storepath\n');
        case constants.dataToStimCommands.D_GET_TIME_CMD
            success=true;
            response=[constants.stimToDataResponses.S_TIME_RESPONSE now];
        otherwise
            cmd
			error('unknown command');
	end
	
	% now check to see if another command is available
% 	cmd=pnet(con,'read',CMDSIZE,'double','noblock');
% 	if isempty(cmd) % no commands available, so just return
% 		return;
% 	else
% 		commandAvailable=true;
%     end
catch ex
    % if we catch an error while running doTrials, pass back a quit to
    % handleCommands
    response=constants.omniMessages.END_OF_DOTRIALS;
    quit=true;
	disp(['CAUGHT ER (at clientHandleCommand): ' getReport(ex)]);
    rethrow(ex);
    return
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