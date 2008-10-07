function path = getCompilePathBySubject(conn, subjectID)
% retreives the compile_path (compiled trialRecords store path) field from the subjects table given the display_uin
% returns the result as a 1x1 cell array (holding a char array)

getPathQuery = sprintf('select compile_path from subjects where display_uin=''%s''', subjectID);

path=query(conn,getPathQuery);
if isempty(path{1})
    error('could not find compiled trialRecords store path for this subject %s', subjectID);
end


end %end function