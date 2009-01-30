function [requestRewardPorts requestRewardDone newValveState station] = setupLocalTimedAndLocalPumpRewards(tm, requestRewardStarted, ...
  requestRewardStartLogged, requestRewardDone, responseDetails, requestRewardPorts, doValves, ...
  station, ifi)
  
  % This function handles the localTimed and localPump reward methods.
  % Part of stimOGL rewrite.
  % INPUT: tm, requestRewardStarted, requestRewardStartLogged, requestRewardDone, responseDetails, 
  %     requestRewardPorts, doValves, station, ifi
  % OUTPUT: requestRewardPorts, requestRewardDone, newValveState, station
  
if strcmp(getRewardMethod(station),'localTimed')       
    if requestRewardStarted && requestRewardStartLogged && ~requestRewardDone
        if 1000*(GetSecs()-responseDetails.requestRewardStartTime) >= getRequestRewardSizeULorMS(tm)
            requestRewardPorts=0*requestRewardPorts;
            requestRewardDone=true;
        end
    end
    newValveState=doValves|requestRewardPorts;


elseif strcmp(getRewardMethod(station),'localPump')

    if requestRewardStarted && ~requestRewardDone && requestRewardStartLogged
        station=doReward(station,getRequestRewardSizeULorMS(tm)/1000,requestRewardPorts);
        requestRewardDone=true;
    end

    if any(doValves)
        primeMLsPerSec=1.0;
        station=doReward(station,primeMLsPerSec*ifi,doValves,true);
    end

    newValveState=0*doValves;
end

end % end function