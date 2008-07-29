function [rx quit] = updateRatrixFromClientRatrix(rn,rx,client)
constants = getConstants(rn);

[quit com]=sendToClient(rn,client,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_GET_RATRIX_CMD,{});

if ~quit
    timeout=10.0;
    [quit rxCmd rxCom rxArgs]=waitForSpecificCommand(rn,client,constants.stationToServerCommands.C_RECV_RATRIX_CMD,timeout,'waiting for client response to S_GET_RATRIX_CMD',[]);
    com=[];
    rxCmd=[];

    if ~quit
        if length(rxArgs)==1 && ~isempty(rxArgs{1})
            newRX = rxArgs{1};
            if isa(newRX,'ratrix')
                %merge backup to rx %may be for totally different subject!
                rx = mergeMiniIntoRatrix(rx,newRX);
            else
                error('C_RECV_RATRIX_CMD sent an argument that was not a ratrix')
            end
        else
%             rxArgs
%             warning('Ratrix was not sent to the server as a part of the the C_RECV_RATRIX_CMD')
        end
    end
end