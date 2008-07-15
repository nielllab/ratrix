function station=getStationFromMac(conn,mac)
station = [];
selectStationQuery = ...
    sprintf('SELECT mac, station_id,rack_id,row_num,col_num,ratrixservers.address FROM stations,racks,ratrixservers WHERE stations.rack_uin=racks.uin AND stations.server_uin=ratrixservers.uin AND mac=''%s'' ORDER BY rack_id,station_id',mac); 

results=query(conn,selectStationQuery);

if ~isempty(results)
    numRecords=size(results,1);

    if numRecords ~= 1
        error('Only one record expected when asking for a station given a mac')
    end
        
    s.mac = results{1,1};
    s.station_id = results{1,2};
    s.rack_id = results{1,3};
    s.row = results{1,4};
    s.col = results{1,5};
    s.server = results{1,6};
    station = s;
end
