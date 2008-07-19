function valid=isDirRemote(path)
nAttempts=25;
for i=1:nAttempts
    valid=isdir(path);
    if valid
        return
    end
end
warning('failure does not guarantee path is not valid')