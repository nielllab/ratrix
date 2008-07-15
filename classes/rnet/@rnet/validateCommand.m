function [good cmd args] = validateCommand(r,c)

if isempty(c)
    good=false;
    cmd=[];
    args=[];
    return
end

if ~isa(c,'rnetcommand') %~strcmp(class(c),'rnetcommand') %does isa not work for java objects?
    error('com must be a rnetcommand')
end

constants = getConstants(r);
cmd = getCommand(c);
args = getArguments(c);
good = true;



switch r.type
    case r.constants.nodeTypes.SERVER_TYPE

        client = getSendingNode(c);

        [tf loc]=clientIsRegistered(r,client);
        if tf
            mac=r.serverRegister{loc,2};
        else
            mac='unregistered client';
        end


        switch cmd
            case constants.stationToServerCommands.C_CMD_ACK
                if length(args) ~= 1 || ~isscalar(args{1}) || args{1}<=0 || ~isnumeric(args{1}) %|| ~isinteger(args{1}) %should really check that it's an integer, but packageArguments hasn't been fixed yet to preserve numeric types properly...
                    good=false;
                    args{1}
                    class(args{1})
                    error('Usage: C_CMD_ACK(commandUID)');
                end
            case constants.stationToServerCommands.C_CMD_ERR
                if length(args) ~= 2 || ~isValidError(r,args{1}) || ~ischar(args{2})
                    good=false;
                    error('Usage: C_CMD_ERR(rnet.constants.errors.*,string)');
                end
%             case constants.stationToServerCommands.C_RECV_TRIAL_RECORDS_CMD
%                 if how pass file?
%                     error('Usage: C_RECV_TRIAL_RECORDS_CMD(?)')
%                 end
            case constants.stationToServerCommands.C_RECV_RATRIX_CMD
                if length(args) ~=1 || ~(isa(args{1},'ratrix') || isempty(args{1}))
                    error('Usage: C_RECV_RATRIX_CMD(ratrix)   (ratrix may be [])')
                end
            case constants.stationToServerCommands.C_RECV_RATRIX_BACKUPS_CMD
            case constants.stationToServerCommands.C_RECV_STATUS_CMD
                if ~(length(args)==1 && isValidStatus(r,args{1}))
                    error('Usage: C_RECV_STATUS_CMD(status)')
                end
            case constants.stationToServerCommands.C_RECV_REPORT_CMD
            case constants.stationToServerCommands.C_RECV_VALVE_STATES_CMD
            case constants.stationToServerCommands.C_RECV_COMMAND_LIST_CMD
            case constants.stationToServerCommands.C_REWARD_CMD
                if ~(length(args)==2 && isreal(args{1}) && isscalar(args{1}) && args{1}>=0 && islogical(args{2}) && isvector(args{2}))
                    good=false;
                    error('Usage: C_REWARD_CMD(double ulRewardSize >=0,logical vector valvestates)');
                end
            case constants.stationToServerCommands.C_VALVES_SET_CMD
                if ~(ismember(length(args),[1 2]) && islogical(args{1}) && isvector(args{1}) && (length(args)==1 || (isscalar(args{2}) && isfloat(args{2}) && args{2}>0)))
                    good=false;
                    error('Usage: C_VALVES_SET_CMD(logical vector valvestates[, double waitTime])')
                end
            case constants.stationToServerCommands.C_UPDATE_SOFTWARE_ON_TARGETS_CMD
                if ~isempty(args)
                    good=false;
                    error('Usage: C_UPDATE_SOFTWARE_ON_TARGETS_CMD(void)')
                end
            case constants.stationToServerCommands.C_RECV_MAC_CMD
                if ~(length(args)==1 && (isMACaddress(args{1}) || args{1}==constants.errors.CANT_DETERMINE_MAC))
                    good=false;
                    error('Usage: C_RECV_MAC_CMD(MACaddress)')
                end
            case constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD
                if length(args)~=1 || ~islogical(args{1}) || ~isscalar(args{1})
                    good=false;
                    error('Usage: C_RECV_CURR_VERSION_CMD(booleanRestarting)')
                end
            case r.constants.stationToServerCommands.C_STOPPED_TRIALS
                if length(args) ~=1 || ~isa(args{1},'ratrix')
                    error('Usage: C_RECV_RATRIX_CMD(ratrix)')
                end
            otherwise
                good=false;
                error('received unrecognized command')
        end
    case r.constants.nodeTypes.CLIENT_TYPE

        mac='server';


        switch cmd
            case constants.serverToStationCommands.S_START_TRIALS_CMD
                if length(args)~=1 || ~isa(args{1},'ratrix')
                    good=false;
                    sendError(r,c,constants.errors.BAD_ARGS,'usage: S_START_TRIALS_CMD(Ratrix)');
                end
            case constants.serverToStationCommands.S_STOP_TRIALS_CMD
