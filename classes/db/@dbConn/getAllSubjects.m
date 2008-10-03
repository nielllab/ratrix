function subjects=getAllSubjects(conn)
subjects = {};
selectSubjectsQuery = 'select display_uin, subjects.uin from subjects order by display_uin';
results=query(conn,selectSubjectsQuery);

if ~isempty(results)
    numRecords=size(results,1);
    subjects = cell(numRecords,1);
    for i=1:numRecords
        s = [];
        s.subjectID = results{i,1};
        s.subject_uin = results{i,2};
        subjects{i} = s;
    end
end
