function [r rx]=remoteClientShutdown(r,c,rx,subjects)

constants=r.constants;

fprintf('shutting down %s\n',c.id.toCharArray()) %need a matlab wrapper around RatrixNetworkNodeIdent to expose this
timeout=10.0;

[quit com]=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_GET_STATUS_CMD,{});
if ~quit
    [quit statCom statCmd statCmdArgs]=waitForSpecificCommand(r,c,constants.stationToServerCommands.C_RECV_STATUS_CMD,timeout,'waiting for client response to S_GET_STATUS_CMD',[]);
end
if ~quit
    if any([isempty(statCom) isempty(statCmd) isempty(statCmdArgs)])
        quit=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD,{});
        warning('Client timedout for status request in remoteClientShutdown()');
    else
        stat=statCmdArgs{1};
        switch stat
            case {constants.statuses.MID_TRIAL constants.statuses.IN_SESSION_BETWEEN_TRIALS constants.statuses.BETWEEN_SESSIONS}
                [quit com]=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_STOP_TRIALS_CMD,{});

                if ~quit
                    quit=waitForAck(r,com,timeout,'waiting for ack to stop_trials');
                end

                if ~quit
                    [quit stopCom stopCmd stopArgs]=waitForSpecificCommand(r,c,constants.stationToServerCommands.C_STOPPED_TRIALS,timeout,'waiting for client response (with ratrix) to already acked S_STOP_TRIALS_CMD (C_STOPPED_TRIALS)',[]);
                    %get ratrix, merge
                    if ~quit && ~isempty(rx)
                        [rx quit] = updateRatrixFromClientRatrix(r,rx,c);
                    end
                end

            case constants.statuses.NO_RATRIX
                if ~isempty(rx)
                    %get ratrix, merge (could pass in)
                    [rx quit] = updateRatrixFromClientRatrix(r,rx,c);
                end
            otherwise
                error('bad status')
        end
        if ~quit
            if ~isempty(rx)
                quit=replicateClientTrialRecords(r,c,[]);
            end

            [quit com]=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD,{});

            if ~quit
                quit=waitForAck(r,com,timeout,'waiting for ack to shutdown_station');
            end
        end

    end
end

if quit
    warning('Got a quit in remote client shutdown')
end

if clientIsRegistered(r,c)
    [r rx]=unregisterClient(r,c,rx,subjects);
    disconnectClient(r,c);
end