function [currentValveState valveErrorDetails quit serverValveChange responseDetails requestRewardStartLogged requestRewardDurLogged] = ...
  setupServerPumpRewards(tm, rn, station, newValveState, currentValveState, valveErrorDetails, startTime, serverValveChange, ...
  requestRewardStarted, requestRewardStartLogged, requestRewardPorts, requestRewardDone, requestRewardDurLogged, responseDetails, quit)

% This function sets up the serverPump reward method.
% Part of stimOGL rewrite.
% INPUT: tm, rn, station, newValveState, currentValveState, valveErrorDetails, startTime, serverValveChange,
%   requestRewardStarted, requestRewardStartLogged, requestRewardPorts, requestRewardDone, requestRewardDurLogged, responseDetails, quit
% OUTPUT: currentValveState, valveErrorDetails, quit, serverValveChange, responseDetails, requestRewardStartLogged, requestRewardDurLogged

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
    %'request reward!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    requestRewardStartLogged=true;
end

if  requestRewardDone && ~requestRewardDurLogged
    responseDetails.requestRewardDurationActual=GetSecs()-responseDetails.requestRewardStartTime;
    %'request reward stopped!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    requestRewardDurLogged=true;
end

end % end function