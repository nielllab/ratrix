function [currentValveState valveErrorDetails quit serverValveChange responseDetails requestRewardStartLogged requestRewardDurLogged phaseRecord] ...
    = serverPumpRewards(tm, rn, station, newValveState, currentValveState, valveErrorDetails, startTime, serverValveChange, ...
    requestRewardStarted, requestRewardStartLogged, requestRewardPorts, requestRewardDone, requestRewardDurLogged, responseDetails, quit, phaseRecord)

%this hasn't been debugged since moving reward handling to inside stimOGL -- used to be in doTrial
%things like stopEarly need to quit loop immediately and get passed back out to doTrial
%and rnet errors need to set a response code so we don't think this was a passive viewing stim with a none response
%rewardSizeULorMS and getRequestRewardSizeULorMS need to be fixed
%rewardValves may be requestRewardPorts --
%names should be changed, this doesn't just handle requests...
error('needs updating')

[currentValveState valveErrorDetails]=setAndCheckValves(station,newValveState,currentValveState,valveErrorDetails,startTime,'frame cycle valve update');

if ~isempty(rn) && isConnected(rn)
    constants=getConstants(rn);
end

if serverValveChange
    quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_VALVES_SET_CMD,{currentValveState});
    serverValveChange=false;
end

if requestRewardStarted && ~requestRewardStartLogged
    if strcmp(getRewardMethod(station),'serverPump')
        quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{getRequestRewardSizeULorMS(tm),logical(requestRewardPorts)});
    end
    responseDetails.requestRewardStartTime=GetSecs();
    requestRewardStartLogged=true;
end

if  requestRewardDone && ~requestRewardDurLogged
    responseDetails.requestRewardDurationActual=GetSecs()-responseDetails.requestRewardStartTime;
    requestRewardDurLogged=true;
end

valveStart=GetSecs();
timeout=-5.0;

sprintf('*****should be no output between here *****')

stopEarly=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{rewardSizeULorMS,logical(rewardValves)});
rewardDone=false;
while ~rewardDone && ~stopEarly
    [stopEarly openValveCom openValveCmd openValveCmdArgs]=waitForSpecificCommand(rn,[],constants.serverToStationCommands.S_SET_VALVES_CMD,timeout,'waiting for server open valve response to C_REWARD_CMD',constants.statuses.MID_TRIAL);
    
    if stopEarly
        'got stopEarly 2'
    end
    
    if ~stopEarly
        
        if any([isempty(openValveCom) isempty(openValveCmd) isempty(openValveCmdArgs)])
            error('waitforspecificcommand acted like it got a stop early even though it says it didn''t')
        end
        
        requestedValveState=openValveCmdArgs{1};
        isPrime=openValveCmdArgs{2};
        
        if ~isPrime
            rewardDone=true;
            phaseRecord.latencyToOpenValveRecd=GetSecs()-valveStart;
            
            [stopEarly phaseRecord.valveErrorDetails,...
                phaseRecord.latencyToOpenValves,...
                phaseRecord.latencyToCloseValveRecd,...
                phaseRecord.latencyToCloseValves,...
                phaseRecord.actualRewardDuration,...
                phaseRecord.latencyToRewardCompleted,...
                phaseRecord.latencyToRewardCompletelyDone]...
                =clientAcceptReward(...
                rn,...
                openValveCom,...
                station,...
                timeout,...
                valveStart,...
                requestedValveState,...
                rewardValves,...
                isPrime);
            
            if stopEarly
                'got stopEarly 3'
            end
            
        else
            
            [stopEarly phaseRecord.primingValveErrorDetails(end+1),...
                phaseRecord.latencyToOpenPrimingValves(end+1),...
                phaseRecord.latencyToClosePrimingValveRecd(end+1),...
                phaseRecord.latencyToClosePrimingValves(end+1),...
                phaseRecord.actualPrimingDuration(end+1),...
                garbage,...
                garbage]...
                =clientAcceptReward(...
                rn,...
                openValveCom,...
                station,...
                timeout,...
                valveStart,...
                requestedValveState,...
                [],...
                isPrime);
            
            if stopEarly
                'got stopEarly 4'
            end
        end
    end
    
end

sprintf('*****and here *****')

end % end function