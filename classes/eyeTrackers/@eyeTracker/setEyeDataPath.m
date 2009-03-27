function et=setEyeDataPath(et,path)

if isdir(path)
    et.eyeDataPath=path;
else
    path=path
    error('not a path')
end