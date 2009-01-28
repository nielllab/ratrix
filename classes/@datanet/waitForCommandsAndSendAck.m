function quit = waitForCommandsAndSendAck(datanet)
% this function keeps that data machine listening for commands from the stim computer and responds to each command with an ack
quit = false;
constants = getConstants(datanet);
message = [];
MAXSIZE=1024*1024;
CMDSIZE=1;

if strmatch(datanet.type, 'stim')
    error('must be called on datanet of type ''data''');
end

% first connection - keep trying to get a connection using tcplisten
datacon = -1;
while datacon == -1
    datacon=pnet(datanet.sockcon,'tcplisten');
end


% local variables that can be set by commands
% parameters.refreshRate - in hz
% parameters.resolution - [width height]
parameters=[];

% now we have a connection from client
pnet(datacon,'setreadtimeout', 5); % set timeout to (hopefully) affect pnet_getvar
pnet(datacon,'setwritetimeout', 5);
while ~quit
    success = false;
    received = pnet(datacon,'read',CMDSIZE,'double','noblock');

    if ~isempty(received) % if we received something, decide what to do with the command
        size(received)
        received
        switch received % decide what to do based on what command was received
            case constants.startConnectionCommands.S_START_DATA_LISTENER_CMD
                success = true;
                fprintf('we got a command to start the data listener\n');
                message = constants.startConnectionCommands.D_LISTENER_STARTED;
            case constants.stimToDataCommands.S_SET_AI_PARAMETERS_CMD
                params = pnet_getvar(datacon);
                datanet.ai_parameters = params;
                success = true;            
                message = constants.dataToStimResponses.D_AI_PARAMETERS_SET;
            case constants.stimToDataCommands.S_SET_LOCAL_PARAMETERS_CMD
                parameters = pnet_getvar(datacon);
                success = true;
                message = constants.dataToStimResponses.D_LOCAL_PARAMETERS_SET;
            case constants.stimToDataCommands.S_START_RECORDING_CMD
                success = true;
                % do something here to start recording (turn on NIDAQ)
                % START NIDAQ HERE
                % =================================================================================================
                % get parameters from datanet object field ai_parameters, or use defaults
                ai_parameters = datanet.ai_parameters;
                if isfield(ai_parameters, 'numChans')
                    numChans = ai_parameters.numChans;
                else
                    numChans = 3;
                end
                if isfield(ai_parameters, 'sampRate')
                    sampRate = ai_parameters.sampRate;
                else
                    sampRate = 40000;
                end
                if isfield(ai_parameters, 'inputRanges')
                    inputRanges = ai_parameters.inputRanges;
                else
                    inputRanges = repmat([-1 6],numChans,1);
                end
                if isfield(ai_parameters, 'recordingFile')
                    recordingFile = ai_parameters.recordingFile;
                else
                    recordingFile = [];
                end
                % start NIDAQ
                sprintf('starting NIDAQ with %d channels %d sampRate',numChans,sampRate)
                inputRanges
                
                [ai chans recordingFile]=openNidaqForAnalogRecording(numChans,sampRate,inputRanges,recordingFile);
                ai
                set(ai)
                get(ai)
                get(ai,'Channel')
                daqhwinfo(ai)
                chans
                set(chans(1))
                get(chans(1))
                start(ai);
                % =================================================================================================
                fprintf('we got a command to start recording and sent ack\n');
                message = constants.dataToStimResponses.D_RECORDING_STARTED;
            case constants.stimToDataCommands.S_TIMESTAMP_CMD
                success = true;
                % do something here to store local timestamp
                % INSERT TIMESTAMP HERE
                % =================================================================================================
                % get a single sample using getdata (okay to extract from engine b/c streamed to disk)
                flushdata(ai);
                % start a matlab-based local timestamp to also keep track of roughly how long a trial records for
                matlabTimeStamp = GetSecs();
                % =================================================================================================
                fprintf('we got a command to store a local timestamp\n');
                message = constants.dataToStimResponses.D_TIMESTAMPED;
                [timestampData,timestamp] = getdata(ai,1);
            case constants.stimToDataCommands.S_SEND_DATA_CMD
                % we got a S_SEND_DATA_CMD - try to read filename now
                filename=pnet(datacon,'read',MAXSIZE,'char','noblock');
                while isempty(filename)
                    success=false;
                    filename=pnet(datacon,'read',MAXSIZE,'char','noblock');
                end
                success = true;
                % got a filename - save to it

                % do something here to get data from NIDAQ using local timestamp variable
                % GET DATA HERE
                % =================================================================================================
                samplingRate = get(ai,'SampleRate');
                estimatedElapsedTime = GetSecs() - matlabTimeStamp; % estimated time of recording to retrieve
                estimatedNumberOfSamples = (estimatedElapsedTime+1)*samplingRate; % estimated number of samples to get - add a 1sec buffer
                [neuralData, neuralDataTimes] = getdata(ai, estimatedNumberOfSamples);
                firstNeuralDataTime = neuralDataTimes(1);
                % now go through and throw out trialData that is past our timestamp
                neuralData(find(neuralDataTimes<timestamp), :) = [];
                neuralDataTimes(find(neuralDataTimes<timestamp)) = [];
                % CHANGE MESSAGE TO BE neuralDataTimes, not a random data
                % =================================================================================================
                fullFilename = fullfile(datanet.storepath, 'neuralRecords', filename);
