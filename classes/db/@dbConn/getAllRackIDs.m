function rackIDs=getAllRackIDs(conn)
rackIDs = {};
selectRackIDQuery = ...
    sprintf('SELECT DISTINCT rack_id from RACKS, STATIONS where racks.uin=stations.rack_uin order by rack_id'); 

rackIDs=query(conn,selectRackIDQuery);

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
