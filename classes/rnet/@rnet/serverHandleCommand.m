function [sys r rx]=serverHandleCommand(r,com,sys,rx,subjects)

%fprintf('Server recieved: %s remaining %d\n', toString(com),commandsAvailable(r,{},getSendingNodeId(com)));
constants = getConstants(r);
client = getSendingNode(com);
[good cmd args] = validateCommand(r,com);

if good
    switch cmd
        case constants.stationToServerCommands.C_CMD_ACK
            error('received unexpected ACK')
        case constants.stationToServerCommands.C_CMD_ERR
            errType = args{1};
            errString = args{2};
            fprintf('Error Recived from %s: [%d] %s',toString(com),errType,errString);
            error('client sent an error')
%         case constants.stationToServerCommands.C_RECV_TRIAL_RECORDS_CMD
%             error('unexpected C_RECV_TRIAL_RECORDS_CMD')
        case constants.stationToServerCommands.C_RECV_RATRIX_CMD
            error('unexpected C_RECV_RATRIX_CMD')
        case constants.stationToServerCommands.C_RECV_RATRIX_BACKUPS_CMD
            error('unexpected C_RECV_RATRIX_BACKUPS_CMD')
        case constants.stationToServerCommands.C_RECV_STATUS_CMD
            error('unexpected C_RECV_STATUS_CMD')
        case constants.stationToServerCommands.C_RECV_REPORT_CMD
            error('unexpected C_RECV_REPORT_CMD')
        case constants.stationToServerCommands.C_RECV_VALVE_STATES_CMD
            error('unexpected C_RECV_VALVE_STATES_CMD')
        case constants.stationToServerCommands.C_RECV_COMMAND_LIST_CMD
            error('unexpected C_RECV_COMMAND_LIST_CMD')
        case constants.stationToServerCommands.C_REWARD_CMD
            if isa(sys,'pumpSystem')
                rewardTimeout = 20.0; %figure out where to store this
                ulRewardSize=args{1};
                valveStates=args{2};
                isPrime=false;
                [sys r]=rewardClient(r,client,ulRewardSize,valveStates,rewardTimeout,isPrime,sys);
            else
                error('got a reward request for a server that doesn''t serve a pump')
            end
        case constants.stationToServerCommands.C_VALVES_SET_CMD
            error('unexpected C_VALVES_SET_CMD')
        case constants.stationToServerCommands.C_UPDATE_SOFTWARE_ON_TARGETS_CMD
            % Update software on all stations
            clients = listClients(r);
            fprintf('Sending update software command to all clients');
            for i=1:length(clients)
                updateClient = clients(i);
                quit=sendToClient(r,updateClient,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD,{});
            end
            % Now update the software on the server
            fprintf('Now updating the software on the server');
            r=svnUpdate(r);

            %shouldn't we check for an ACK from the client?  except it's
            %shutting down...
        case constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD
            error('unexpected C_RECV_UPDATING_SOFTWARE_CMD')
        case r.constants.stationToServerCommands.C_STOPPED_TRIALS
            warning('unexpected C_STOPPED_TRIALS - client has chosen to change svn revision, graduated, or has a serious problem')
            %args{1} %possible issue -- we get the rx here, but would
            %rather ask again in shutdown, but if that fails we lost a good chance to get it.  possibly merge here? 
            [r rx]=remoteClientShutdown(r,client,rx,subjects); %handles merge,replication,unregister,disconnect
        otherwise
            error('Unknown command received');
    end
end