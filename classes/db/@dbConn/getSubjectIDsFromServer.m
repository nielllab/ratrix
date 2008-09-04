function subjectIDs = getSubjectIDsFromServer(conn, server_uin)
% This function grabs all subjectIDs (display_uin) that belong to a given server_uin from the Oracle DB.
% Returns a cell array of subjectIDs.

getSubIDsQuery = sprintf('select LOWER(display_uin) from subjects, heat_assignments, stations where subjects.uin=heat_assignments.subject_uin AND stations.server_uin=%d AND heat_assignments.station_uin=stations.uin', server_uin);
results=query(conn,getSubIDsQuery);

if ~isempty(results)
    numRecords=size(results,1);
    subjectIDs = cell(numRecords,1);
    for i=1:numRecords
        s = [];
        s.subjectID = results{i,1};
        subjectIDs{i} = s;
    end
end


end % end function