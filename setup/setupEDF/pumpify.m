function pumpify

cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);


r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file


server_name=getServerNameFromIP;

conn=dbConn;
stations=getStationsForServer(conn,server_name);
assignments=getAssignmentsForServer(conn,server_name);
closeConn(conn);
assignments=[assignments{:}];

machines={};
for i=1:length(stations)
    if isMACaddress(stations{i}.mac) && stations{i}.rack_id==3
        id=[num2str(stations{i}.rack_id) stations{i}.station_id];
        mac=stations{i}.mac
        physicalLocation=int8([stations{i}.rack_id stations{i}.row stations{i}.col]);
        path=fullfile(dataPath, 'Stations',sprintf('station%s',id));
        s=makeDefaultStation(id,path,mac,physicalLocation);
        r=replaceStationForBox(r,s);
        
        subs=assignments([assignments.rack_id]==stations{i}.rack_id & [assignments.station_id]==stations{i}.station_id);
        fprintf('station %s:\n',id)
        for j=1:length(subs)
            sub=subs(j).subject_id;
            fprintf('\t%s\n',sub)
            val=200;
            [junk r]=setAllReinforcementManagerRewards(getSubjectFromID(r,sub),val,r,'','edf');
        end
    end
end