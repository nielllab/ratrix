function [quit valveErrorDetails latencyToOpenValves latencyToCloseValveRecd latencyToCloseValves actualRewardDuration latencyToRewardCompleted latencyToRewardCompletelyDone]= ...
    clientAcceptReward(rn,com,station,timeout,refTime,requestedValveState,expectedRequestedValveState,isPrime)

currentValveState=verifyValvesClosed(station);
allClosed=currentValveState;
constants=rn.constants;
doReward=true;
latencyToRewardCompleted = nan;
latencyToRewardCompletelyDone = nan;
valveErrorDetails=[];
quit=false;

if length(requestedValveState) == getNumPorts(station)
    'got good accept reward'
    if isPrime
        if ~any(requestedValveStates)
            sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'server sent priming open S_SET_VALVES_CMD with no open valve states');
            doReward=false;
        end
    elseif ~valveStateMatch(requestedValveState,expectedRequestedValveState)
        sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'server S_SET_VALVES_CMD response to C_REWARD_CMD was not compatible with requested valve states')
        doReward=false;
    end

    if doReward
        'got into do reward'
        [currentValveState valveErrorDetails]=setAndCheckValves(station,requestedValveState,currentValveState,valveErrorDetails,refTime,'opening valves');
        latencyToOpenValves=GetSecs()-refTime;
        quit = sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_VALVES_SET_CMD,{currentValveState,latencyToOpenValves});
        if ~quit
            [quit closeValveCom closeValveCmd closeValveCmdArgs]=waitForSpecificCommand(rn,[],constants.serverToStationCommands.S_SET_VALVES_CMD,timeout,'waiting for server close valve S_SET_VALVES_CMD',constants.statuses.MID_TRIAL);
        end
        if quit
            'got quit'
            
            %note -- leaving valves open cuz server told me to quit in the
            %middle of delivering water to me and never told me to close my
            %valves.  so i am basically a leak at this point.
            
            latencyToCloseValveRecd =nan;
            latencyToCloseValves  =nan;
            actualRewardDuration  =nan;
            latencyToRewardCompleted  =nan;
            latencyToRewardCompletelyDone =nan;
            
        else
            'got past quit'
            
            latencyToCloseValveRecd=GetSecs()-refTime;
            if length(closeValveCmdArgs{1}) == getNumPorts(station)
                requestedValveState=closeValveCmdArgs{1};
                if isPrime==closeValveCmdArgs{2}
                    if valveStateMatch(requestedValveState,allClosed)
                        'got to lowest level'
                        
                        [currentValveState valveErrorDetails]=setAndCheckValves(station,requestedValveState,currentValveState,valveErrorDetails,refTime,'closing valves');
                        latencyToCloseValves=GetSecs()-refTime;
                        actualRewardDuration = latencyToCloseValves-latencyToOpenValves;
                        quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_VALVES_SET_CMD,{currentValveState,actualRewardDuration});
                        if ~isPrime
                            'got to lowest level not prime'
                            if ~quit
                                [quit rewardCompleteCom rewardCompleteCmd rewardCompleteCmdArgs]=waitForSpecificCommand(rn,[],constants.serverToStationCommands.S_REWARD_COMPLETE_CMD,timeout,'waiting for server reward complete command',constants.statuses.MID_TRIAL);
                            end
                            if quit
                                latencyToRewardCompleted=nan;
                                latencyToRewardCompletelyDone=nan;
                            else
                                latencyToRewardCompleted=GetSecs()-refTime;
                                sendAcknowledge(rn,rewardCompleteCom);
                                latencyToRewardCompletelyDone=GetSecs()-refTime;
                            end
                        end
                        'all done with reward'
                    else
                        sendError(rn,closeValveCom,constants.errors.CORRUPT_STATE_SENT,'client received closer S_SET_VALVES_CMD that was not all zeros')
                    end
                else
                    sendError(rn,closeValveCom,constants.errors.CORRUPT_STATE_SENT,'client received closer S_SET_VALVES_CMD that did not match priming of opener');
                end
            else
                sendError(rn,closeValveCom,constants.errors.CORRUPT_STATE_SENT,'client received inappropriately sized closer S_SET_VALVES_CMD arg');
            end
        end
    else
        'failed do reward!'
    end
else
    sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'client received inappropriately sized opener S_SET_VALVES_CMD arg');
end