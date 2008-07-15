switch getRewardMethod(station)
    case 'localTimed'
        if requestRewardStarted && requestRewardStartLogged && ~requestRewardDone
            if 1000*(GetSecs()-responseDetails.requestRewardStartTime) >= getRequestRewardSizeULorMS(tm)
                requestRewardPorts=0*requestRewardPorts;
                requestRewardDone=true;
            end
        end
        newValveState=doValves|requestRewardPorts;
    case 'serverPump'
        serverValveStates=currentValveState;
        while commandsAvailable(rn,constants.priorities.IMMEDIATE_PRIORITY) && ~done && ~quit
            logwrite('handling IMMEDIATE priority command in stimOGL');
            if ~isConnected(r)
                done=true;
            end
            com=getNextCommand(rn,constants.priorities.IMMEDIATE_PRIORITY);
            [good cmd args]=validateCommand(rn,com);
            logwrite(sprintf('command is %d',cmd));
            if good
                switch cmd


                    case constants.serverToStationCommands.S_SET_VALVES_CMD
                        isPrime=args{2};
                        if isPrime
                            if reqeustRewardStarted && ~requestRewardDone
                                quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received priming S_SET_VALVES_CMD while a non-priming request reward was unfinished');
                            else
                                timeout=-1;
                                [quit valveErrorDetails(end+1)]=clientAcceptReward(rn,...
                                    com,...
                                    station,...
                                    timeout,...
                                    valveStart,...
                                    requestedValveState,...
                                    [],...
                                    isPrime);
                                if quit
                                    done=true;
                                end
                            end
                        else
                            if all(size(ports)==size(args{1}))

                                serverValveStates=args{1};
                                serverValveChange=true;

                                if reqeustRewardStarted && requestRewardStartLogged && ~requestRewardDone
                                    if requestRewardOpenCmdDone
                                        if all(~serverValveStates)
                                            requestRewardDone=true;
                                        else
                                            quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received S_SET_VALVES_CMD for closing request reward but not all valves were indicated to be closed');
                                        end
                                    else
                                        if all(serverValveStates==requestRewardPorts)
                                            requestRewardOpenCmdDone=true;
                                        else
                                            quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received S_SET_VALVES_CMD for opening request reward but wrong valves were indicated to be opened');
                                        end
                                    end
                                else
                                    quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received unexpected non-priming S_SET_VALVES_CMD');
                                end
                            else
                                quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received inappropriately sized S_SET_VALVES_CMD arg');
                            end
                        end


                    case constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
                        if requestRewardDone
                            quit=sendAcknowledge(rn,com);
                        else
                            if requestRewardStarted
                                quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD apparently not preceeded by open and close S_SET_VALVES_CMD''s');
                            else
                                quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD not preceeded by C_REWARD_CMD (MID_TRIAL)');
                            end
                        end
                    otherwise
                        done=clientHandleVerifiedCommand(rn,com,cmd,args,constants.statuses.MID_TRIAL);
                        if done
                            response='server kill';
                        end
                end
            end
        end
        newValveState=doValves|serverValveStates;
    otherwise
        error('bad reward method')
end

[currentValveState valveErrorDetails]=setAndCheckValves(station,newValveState,currentValveState,valveErrorDetails,startTime,'frame cycle valve update');

if serverValveChange
    quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_VALVES_SET_CMD,{currentValveState});
    serverValveChange=false;
end

if requestRewardStarted && ~requestRewardStartLogged
    if strcmp(getRewardMethod(station),'serverPump')
        quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{getRequestRewardSizeULorMS(tm),logical(requestRewardPorts)});
    end
    responseDetails.requestRewardStartTime=GetSecs();
    'request reward!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    requestRewardStartLogged=true;
end

if  requestRewardDone && ~requestRewardDurLogged
    responseDetails.requestRewardDurationActual=GetSecs()-responseDetails.requestRewardStartTime;
    'request reward stopped!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    requestRewardDurLogged=true;
end

%before can end, must make sure any request rewards are done so
%that the valves will be closed.  this includes server reward
%requests.  right now there is a bug if the response occurs before
%the request reward is over.