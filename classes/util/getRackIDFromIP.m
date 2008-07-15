function rackID=getRackIDFromIP

rackID=[];
if iswin
    [a b]=dos('ipconfig');
    if a==0
        conn=dbConn;
        stations=getStations(conn);
        closeConn(conn);
        stations=[stations{:}];
        stations=stations(randperm(length(stations))); %remove
        [servers junk inds]=unique({stations.server});
        
        for i=1:length(servers)
            rackIDs = unique([stations(find(inds==i)).rack_id]);
            servers{i}
            rackIDs
            if length(rackIDs)==1
                if ~isempty(findstr(servers{i},b))
                    if isempty(rackID)
                        rackID=rackIDs;
                        'match!'
                        rackID
                    else
                        error('found multiple server ip''s for this rack ID')
                    end
                end
            else
                error('found multiple rack ids for one server ip')
            end
        end
    else
        a
        b
        error('couldnt ipconfig')
    end
else
    error('only works on windows')
end

if isempty(rackID)
    b

    error('couldn''t find server by matching ip on this machine')

end