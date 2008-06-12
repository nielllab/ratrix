function quit=replicateClientTrialRecords(r,c)

% [quit com]=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_GET_TRIAL_RECORDS_CMD,{});
% [quit trCmd trCom trArgs]=waitForSpecificCommand(r,c,constants.stationToServerCommands.C_RECV_TRIAL_RECORDS_CMD,timeout,'waiting for client response to S_GET_TRIAL_RECORDS_CMD',[]);
% 
% if confirm successful save
% [quit com]=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_CLEAR_TRIAL_RECORDS_CMD,{});    
 
constants = getConstants(r);

timeout=30;
%paths={'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects','\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\ratrix\data\large\subjects'};
paths={'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\test\subjects','\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\test2\subjects'};
[quit com]=sendToClient(r,c,constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_REPLICATE_TRIAL_RECORDS_CMD,{paths,true});    

if ~quit
quit=waitForAck(r,com,timeout,'waiting for ack from S_REPLICATE_TRIAL_RECORDS_CMD');
end

end