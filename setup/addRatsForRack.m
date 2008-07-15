function r=addRatsForRack(rackID,auth)

conn=dbConn;
heats=getHeats(conn);
ids={};
for i=1:length(heats)
    assignments=getAssignments(conn,rackID,heats{i}.name);
    for j=1:length(assignments)
        ids{end+1}=assignments{j}.subject_id;
    end
end

closeConn(conn);

subs=createSubjectsFromDB(ids);

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

for i=1:length(subs)
    %% need to check if that subject id is already in ratrix, and if so,
    %% make sure none of its fields have changed in oracle
    r=addSubject(r,subs(i),auth);
end