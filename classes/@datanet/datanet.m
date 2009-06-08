function r=datanet(varargin)
% datanet class constructor
% r = datanet('data', hostname, client_hostname, data_storepath, [ai_parameters])
% r = datanet('stim', hostname, [ai_parameters])

% the ai_parameters struct can be stored in the stim datanet, to be sent to the data side (so it can be changed in the protocol)
% the data side's ai_parameters are what actually get used 

% wrapper of the pnet class to use TCP/IP
% includes commands, status, error msgs as predefined constants

% port numbers are hardcoded to be 8888 and 8889. not sure if we should allow custom port numbers, because the function
% connectToClient uses the same hardcoded ports
% see http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers for a list of potential port conflicts (none atm)

% =================================================================
% commands/responses where data sends a command, stim sends a response
% data to stim commands
r.constants.dataToStimCommands.D_START_TRIALS_CMD = 1;
r.constants.dataToStimCommands.D_STOP_TRIALS_CMD = 2;
r.constants.dataToStimCommands.D_SET_STOREPATH_CMD = 3;
r.constants.dataToStimCommands.D_GET_TIME_CMD = 4;

% stim to data responses
r.constants.stimToDataResponses.S_TRIALS_STARTED = 101;
r.constants.stimToDataResponses.S_TRIALS_STOPPED = 102;
r.constants.stimToDataResponses.S_STOREPATH_SET = 103;
r.constants.stimToDataResponses.S_TIME_RESPONSE = 104;

% =================================================================
% commands/responses where stim sends a command, data sends a response
% stim to data commands
r.constants.stimToDataCommands.S_TRIAL_START_EVENT_CMD = 51;
r.constants.stimToDataCommands.S_TRIAL_END_EVENT_CMD = 52;
r.constants.stimToDataCommands.S_STOP_RECORDING_CMD = 53;
r.constants.stimToDataCommands.S_ERROR_RECOVERY_METHOD = 54;

% data to stim responses
r.constants.dataToStimResponses.D_TRIAL_START_EVENT_ACK = 151;
r.constants.dataToStimResponses.D_TRIAL_END_EVENT_ACK = 152;
r.constants.dataToStimResponses.D_RECORDING_STOPPED = 153;
r.constants.dataToStimResponses.D_ERROR_METHOD_RECEIVED = 154;

% special omni messages that can act as both a command and a response (ack)
r.constants.omniMessages.END_OF_DOTRIALS = 1001;
% =================================================================

r.type=[]; % either 'stim' or 'data'
r.host=[]; % hostname
r.ports=[]; % port numbers for cmd and ack channels
r.cmdSockcon=[]; % actual pnet object - socket for commands
r.ackSockcon=[]; % actual pnet object - socket for acks
r.storepath=''; % location where all data is stored (neuralRecords, stimRecords, spikeRecords, analysis)
                        % pass this in during setProtocol to the stim datanet - it will get sent to the data datanet as well
r.cmdCon=[]; % actual pnet object - connection for commands
r.ackCon=[]; % actual pnet object - connection for acks
r.client_hostname = ''; % hostname of the client machine (empty if this is a 'stim' datanet)
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
        % stim side
        if ischar(varargin{1}) && ischar(varargin{2})
            if strcmp(varargin{1}, 'stim')
                r.type = 'stim';
                r.ports = [8888 8889];
                r.host = varargin{2};
            else
                error('first argument must be ''stim'' and second argument must be a string');
            end
            % if we have ai_parameters
            if nargin==3
                if isstruct(varargin{3}) && strcmp(r.type, 'stim')
                    r.ai_parameters = varargin{3};
                end
            end
        else
            error('must be ''stim'' type, and provide hostname');
        end
    case {4 5}
        % data side
        % type and hostname
        if ischar(varargin{1}) && ischar(varargin{2})
            if strcmp(varargin{1}, 'data')
                r.type = 'data';
                r.ports = [8888 8889];
                r.host = varargin{2};
            else
                error('type must be data');
            end
        else
            error('first argument must be ''data'' and second argument must be a stirng');
        end
        % client_hostname
        if ischar(varargin{3})
            r.client_hostname = varargin{3};
        else
            error('client_hostname must be a string');
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

r = class(r, 'datanet');

