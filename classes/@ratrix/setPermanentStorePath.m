function r=setPermanentStorePath(r,path)
if isdir(path) %can fail due to windows networking/filesharing bug, but unlikely at construction time
    r.permanentStorePath = path;
    saveDB(r,0);  %alsoReplaceSubjectData = false
else
    path
    error('Argument to setPermanentStorePath is not a directory')
end