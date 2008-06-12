function [quit out]=getClientMACaddress(r,c)
out = [];
quit=false;
[tf loc]=clientIsRegistered(r,c);
if tf
    out=r.serverRegister{loc,2};
else

    timeout=5.0;
    constants = getConstants(r);
    quit=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_GET_MAC_CMD,{});
    if ~quit
        [quit respCmd respCom respArgs] = waitForSpecificCommand(r,c,constants.stationToServerCommands.C_RECV_MAC_CMD,timeout,'waiting for client response to S_GET_MAC_CMD',[]);
    end
    if quit
        'Got a quit waiting for mac address' 
    elseif any([isempty(respCmd) isempty(respCom) isempty(respArgs)])
        error('timed out waiting for client response to S_GET_MAC_CMD')
    else
        out=respArgs{1};
    end
end