function quit=clientHandleVerifiedCommand(r,com,cmd,args,stat)

if ~iscell(args)
    error('args must be a cell array')
end

if ~isa(com,'rnetcommand') %~strcmp(class(c),'rnetcommand') %does isa not work for java objects?
    error('com must be a rnetcommand')
end

if ~isValidClientCommand(r,cmd)
    error('cmd must be a command constant as defined in rnet.m: S_***_CMD')
end

if ~isValidStatus(r,stat)
    error('stat must be a status constant as defined in rnet.m')
end

quit=false;
constants = getConstants(r);

ratrixDataPath=fullfile(fileparts(fileparts(getRatrixPath)),'testdata',filesep);
%ratrixDataPath='C:\Documents and Settings\rlab\Desktop\testdata\'; 
%figure out where to store this
%actually, this is an ok place -- there's nothing persistent
%that the client/bootstrap can use to know where it sticks ratrices
%the server could tell it where to stick them, but it's cooler
%that it can decide whatever it wants.  the thing is that
%box/station directories make themselves according to their own paths, 
%which under the old way of thinking could be remote, but in reality
%are always local.  this make for counterintuitive behavior when
%miniratrices passed over an rnet implant themselves and have separate
%server and data directories.

switch cmd
    %commands that require status=NO_RATRIX
    case constants.serverToStationCommands.S_START_TRIALS_CMD
        if stat==constants.statuses.NO_RATRIX
            fprintf('Got a ratrix to begin trials with\n');
            rx = args{1};
            if isGoodNonpersistedSingleStationRatrix(rx)
                fprintf('Ratrix is in good state to begin trials with\n');

                rx=establishDB(rx,fullfile(ratrixDataPath, 'ServerData'),1); %THIS DOESN'T WORK THE FIRST TIME, BUT DOES ONCE THE DIRS ARE CREATED
                quit=sendAcknowledge(r,com);

                ids=getSubjectIDs(rx);
                s=getSubjectFromID(rx,ids{1});
                b=getBoxIDForSubjectID(rx,getID(s));
                st=getStationsForBoxID(rx,b);

                %see commandBoxIDStationIDs() (need to add stuff for updating logs, keeping track of running, etc.)

                fprintf('About to run trials on new ratrix\n');
                rx=doTrials(st(1),rx,0,r); %0 means repeat forever
                quit=sendToServer(r,getClientId(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_STOPPED_TRIALS,{rx});
            else
                quit=sendError(r,com,constants.errors.CORRUPT_STATE_SENT,'ratrix is not good nonpersisted single station ratrix');
                fprintf('Ratrix is not in a good persistant state\n');
            end
        else
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is not NO_RATRIX - must call S_STOP_TRIALS_CMD before S_START_TRIALS_CMD');
        end
    case constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD
        fprintf('handling shutdown from server\n')
        if stat==constants.statuses.NO_RATRIX
            if ~commandsAvailable(r)
                quit=true;
                sendAcknowledge(r,com);
                %sendRatrixToServer(ratrixDataPath,r,constants);
            else
                quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client has commands in queue - must allow them to complete or remove each using S_CLEAR_COMMAND_CMD before S_SHUTDOWN_STATION_CMD');
            end
        else
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is not NO_RATRIX - must call S_STOP_TRIALS_CMD before S_SHUTDOWN_STATION_CMD');
        end
    case constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD
        if stat==constants.statuses.NO_RATRIX
            quit=updateRatrixRevisionIfNecessary(args);

            quitOnError=sendToServer(r,getClientId(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD,{quit});
            if quitOnError || quit
                quit=true;
            end
        else
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is not NO_RATRIX - must call S_STOP_TRIALS_CMD before S_UPDATE_SOFTWARE_CMD');
        end





        %commands that require a ratrix

    case constants.serverToStationCommands.S_GET_QUICK_REPORT_CMD
        if stat==constants.statuses.NO_RATRIX
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is NO_RATRIX - must call S_START_TRIALS_CMD(ratrix) before S_GET_QUICK_REPORT_CMD');
        else
            %C_RECV_REPORT_CMD
        end
    case constants.serverToStationCommands.S_STOP_TRIALS_CMD
        fprintf('handling stop trials from server\n')
        if stat==constants.statuses.NO_RATRIX
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is NO_RATRIX - must call S_START_TRIALS_CMD(ratrix) before S_STOP_TRIALS_CMD');
        else
            quit=true;
            sendAcknowledge(r,com); %even tho this just means the client is telling itself to stop trials, not that it is done.
            %rather than sending an ack here, may be better to always return the ratrix w/C_RECV_RATRIX_CMD
            %no actually, need to let session clean itself up.  the ratrix
            %will get sent by the line after doTrials in the handler for
            %start_trials
        end




        %commands that are OK regardless of status

    case constants.serverToStationCommands.S_GET_RATRIX_CMD

        quit=sendRatrixToServer(ratrixDataPath,r,constants);


    case constants.serverToStationCommands.S_GET_PENDING_COMMANDS_CMD
        %C_RECV_COMMAND_LIST_CMD
    case constants.serverToStationCommands.S_CLEAR_COMMAND_CMD
        %ack?
        %     case constants.serverToStationCommands.S_GET_TRIAL_RECORDS_CMD
        %         C_RECV_TRIAL_RECORDS_CMD

        %     case constants.serverToStationCommands.S_CLEAR_TRIAL_RECORDS_CMD
        %         go clear all records
        %         sendAcknowledge(r,com);
    case constants.serverToStationCommands.S_REPLICATE_TRIAL_RECORDS_CMD
%         paths=args{1};
        deleteOnSuccess=args{2};
        recordInOracle=1; %pmm -08/06/26
        replicateTrialRecords([],deleteOnSuccess, recordInOracle); %9/17/2008 - fli
        sendAcknowledge(r,com);
    case constants.serverToStationCommands.S_GET_RATRIX_BACKUPS_CMD
        %C_RECV_RATRIX_BACKUPS_CMD
    case constants.serverToStationCommands.S_CLEAR_RATRIX_BACKUPS_CMD
        %ack?
    case constants.serverToStationCommands.S_GET_STATUS_CMD
        fprintf('handling get status from server\n')
        quit=sendToServer(r,getClientId(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_STATUS_CMD,{stat});
    case constants.serverToStationCommands.S_GET_MAC_CMD
        fprintf('handling mac req\n')
        [success mac]=getMACaddress();
        if ~success
            mac
            mac=constants.errors.CANT_DETERMINE_MAC;
        end
        quit=sendToServer(r,getClientId(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_MAC_CMD,{mac});



        %commands that should always be handled elsewhere
    case constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
        quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD outside of a trial context');
    case {constants.serverToStationCommands.S_GET_VALVE_STATES_CMD constants.serverToStationCommands.S_SET_VALVES_CMD}
        %C_RECV_VALVE_STATES_CMD
        %C_VALVES_SET_CMD
        quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_GET_VALVE_STATES_CMD or S_SET_VALVES_CMD outside of a session context (a ratrix and station are needed to work valves)');
    otherwise
        quit=sendError(r,com,constants.errors.UNRECOGNIZED_COMMAND);
end

function quit=sendRatrixToServer(ratrixDataPath,r,constants)
try
    rx=ratrix(fullfile(ratrixDataPath, 'ServerData'),0); %load from file
catch ex
    noDBstr='no db at that location';
    if ~isempty(findstr(ex.message,noDBstr))
        rx=[];
    else
        ple(ex)
        rethrow(ex);
    end
end

quit=sendToServer(r,getClientId(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_RATRIX_CMD,{rx});