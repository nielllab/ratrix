function rackID=getRackIDFromIP

rackID=[];
if IsWin
    [a b]=dos('ipconfig');
    if a==0
        conn=dbConn;
        stations=getStations(conn);
        closeConn(conn);
        stations=[stations{:}];
        [servers junk inds]=unique({stations.server});

        for i=1:length(servers)
            rackIDs = unique([stations(find(inds==i)).rack_id]);
            if length(rackIDs)==1
                if ~isempty(findstr(servers{i},b))
                    if isempty(rackID)
                        rackID=rackIDs;
                    else
                        rackID
                        servers{i}
                        rackIDs
                        error('found multiple server ip''s for this rack ID')
                    end
                end
            else
                servers{i}
                rackIDs
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

    %rackID=3; %testing only
    %error('couldn''t find server by matching ip on this machine')

end