%             case constants.serverToStationCommands.S_GET_TRIAL_RECORDS_CMD
%                 if ~isempty(args)
%                     good=false;
%                     sendError(r,c,constants.errors.BAD_ARGS,'usage: S_GET_TRIAL_RECORDS_CMD(void)');
%                 end
%             case constants.serverToStationCommands.S_CLEAR_TRIAL_RECORDS_CMD
%                 if ~isempty(args)
%                     good=false;
%                     sendError(r,c,constants.errors.BAD_ARGS,'usage: S_CLEAR_TRIAL_RECORDS_CMD(void)');
%                 end
            case constants.serverToStationCommands.S_REPLICATE_TRIAL_RECORDS_CMD
                args
                args{1}
                if length(args)==2 && iscell(args{1}) && isvector(args{1}) && ~isempty(args{1}) && isscalar(args{2}) && islogical(args{2})
                    for i=1:length(args{1})
                        if ~ischar(args{1}{i})
                            'not char'
                            sendError(r,c,constants.errors.BAD_ARGS,'paths should be strings');
                            good=false;
                        else
%                             d=remoteDir(args{1}{i});
%                             d
%                             if isempty(d) %even an empty dir has 2 entires -- '.' and '..'
%                                 'd was empty'
%                                 sendError(r,c,constants.errors.BAD_ARGS,['can''t find path: ' args{1}{i}]);
%                                 good=false;
%                             end
                            
                            if ~isDirRemote(args{1}{i}) %not safe due to windows networking/filesharing bug -- if this causes lots of crashes (will bring down whole server/rack), consider not checking at all (or just checking for char vector), rely on the replication function doing the check
                                'cant see dir'
                                args{1}{i}
                                sendError(r,c,constants.errors.BAD_ARGS,['can''t find path: ' args{1}{i}]);
                                good=false;
                            end
                        end
                    end
                else
                    'bad args'
                    good=false;
                    sendError(r,c,constants.errors.BAD_ARGS,'Usage: S_REPLICATE_TRIAL_RECORDS_CMD({destination paths},bool deleteOnSuccess)')
                end
                good
            case constants.serverToStationCommands.S_GET_STATUS_CMD
            case constants.serverToStationCommands.S_GET_RATRIX_CMD
                if ~isempty(args)
                    sendError(r,c,constants.errors.BAD_ARGS,'usage: S_GET_RATRIX_CMD(void)');
                end
            case constants.serverToStationCommands.S_GET_RATRIX_BACKUPS_CMD
            case constants.serverToStationCommands.S_CLEAR_RATRIX_BACKUPS_CMD
            case constants.serverToStationCommands.S_GET_QUICK_REPORT_CMD
            case constants.serverToStationCommands.S_SET_VALVES_CMD
                if length(args)~=2 || ~islogical(args{1}) || ~isvector(args{1}) || ~islogical(args{2}) || ~isscalar(args{2})
                    good=false;
                    sendError(r,c,constants.errors.BAD_ARGS,'usage: S_SET_VALVES_CMD(logical vector valvestates, logical isPrime)');
                end
            case constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD
                if ~isempty(args)
                    good=false;
                    sendError(r,c,constants.errors.BAD_ARGS,'usage: S_SHUTDOWN_STATION_CMD(void)');
                end
            case constants.serverToStationCommands.S_GET_PENDING_COMMANDS_CMD
            case constants.serverToStationCommands.S_CLEAR_COMMAND_CMD
            case constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD
                if length(args) > 1 || (length(args)==1 && ~((ischar(args{1}) && all(args{1}(1:6)=='svn://')) || (isinteger(args{1}) && args{1}>0)))
                    good=false;
                    sendError(r,c,constants.errors.BAD_ARGS,'usage: S_UPDATE_SOFTWARE_CMD([revision_number|svn url(ex: ''svn://132.239.158.177/tags/v0.5'')])');
                end
            case constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
            case constants.serverToStationCommands.S_GET_MAC_CMD
                if ~isempty(args)
                    good=false;
                    sendError(r,c,constants.errors.BAD_ARGS,'usage: S_GET_MAC_CMD(void)');
                end
            case constants.serverToStationCommands.S_GET_VALVE_STATES_CMD
            otherwise
                good=false;
                sendError(r,c,constants.errors.UNRECOGNIZED_COMMAND);
        end
    otherwise
        good=false;
        error('Unknown rnet.type value');
end

if good
    outstr='validated!';
else
    outstr='failed validation!';
end

f=fopen('cmdLog.txt','a');
fprintf(f,'%s: got command %d (from %s): %s\n',datestr(now),cmd,mac,outstr);
fclose(f);
