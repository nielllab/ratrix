function [endValveState valveErrorDetails]=setAndCheckValves(station, requestedValves,expectedValveState,valveErrorDetails,startTime,description)

%[endValveState valveErrorDetails]=setAndCheckValves(station, requestedValves,expectedValveState,valveErrorDetails,startTime,description)
%
%set the valves to the requested value
%first check to make sure the valves are in the expected state
%if not, it logs an error

if strcmp(station.responseMethod,'parallelPort')
    
    %CHECK to see if the valves are as we expect
    beforeValveState=getValves(station);
    if ~all(beforeValveState==expectedValveState)
        disp('VALVE ERROR: LOGGING IT')
        errNum=size(valveErrorDetails,2)+1;
        valveErrorDetails(errNum).timeSinceTrial=getSecs()-startTime;
        valveErrorDetails(errNum).expected=expectedValveState;
        valveErrorDetails(errNum).found=beforeValveState;
        valveErrorDetails(errNum).description=description;
    else
        %don't update
        %valveErrorDetails=valveErrorDetails;
    end

    % DO IT
    setValves(station, requestedValves)

    %return the end state of the valves 
    %If getValves is slow we could assume they are as requested
    endValveState=getValves(station); 
    if any(endValveState~=requestedValves)
        error('valve setting failed')
    end
    

else
    warning('can''t check and set valves without parallel port')
    endValveState=zeros(1,station.numPorts);
end

