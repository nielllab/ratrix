function makeSubjectServerDirectory(r,sID);
serverPath=getServerDataPathForSubjectID(r,sID);

[success,message,msgid] = mkdir(serverPath);
if ~success
    error(sprintf('could not make subject server directory: %s, %s, %s',serverPath,message,msgid))
end