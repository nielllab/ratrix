cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);


r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file


server_name=getServerNameFromIP;

conn=dbConn;
stations=getStationsForServer(conn,server_name)
closeConn(conn);

machines={};
for i=1:length(stations)
    if isMACaddress(stations{i}.mac) && stations{i}.rack_id==3
        id=[num2str(stations{i}.rack_id) stations{i}.station_id];
        mac=stations{i}.mac
        physicalLocation=int8([stations{i}.rack_id stations{i}.row stations{i}.col]);
        path=fullfile(dataPath, 'Stations',sprintf('station%s',id));
        s=makeDefaultStation(id,path,mac,physicalLocation);
        r=replaceStationForBox(r,s);
    end
end