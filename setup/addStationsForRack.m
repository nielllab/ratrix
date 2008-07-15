function r=addStationsForRack(rackID)

conn=dbConn('132.239.158.177','1521','dparks','pac3111');
stations=getStationsOnRack(conn,rackID);
closeConn(conn);

servePump=false;
standalone=false;
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);



% machines={...
%     {7,'0018F35DFADB',[2 1 1]},... %'0018F35E0281' philip took
%     {8,'0018F35DEE62',[2 1 2]},...
%     {9,'0018F34EAE45',[2 1 3]},...
%     {10,'001A4D9326C2',[2 2 1]},...
%     {11,'001A4D523D5C',[2 2 2]},...
%     {12,'001D7D9ACF80',[2 2 3]}}; %'001A4D528033' broke
% % % '001A4D4F8C2F' new server

machines={};

for i=1:length(stations)
    if isMACaddress(stations{i}.mac)
        %machines{end+1}={stations{i}{1,[2 1]} [stations{i}{1,[4 5 6]}]};
        
        machines{end+1}={ [num2str(stations{i}.rack_id) stations{i}.station_id] stations{i}.mac [stations{i}.rack_id stations{i}.row stations{i}.col] };

    end
end


r=createRatrixWithDefaultStations(machines,dataPath,servePump);