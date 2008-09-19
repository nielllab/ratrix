function subjectIDs = getSubjectIDsFromServer(conn, server_name)
% This function grabs all subjectIDs (display_uin) that belong to a given server_name from the Oracle DB.
% Returns a cell array of subjectIDs.

subjectIDs={};
getSubIDsQuery = sprintf('select LOWER(display_uin) from subjects, heat_assignments, stations, ratrixservers where subjects.uin=heat_assignments.subject_uin AND stations.server_uin=ratrixservers.uin AND ratrixservers.name=''%s'' AND heat_assignments.station_uin=stations.uin', server_name);
results=query(conn,getSubIDsQuery);

if ~isempty(results)
    numRecords=size(results,1);
    subjectIDs = cell(numRecords,1);
    for i=1:numRecords
        s = [];
        s.subjectID = results{i,1};
        subjectIDs{i} = s.subjectID;
    end
end


end % end function