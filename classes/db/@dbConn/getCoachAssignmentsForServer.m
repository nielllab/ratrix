function assignments=getCoachAssignmentsForServer(conn,server_uin,heat_name)
assignments = {};
selectAssignmentQuery = ...
    sprintf('SELECT LOWER(subjects.display_uin), researchers.username FROM heat_assignments,subjects,racks,stations,heats,researchers,experiments WHERE heat_assignments.subject_uin=subjects.uin AND heat_assignments.station_uin=stations.uin AND subjects.coach_uin=researchers.uin(+) AND stations.rack_uin=racks.uin AND heat_assignments.experiment_uin=experiments.uin(+) AND heat_assignments.heat_uin=heats.uin AND stations.server_uin=%d AND heats.name=''%s''ORDER BY rack_id,station_id',server_uin,heat_name);

results=query(conn,selectAssignmentQuery);

if ~isempty(results)
    numRecords=size(results,1);
    assignments = cell(numRecords,1);
    for i=1:numRecords
        a = [];
        a.subject_id = results{i,1};
        a.coach = results{i,2};
        assignments{i} = a;
    end
end
