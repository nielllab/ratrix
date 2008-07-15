function r=setPermanentStorePath(r,path)
if isDirRemote(path)
    r.permanentStorePath = path;
    saveDB(r,0);  %alsoReplaceSubjectData = false
else
    path
    error('Argument to setPermanentStorePath is not a directory')
end