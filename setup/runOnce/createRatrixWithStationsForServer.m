function r=createRatrixWithStationsForServer(server_name,rewardMethod)

conn=dbConn;
stations=getStationsForServer(conn,server_name);
closeConn(conn);

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

machines={};

for i=1:length(stations)
    if isMACaddress(stations{i}.mac)
        
        machines{end+1}={ [num2str(stations{i}.rack_id) stations{i}.station_id] stations{i}.mac [stations{i}.rack_id stations{i}.row stations{i}.col] };

    end
end


r=createRatrixWithDefaultStations(machines,dataPath,rewardMethod,false);
