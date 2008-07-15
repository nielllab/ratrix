function d=remoteDir(path)
nAttempts=25;
for i=1:nAttempts
    d=dir(path);
    if ~isempty(d)
        return
    end
end