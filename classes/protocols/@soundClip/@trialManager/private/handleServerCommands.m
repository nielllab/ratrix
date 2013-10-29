function [done quit valveErrorDetail serverValveStates serverValveChange response newValveState requestRewardDone requestRewardOpenCmdDone] ...
    = handleServerCommands(tm, rn, done, quit, requestRewardStarted, requestRewardStartLogged, requestRewardOpenCmdDone, ...
    requestRewardDone, station, ports, serverValveStates, doValves, response)

valveErrorDetail=[];
serverValveChange = false;

if ~isConnected(rn)
    done=true; %should this also set quit?
    quit=true; % 7/1/09 - also set quit (copied from v1.0.1)
end

constants=getConstants(rn);

%serverValveStates=currentValveState; %what was the purpose of this line?  serverValveStates should only be changed by SET_VALVES_CMD
%needed to remove, cuz was causing keyboard control to make valves stick open

while commandsAvailable(rn,constants.priorities.IMMEDIATE_PRIORITY) && ~done && ~quit
    %logwrite('handling IMMEDIATE priority command in stimOGL');
    if ~isConnected(rn)
        done=true;%should this also set quit?
        quit=true; % 7/1/09 - also set quit (copied from v1.0.1)
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



% Date: Sat, 29 Mar 2008 11:25:21 -0700 (PDT)
% From: Erik Flister <eflister@biomail.ucsd.edu>
% Subject: i am the king
% 
% after telling the server to shutdown:
% server tells station to STOP_TRIALS and this is ACKED
% server gives up waiting for client to send C_STOPPED_TRIALS
% server tells station to REPLCIATE.  this is ACKED.
% station emails me that it successfully has moved trialRecords to server and a 
% CLEAN directory listing
% server tells station to SHUTDOWN.
% station sends error to server -- must send STOP_TRIALS before SHUTDOWN
% 
% BOOM!  this is the problem: stimOGL's clientHandleVerifiedCommand call is only 
% setting the 'done' bit ("stop this trial") and NOT the 'quit' bit ("stop this 
% session") -- so "stopEarly" is not getting sent back up the doTrial chain.  the 
% STOP_TRIALS is acked by the handler, but TRIALS CONTINUE.  at some point, the 
% server gets tired of waiting, and asks for REPLICATE.
% 
% either stimOGL or trialManager.doTrial handles the REPLICATE -- which works, 
% and emails me evidence that it did.  whichever one handles it, the trialRecords 
% are still in memory, and so get REWRITTEN out to the directory as soon as the 
% trial is over.  trials continue even after the SHUTDOWN command, which is 
% rejected because trials haven't stopped.  they continue until the server itself 
% finishes shutting down everyone else and kills the connection at which time the 
% client finally dies.
% 
% now there is a slightly longer and redundant trialRecords sitting there waiting 
% to get uploaded next time the station starts up.  gar.
% 
% the only thing i can't figure out is why this doesnt' happen everytime? it only 
% rarely happens.  it must be that usually it is the trialManager's (correctly 
% written) doTrial that handles the initial STOP TRIAL command -- i don't know 
% how this can be since we spend most of our time in stimOGL. my best explanation 
% is that we actually wind up spending a lot of time in doTrial loading trial 
% records, especially towards the end of sessions. this would explain why it's 
% much more common when i'm using the system (frequently bringing it up/down 
% while testing) to see the error, than when it is in actual use (and building up 
% large trialRecords before being shut down).