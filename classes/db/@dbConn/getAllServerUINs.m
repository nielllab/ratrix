function uins=getAllServerUINs(conn)
assignments = {};
selectAssignmentQuery = ...
    sprintf('SELECT DISTINCT server_uin from STATIONS'); 

uins=query(conn,selectAssignmentQuery);

% if ~isempty(results)
%     numRecords=size(results,1);
%     assignments = cell(numRecords,1);
%     for i=1:numRecords
%         a = [];
%         a.subject_id = results{i,1};
%         a.rack_id = results{i,2};
%         a.station_id = results{i,3};
%         a.heat = results{i,4};
%         a.owner = results{i,5};
%         a.experiment = results{i,6};
%         assignments{i} = a;
%     end
end
