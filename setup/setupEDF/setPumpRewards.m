function setPumpRewards
val=80;
rackID=3;

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
    if stations{i}.rack_id==rackID

        subs=assignments([assignments.rack_id]==stations{i}.rack_id & [assignments.station_id]==stations{i}.station_id);
         id=[num2str(stations{i}.rack_id) stations{i}.station_id];
        fprintf('station %s:\n',id)
        for j=1:length(subs)
            sub=subs(j).subject_id;
            fprintf('\t%s\n',sub)
            [junk r]=setAllReinforcementManagerRewards(getSubjectFromID(r,sub),val,r,'','edf');
        end
    end
end