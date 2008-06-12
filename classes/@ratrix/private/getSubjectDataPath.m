function out=getSubjectDataPath(r)
out=fullfile(r.serverDataPath, 'subjectData');
checkPath(out);