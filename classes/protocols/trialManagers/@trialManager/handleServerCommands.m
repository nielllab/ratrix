function [done quit valveErrorDetail serverValveStates serverValveChange response newValveState requestRewardDone requestRewardOpenCmdDone] ...
   = handleServerCommands(tm, rn, done, quit, requestRewardStarted, requestRewardStartLogged, requestRewardOpenCmdDone, ...
   requestRewardDone, station, ports, serverValveStates, doValves, response, newValveState)

% This function handles server (rnet) commands that can override automatic trials.
% Part of stimOGL rewrite.
% INPUT: rn, constants, done, quit, requestRewardStarted, requestRewardStartLogged, requestRewardOpenCmdDone, 
%           requestRewardDone, station, ports, serverValveStates, doValves, response, newValveState
% OUTPUT: done, quit, valveErrorDetail, serverValveStates, serverValveChange, response, newValveState, requestRewardDone, requestRewardOpenCmdDone

valveErrorDetail=[];
serverValveChange = false;


if ~isConnected(rn)
    done=true; %should this also set quit?
end

constants=getConstants(rn);


%serverValveStates=currentValveState; %what was the purpose of this line?  serverValveStates should only be changed by SET_VALVES_CMD
%needed to remove, cuz was causing keyboard control to make valves stick open

while commandsAvailable(rn,constants.priorities.IMMEDIATE_PRIORITY) && ~done && ~quit
    %logwrite('handling IMMEDIATE priority command in stimOGL');
    if ~isConnected(rn)
        done=true;%should this also set quit?
    end
    com=getNextCommand(rn,constants.priorities.IMMEDIATE_PRIORITY);
    if ~isempty(com)
        [good cmd args]=validateCommand(rn,com);
        %logwrite(sprintf('command is %d',cmd));
        if good
            switch cmd



                case constants.serverToStationCommands.S_SET_VALVES_CMD
                    isPrime=args{2};
                    if isPrime
                        if requestRewardStarted && ~requestRewardDone
                            quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received priming S_SET_VALVES_CMD while a non-priming request reward was unfinished');
                        else
                            timeout=-1;
                            [quit valveErrorDetail]=clientAcceptReward(rn,...
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

                            if requestRewardStarted && requestRewardStartLogged && ~requestRewardDone
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
                    %the following lines referred to 'done' rather than 'quit' -- this is the bug that leads to the 'i am the king' bug?
                    quit=clientHandleVerifiedCommand(rn,com,cmd,args,constants.statuses.MID_TRIAL);
                    if quit
                        response='server kill';
                    end
            end
        end
    end
end
newValveState=doValves|serverValveStates;



end % end function