%                 trialData=[10 11 12];
%                 times = [1 2 3 4 5 6 7];
                save(fullFilename, 'neuralData', 'neuralDataTimes', 'samplingRate', 'matlabTimeStamp', 'firstNeuralDataTime', 'parameters');
                fprintf('we got a command to send a trial''s worth of data\n');
                message = constants.dataToStimResponses.D_DATA;
            case constants.stimToDataCommands.S_STOP_RECORDING_CMD
                success = true;
                % do something here to stop recording (turn off NIDAQ)
                % STOP NIDAQ HERE
                % =================================================================================================
                stop(ai);
                delete(ai)
                clear ai
                % =================================================================================================
                fprintf('we got a command to stop recording\n');
                message = constants.dataToStimResponses.D_RECORDING_STOPPED;
            case constants.stimToDataCommands.S_SHUTDOWN_CMD
                success = true;
                fprintf('we got a command to shutdown\n');
                quit = true;
                message = constants.dataToStimResponses.D_SHUTDOWN;
            case constants.stimToDataCommands.S_SET_STOREPATH_CMD
                path=pnet(datacon,'read',MAXSIZE,'char','noblock');
                while isempty(path)
                    success=false;
                    path=pnet(datacon,'read',MAXSIZE,'char','noblock');
                end
                success=true;
                datanet.storepath = path;
                % 11/5/08 - move directory creation here (create dirs when we set the path)
%                 mkdir(path);
                mkdir(fullfile(path, 'eyeRecords'));
                mkdir(fullfile(path, 'neuralRecords'));
                mkdir(fullfile(path, 'stimRecords'));
                fprintf('we got a command to set the storepath to %s\n', path);
                message = constants.dataToStimResponses.D_STOREPATH_SET;             
            otherwise
                success = false;
                received
                fprintf('we got an unrecognized command\n');
        end
    else % if nothing received, try pnet_getvar
        % failed to receive valid command using read - try using pnet_getvar
%             received = pnet_getvar(serv);
%         if ~isempty(received) % IGNORE THIS PART FOR NOW - PNET_GETVAR disconnects remote host for some reason
%             success = true;
%             message = constants.dataToStimResponses.D_RECEIVED_VAR;
%             % just echo received for now
%             received
%             fprintf('we got something through pnet_getvar\n');
%         end
    end

        
    % now send appropriate message to the stim computer (ack or fail)
    if success
        pnet(datacon,'write',message);
    elseif ~success % dont write anything when fails
%             pnet(con,'write',-1);
    else
        error('if neither successful nor unsuccessful then what is this?')
    end
    % send ack to stim computer if successful
    %%%% THIS IS WHERE BEHAVIOR WILL BE DIFFERENT FOR DIFFERENT RECEIVED COMMANDS
    % if we received a S_START_RECORDING_CMD, then run local calls to start recording, then send ack
    % if we received a S_SEND_DATA_CMD, then just send data (tell stim to listen)
    % etc etc
end


end % end function