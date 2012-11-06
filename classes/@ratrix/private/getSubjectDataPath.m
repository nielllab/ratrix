function out=getSubjectDataPath(r)
out=fullfile(r.serverDataPath, 'subjectData'); %this screws up when reading windows ratrix from linux
checkPath(out);
