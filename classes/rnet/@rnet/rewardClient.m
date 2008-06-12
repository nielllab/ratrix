function [sys r]=rewardClient(r,client,ulRewardSize,valveStates,rewardTimeout,isPrime,sys)
constants=r.constants;

quit=sendToClient(r,client,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_SET_VALVES_CMD,{valveStates,isPrime});

if ~quit
    %wait for confirmation, confirm correct valves, send reward, ask client to close valves
    [quit confirmation confirmationCmd confirmationArgs]=waitForSpecificCommand(r,client,constants.stationToServerCommands.C_VALVES_SET_CMD,rewardTimeout,'waiting for client response to S_SET_VALVES_CMD',[]);
end
if quit
    'Got a quit in reward client'
    return
end

if any([isempty(confirmation) isempty(confirmationCmd) isempty(confirmationArgs)])
    error('timed out waiting for client response to opener C_VALVES_SET_CMD')
end

if all(size(valveStates)==size(confirmationArgs{1}))
    actualStates=confirmationArgs{1};
    waitTime=confirmationArgs{2};
    if valveStateMatch(valveStates,actualStates)
        %do pump of ulRewardSize
        sys=doReward(sys,ulRewardSize/1000,getZoneForClient(r,client));

        allClosed=false(size(valveStates));
        quit=sendToClient(r,client,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_SET_VALVES_CMD,{allClosed,isPrime}); %hmm, OK to assume all closed?  our plumbing depends on it...
        if ~quit
            %wait for confirmation of close, confirm correct values, send reward complete, wait for final ack
            [quit closeConfirm closeConfirmCmd closeConfirmArgs]=waitForSpecificCommand(r,client,constants.stationToServerCommands.C_VALVES_SET_CMD,rewardTimeout,'waiting for client response to S_SET_VALVES_CMD',[]);
        end
        if quit
            'Got a quit in reward client'
            return
        end

        if any([isempty(closeConfirm) isempty(closeConfirmCmd) isempty(closeConfirmArgs)])
            error('timed out waiting for client response to closer C_VALVES_SET_CMD')
        end

        if all(size(valveStates)==size(closeConfirmArgs{1}))
            actualStates=closeConfirmArgs{1};
            rewardDur=closeConfirmArgs{2};
            
            if valveStateMatch(allClosed,actualStates)
                if ~isPrime
                    [quit complete]=sendToClient(r,client,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_REWARD_COMPLETE_CMD,{});
                    if ~quit
                        quit=waitForAck(r,complete,rewardTimeout,'waiting for ack from reward_complete');
                    end
                    if quit
                        return
                    end

                    [tf loc]=clientIsRegistered(r,client);
                    if ~tf
                        error('that client doesn''t exist in the register')
                    else
                        r.serverRegister{loc,4}=[r.serverRegister{loc,4} waitTime];
                        r.serverRegister{loc,5}=[r.serverRegister{loc,5} rewardDur];
                        for i=1:size(r.serverRegister,1)
                            macs{i}=r.serverRegister{i,2}(end-3:end);
                            waitTimes(i)=mean(r.serverRegister{i,4});
                            rewardDurs(i)=mean(r.serverRegister{i,5});
                            rewardCounts(i)=length(r.serverRegister{i,4});
                        end

                        format short g
                        macs
                        rewardCounts
                        waitTimes
                        rewardDurs
                        format long g
                    end

                end
            else
                error('C_VALVES_SET_CMD response to S_SET_VALVES_CMD close request was not compatible with requested valve states')
            end
        else
            error('wrong vector length of valve states back from C_VALVES_SET_CMD in response to close request')
        end
    else
        error('C_VALVES_SET_CMD response to S_SET_VALVES_CMD open request was not compatible with requested valve states')
    end
else
    error('wrong vector length of valve states back from C_VALVES_SET_CMD in response to open request')
end