function r = rnet(varargin)
% Server to Station Commands
r.constants.serverToStationCommands.S_START_TRIALS_CMD = 1;
r.constants.serverToStationCommands.S_STOP_TRIALS_CMD = 2;
%r.constants.serverToStationCommands.S_GET_TRIAL_RECORDS_CMD = 3;
%r.constants.serverToStationCommands.S_CLEAR_TRIAL_RECORDS_CMD = 4;
r.constants.serverToStationCommands.S_GET_STATUS_CMD = 5;
r.constants.serverToStationCommands.S_GET_RATRIX_CMD = 6;
r.constants.serverToStationCommands.S_GET_RATRIX_BACKUPS_CMD = 7;
r.constants.serverToStationCommands.S_CLEAR_RATRIX_BACKUPS_CMD = 8;
r.constants.serverToStationCommands.S_GET_QUICK_REPORT_CMD = 9;
r.constants.serverToStationCommands.S_SET_VALVES_CMD = 10;
r.constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD = 11;
r.constants.serverToStationCommands.S_GET_PENDING_COMMANDS_CMD = 12;
r.constants.serverToStationCommands.S_CLEAR_COMMAND_CMD = 13;
r.constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD = 14;
r.constants.serverToStationCommands.S_REWARD_COMPLETE_CMD = 15;
r.constants.serverToStationCommands.S_GET_MAC_CMD = 16;
r.constants.serverToStationCommands.S_GET_VALVE_STATES_CMD = 17;
r.constants.serverToStationCommands.S_REPLICATE_TRIAL_RECORDS_CMD = 18;
r.constants.serverToStationCommands.S_RECEIVE_DATA_CMD = 99; %for testing only

% Station to Server
r.constants.stationToServerCommands.C_CMD_ACK = 101;
r.constants.stationToServerCommands.C_CMD_ERR = 102;
%r.constants.stationToServerCommands.C_RECV_TRIAL_RECORDS_CMD = 103;
r.constants.stationToServerCommands.C_RECV_RATRIX_CMD = 104;
r.constants.stationToServerCommands.C_RECV_RATRIX_BACKUPS_CMD = 105;
r.constants.stationToServerCommands.C_RECV_STATUS_CMD = 106;
r.constants.stationToServerCommands.C_RECV_REPORT_CMD = 107;
r.constants.stationToServerCommands.C_RECV_VALVE_STATES_CMD = 108;
r.constants.stationToServerCommands.C_RECV_COMMAND_LIST_CMD = 109;
r.constants.stationToServerCommands.C_REWARD_CMD = 110;
r.constants.stationToServerCommands.C_VALVES_SET_CMD = 111;
r.constants.stationToServerCommands.C_UPDATE_SOFTWARE_ON_TARGETS_CMD = 112;
r.constants.stationToServerCommands.C_RECV_MAC_CMD = 113;
r.constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD = 114;
r.constants.stationToServerCommands.C_STOPPED_TRIALS = 115;
r.constants.stationToServerCommands.C_RECEIVE_DATA_CMD = 199; %for testing only

% Monitoring Client to Server
r.constants.monitorClientCommands.M_ISSUE_COMMAND_CMD = 201;
r.constants.monitorClientCommands.M_VERIFY_ALL_STATIONS_CMD = 202;

% Command Priority Levels
r.constants.priorities.IMMEDIATE_PRIORITY = 1;
r.constants.priorities.AFTER_TRIAL_PRIORITY = 2;
r.constants.priorities.AFTER_SESSION_PRIORITY = 3;
r.constants.priorities.MESSAGE_RECEIPTS_PRIORITY = 4;

% Client statuses
r.constants.statuses.MID_TRIAL = 1;
r.constants.statuses.IN_SESSION_BETWEEN_TRIALS = 2;
r.constants.statuses.BETWEEN_SESSIONS = 3;
r.constants.statuses.NO_RATRIX = 4;

%Command Error Response Types
r.constants.errors.UNRECOGNIZED_COMMAND = 1;
r.constants.errors.BAD_ARGS = 2;
r.constants.errors.CORRUPT_STATE_SENT = 3;
r.constants.errors.BAD_STATE_FOR_COMMAND = 4;

%Error values (non-command)
r.constants.errors.CANT_DETERMINE_MAC = -1;

%Node Types
r.constants.nodeTypes.SERVER_TYPE = 1;
r.constants.nodeTypes.CLIENT_TYPE = 2;

%addJavaComponents(); would like to have this here, but it doesn't work for some reason...
%     the caller has to call it before constructing an
%     rnet for some reason.  can't figure out why, but if you don't do it, even
%     though the dynamic path is updated correctly, the import appears to
%     fail.
import rlab.net.*; %lame that import isn't global -- can't call in lower function

r.type = 0;
r.server = [];
r.client = [];
r.serverRegister = {};
r.primeClient = {};
r.id = [];
r.host = [];
r.port = 0;

if nargin==1 && isa(varargin{1},'rnet')
    r = varargin{1};
elseif ischar(varargin{1})
    type = varargin{1};
    switch(nargin)
        case 0
            error('Default rnet object not supported');
        case {1 2}
            if strcmp(type,'server') == 1
                r.type = r.constants.nodeTypes.SERVER_TYPE;
                r.id = 'server';
                r.host = 'localhost';

                if nargin==2
                    if isnumeric(varargin{2}) %should be a stricter test?  positive integer?
                        r.port = varargin{2};
                        r.server = RlabNetworkServer(r.port);
                    else
                        error('Server second argument should be port number');
                    end
                else
                    r.port = RlabNetworkServer.SERVER_PORT;
                    r.server = RlabNetworkServer();
                end

                r.server.setTemporaryPath(java.lang.String(matlabroot));
                thread = java.lang.Thread(r.server);
                thread.start();
            else
                error('Only server type can have one or two arguments');
            end

        case {3 4}
            if strcmp(type,'client') == 1
                if ischar(varargin{2})
                    r.id = varargin{2};
                else
                    error('Client should provide its id in string form');
                end

                if ischar(varargin{3}) %should be a stricter test?  ip address?
                    r.host = varargin{3};
                else
                    error('Client should provide the host string');
                end

                if nargin==4
                    if isnumeric(varargin{4})  %should be a stricter test?  positive integer?
                        r.port = varargin{4};
                    else
                        error('Client should provide a number port number');
                    end
                else
                    r.port = RlabNetworkServer.SERVER_PORT;
                end

                r.type = r.constants.nodeTypes.CLIENT_TYPE;
                r.client = RlabNetworkClient(java.lang.String(r.id),java.lang.String(r.host),r.port);
                r.client.setTemporaryPath(java.lang.String(matlabroot));

                % Need to determine if the connect command was acked by the server, and by that if this
                % connection is fully established
                startTime = GetSecs();
                timeout = 5.0;
                while ~r.client.connectionEstablished()
                  if GetSecs() > startTime+timeout
                    r.client.shutdown();
                    r.client=[ ];
                    error('Client timed out waiting to establish connection');
                  end
                  WaitSecs(0.1);
                end
            else
                error('Only client can have three or four arguments');
            end

        otherwise
            errror('Invalid number of arguments to rnet');
    end
    
    r = class(r,'rnet');
else
    error('First argument to rnet should be type');
end