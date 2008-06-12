function heats=getHeats(conn)
heats = {};
selectHeatQuery = ...
    'SELECT name, red_value, green_value, blue_value FROM heats ORDER BY red_value desc, blue_value, green_value'; 

results=query(conn,selectHeatQuery);

if ~isempty(results)
    numRecords=size(results,1);
    heats = cell(numRecords,1);
    for i=1:numRecords
        h = [];
        h.name = results{i,1};
        h.red = results{i,2};
        h.green = results{i,3};
        h.blue = results{i,4};
        heats{i} = h;
    end
end
