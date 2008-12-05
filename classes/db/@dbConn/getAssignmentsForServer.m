function assignments=getAssignmentsForServer(conn,server_name,heat_names,include_test_rats)

% 12/4/08
% include_test_rats allows analysis to exclude test rats
if ~exist('include_test_rats','var')
    include_test_rats=1; % default is to include test rats (used in other ratrix code)
end

if ~exist('heat_names','var') || isempty(heat_names)
    heat_names=getHeats(conn);
    heat_names=[heat_names{:}];
    heat_names={heat_names.name};
elseif ischar(heat_names) && isvector(heat_names)
    heat_names={heat_names};
elseif iscell(heat_names) && isvector(heat_names)
    %pass
else
    error('heat names must be a string or a cell vector of strings or empty (for all heats)')
end

assignments = {};
for j=1:length(heat_names)
    heat_name=heat_names{j};
    selectAssignmentQuery = ...
        sprintf('SELECT LOWER(subjects.display_uin), rack_id, station_id, heats.name, researchers.username, experiments.name FROM heat_assignments,subjects,racks,stations,heats,researchers,experiments,ratrixservers WHERE heat_assignments.subject_uin=subjects.uin AND heat_assignments.station_uin=stations.uin AND subjects.owner_uin=researchers.uin(+) AND stations.rack_uin=racks.uin AND heat_assignments.experiment_uin=experiments.uin(+) AND heat_assignments.heat_uin=heats.uin AND stations.server_uin=ratrixservers.uin AND ratrixservers.name=''%s'' AND heats.name=''%s'' AND (subjects.test_subject=%d OR subjects.test_subject is null OR subjects.test_subject=0) ORDER BY rack_id,station_id',server_name,heat_name,include_test_rats);

    results=query(conn,selectAssignmentQuery);

    if ~isempty(results)
        numRecords=size(results,1);
        for i=1:numRecords
            a = [];
            a.subject_id = results{i,1};
            a.rack_id = results{i,2};
            a.station_id = results{i,3};
            a.heat = results{i,4};
            a.owner = results{i,5};
            a.experiment = results{i,6};
            assignments{end+1} = a;
        end
    end
end