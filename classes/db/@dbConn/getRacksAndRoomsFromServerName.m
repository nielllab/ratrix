function rrs=getRacksAndRoomsFromServerName(conn, server_name)
rrs = {};
selectRackIDQuery = ...
    sprintf('SELECT DISTINCT rack_id, room from RACKS, STATIONS, RATRIXSERVERS where racks.uin=stations.rack_uin AND stations.server_uin=ratrixservers.uin AND ratrixservers.name=''%s'' order by rack_id', server_name); 

results=query(conn,selectRackIDQuery);

if ~isempty(results)
    numRecords=size(results,1);
    rrs = cell(numRecords,1);
    for i=1:numRecords
        a = [];
        a.rackID = results{i,1};
        a.room = results{i,2};
        rrs{i} = a;
    end
end
