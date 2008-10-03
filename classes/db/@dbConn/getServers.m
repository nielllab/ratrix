function servers=getServers(conn)
servers = {};
selectServerQuery = ...
    'SELECT address, name from ratrixservers ORDER BY name'; 

results=query(conn,selectServerQuery);

if ~isempty(results)
    numRecords=size(results,1);
    servers = cell(numRecords,1);
    for i=1:numRecords
        s = [];
        s.address = results{i,1};
        s.server_name = results{i,2};
        servers{i} = s;
    end
end
