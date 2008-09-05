function serverUIN=getServerUINFromIP

serverUIN=[];
if IsWin
    [a b]=dos('ipconfig');
    if a==0
        conn=dbConn;
        sql_query='SELECT * from ratrixservers';
        results = query(conn,sql_query);
        
        if ~isempty(results)
            numRecords=size(results,1);
            servers = cell(numRecords,1);
            for i=1:numRecords
                a = [];
                a.server_uin = results{i,1};
                a.address = results{i,2};
                servers{i} = a;
            end
        end

        
        
        closeConn(conn);
        
        for i=1:length(servers)
            toSearch = servers{i}.address
            if ~isempty(findstr(toSearch,b))
                serverUIN = servers{i}.server_uin;
            end
        end
        
%         stations=[stations{:}];
%         [servers junk inds]=unique({stations.server});
% 
%         for i=1:length(servers)
%             rackIDs = unique([stations(find(inds==i)).rack_id]);
%             if length(rackIDs)==1
%                 if ~isempty(findstr(servers{i},b))
%                     if isempty(rackID)
%                         rackID=rackIDs;
%                     else
%                         rackID
%                         servers{i}
%                         rackIDs
%                         error('found multiple server ip''s for this rack ID')
%                     end
%                 end
%             else
%                 servers{i}
%                 rackIDs
%                 error('found multiple rack ids for one server ip')
%             end
%         end
    else
        a
        b
        error('couldnt ipconfig')
    end
else
    error('only works on windows')
end

if isempty(serverUIN)
    b

    %rackID=3; %testing only
    %error('couldn''t find server by matching ip on this machine')

end