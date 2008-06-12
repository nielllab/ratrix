function cList = disconnectClient(r,client)
javaCList = r.server.disconnectClient(client);
cList = {};
if ~isempty(javaCList)
    for i=1:javaCList.length
        cList{i} = rnetcommand(javaCList(i));
    end
end