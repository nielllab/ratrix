function r=datanet(varargin)
% datanet class constructor
% r = datanet('stim', hostname, data_hostname, data_storepath, [ai_parameters])
% r = datanet('data', hostname, [ai_parameters])

% the ai_parameters struct can be stored in the stim datanet, to be sent to the data side (so it can be changed in the protocol)
% the data side's ai_parameters are what actually get used 

% wrapper of the pnet class to use TCP/IP
% includes commands, status, error msgs as predefined constants

% startup of data/stim connection
r.constants.startConnectionCommands.S_START_DATA_LISTENER_CMD = 101;
r.constants.startConnectionCommands.D_LISTENER_STARTED = 102;

% Stim to Data commands
r.constants.stimToDataCommands.S_START_RECORDING_CMD = 1;
r.constants.stimToDataCommands.S_TIMESTAMP_CMD = 2;
r.constants.stimToDataCommands.S_SAVE_DATA_CMD = 3;
r.constants.stimToDataCommands.S_STOP_RECORDING_CMD = 4;
r.constants.stimToDataCommands.S_SHUTDOWN_CMD = 5;
r.constants.stimToDataCommands.S_SET_STOREPATH_CMD = 6;
r.constants.stimToDataCommands.S_SET_AI_PARAMETERS_CMD = 7;
r.constants.stimToDataCommands.S_SET_LOCAL_PARAMETERS_CMD = 8;

% Data to Stim messages
r.constants.dataToStimResponses.D_RECORDING_STARTED = 11;
r.constants.dataToStimResponses.D_TIMESTAMPED = 12;
r.constants.dataToStimResponses.D_DATA_SAVED = 13;
r.constants.dataToStimResponses.D_RECORDING_STOPPED = 14;
r.constants.dataToStimResponses.D_SHUTDOWN = 15;
r.constants.dataToStimResponses.D_STOREPATH_SET = 16;
r.constants.dataToStimResponses.D_AI_PARAMETERS_SET = 17;
r.constants.dataToStimResponses.D_LOCAL_PARAMETERS_SET = 18;
% r.constants.dataToStimResponses.D_RECEIVED_VAR = 16;


r.type=[]; % either 'stim' or 'data'
r.host=[]; % hostname
r.port=[]; % port number
r.sockcon=[]; % actual pnet object - socket
r.storepath=''; % location where all data is stored (neuralRecords, stimRecords, spikeRecords, analysis)
                        % pass this in during setProtocol to the stim datanet - it will get sent to the data datanet as well
r.con=[]; % actual pnet object - connection
r.data_hostname = ''; % hostname of data process (only nonempty if type is 'stim'
r.ai_parameters = []; % parameters for the nidaq instrument - must be a struct
                      % ai_parameters.numChans - number of channels for analoginput object
                      % ai_parameters.sampRate - sampling rate of analoginput object
                      % ai_parameters.inputRanges - input ranges of analoginput object
                      % ai_parameters.recordingFile - filename of recording for nidaq

switch nargin
    case 0
        % no default object
        error('default datanet object not supported');
    case {2 3}
        % data side
        if ischar(varargin{1}) && ischar(varargin{2})
            if strcmp(varargin{1}, 'data')
                r.type = 'data';
                r.port = 8888;
                r.host = varargin{2};
                r.sockcon = pnet('tcpsocket', r.port);
            else
                error('first argument must be either ''data'' and second argument must be a string');
            end
            % if we have ai_parameters
            if nargin==3
                if isstruct(varargin{3}) && strcmp(r.type, 'data')
                    r.ai_parameters = varargin{3};
                end
            end
        else
            error('must be ''data'' type, and provide hostname');
        end
    case {4 5}
        % stim side
        % type and hostname
        if ischar(varargin{1}) && ischar(varargin{2})
            if strcmp(varargin{1}, 'stim')
                r.type = 'stim';
                r.port = 8888;
                r.host = varargin{2};
                r.sockcon = pnet('tcpsocket', r.port);
            else
                error('type must be stim');
            end
        else
            error('first argument must be ''stim'' and second argument must be a stirng');
        end
        % data_hostname
        if ischar(varargin{3})
            r.data_hostname = varargin{3};
        else
            error('data_hostname must be a string');
        end
        % storepath
        if ischar(varargin{4})
            r.storepath = varargin{4};
        else
            error('data_storepath must be a valid directory');
        end
        % optional ai_parameters
        if nargin==5
            if isstruct(varargin{5})
                r.ai_parameters = varargin{5};
            else
                error('ai_parameters must be a struct');
            end
        end        
    otherwise
        nargin
        error('Wrong number of input arguments')
end
if r.sockcon == -1
    error('failed to create valid socket connection');
end
r = class(r, 'datanet');

