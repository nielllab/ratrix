function assignments=getAssignments(conn,rack_id,heat_name)
assignments = {};
selectAssignmentQuery = ...
    sprintf('SELECT LOWER(subjects.display_uin), rack_id, station_id, heats.name, researchers.username, experiments.name, heat_assignments.note FROM heat_assignments,subjects,racks,stations,heats,researchers,experiments WHERE heat_assignments.subject_uin=subjects.uin AND heat_assignments.station_uin=stations.uin AND stations.rack_uin=racks.uin AND heat_assignments.heat_uin=heats.uin AND subjects.owner_uin=researchers.uin(+) AND heat_assignments.experiment_uin=experiments.uin AND racks.rack_id=%d AND heats.name=''%s''ORDER BY rack_id,station_id',rack_id,heat_name); 

results=query(conn,selectAssignmentQuery);

if ~isempty(results)
    numRecords=size(results,1);
    assignments = cell(numRecords,1);
    for i=1:numRecords
        a = [];
        a.subject_id = results{i,1};
        a.rack_id = results{i,2};
        a.station_id = results{i,3};
        a.heat = results{i,4};
        a.owner = results{i,5};
        a.experiment = results{i,6};
        a.note = results{i,7};
        assignments{i} = a;
    end
end
