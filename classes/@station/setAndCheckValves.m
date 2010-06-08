function [endValveState valveErrorDetails]=setAndCheckValves(station, requestedValves,expectedValveState,valveErrorDetails,startTime,description,barebones)

if ~exist('barebones','var') || isempty(barebones)
    barebones=true;%false;
end

%[endValveState valveErrorDetails]=setAndCheckValves(station, requestedValves,expectedValveState,valveErrorDetails,startTime,description)
%
%set the valves to the requested value
%first check to make sure the valves are in the expected state
%if not, it logs an error

if strcmp(station.responseMethod,'parallelPort')
    if ~barebones
        %CHECK to see if the valves are as we expect
        beforeValveState=getValves(station);
        if ~all(beforeValveState==expectedValveState)
            disp('VALVE ERROR: LOGGING IT')
            errNum=size(valveErrorDetails,2)+1;
            valveErrorDetails(errNum).timeSinceTrial=GetSecs()-startTime;
            valveErrorDetails(errNum).expected=expectedValveState;
            valveErrorDetails(errNum).found=beforeValveState;
            valveErrorDetails(errNum).description=description;
        else
            %don't update
            %valveErrorDetails=valveErrorDetails;
        end
    end
    
    % DO IT
    setValves(station, requestedValves);
    
    if ~barebones
        %return the end state of the valves
        %If getValves is slow we could assume they are as requested
        endValveState=getValves(station);
        if any(endValveState~=requestedValves)
            endValveState=endValveState
            requestedValves=requestedValves
            error('valve setting failed')
            %it might be porttalk isn't installed
            %follw instructions: http://tech.groups.yahoo.com/group/psychtoolbox/message/4825
            %download from here: http://www.beyondlogic.org/porttalk/porttalk.htm
        end
    else
        endValveState=requestedValves;
    end
    
    
else
    if ~ismac
        warning('can''t check and set valves without parallel port')
    end
    endValveState=false(1,station.numPorts);
end