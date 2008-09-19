function path = getPermanentStorePathBySubject(conn, subjectID)
% retreives the store_path (permanent store path) field from the subjects table given the display_uin
% returns the result as a 1x1 cell array (holding a char array)

getPathQuery = sprintf('select store_path from subjects where display_uin=''%s''', subjectID);

path=query(conn,getPathQuery);
if isempty(path{1})
    error('could not find permanent store path for this subject %s', subjectName);
end


end %end function