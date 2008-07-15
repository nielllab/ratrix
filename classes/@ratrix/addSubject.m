function r = addSubject(r,s,author)
if isa(s,'subject')
    [member index]=ismember(lower(getID(s)),lower(getSubjectIDs(r)));
    if index>0
        getID(s)
        error('ratrix already contains a subject with that id')

    else
        if litterCheck(r,s) && authorCheck(r,author)



            %                 serverPath=[r.serverDataPath '\subjectData\' getID(s) '\'];
            %
            %                     [success,message,msgid] = mkdir(serverPath);
            %                     if ~success
            %                         error(sprintf('could not make subject server directory: %s, %s, %s',serverPath,message,msgid))
            %                     end

            r.subjects{length(r.subjects)+1}=s;
            saveDB(r,0);
            makeSubjectServerDirectory(r,getID(s));
            recordInLog(r,s,sprintf('added subject %s\n%s',getID(s),display(s)),author);
        else
            error('litterID should be ''unknown'' or should match acquisition and birth dates of other subjects with the same litterID')
        end
    end
else
    error('argument not subject object')
end