function r=addRatsForServer(server_name,auth)
if ~exist('server_name','var') || isempty(server_name)
    server_name=getServerNameFromIP;
end

conn=dbConn;
heats=getHeats(conn);
ids={};
for i=1:length(heats)
    assignments=getAssignmentsForServer(conn,server_name,heats{i}.name);
    for j=1:length(assignments)
        ids{end+1}=assignments{j}.subject_id;
    end
end

closeConn(conn);

subs=createSubjectsFromDB(ids);

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

preExistingSubs=getSubjectIDs(r);

for i=1:length(subs)
    if ismember(getID(subs(i)),preExistingSubs)
        getID(subs(i))
        warning('subject already in ratrix - not adding')
    else
        r=addSubject(r,subs(i),auth);
    end
end