function recordInLog(r,s,str,author)
    if ~authorCheck(r,author)
        author='unknown author';
        warning(sprintf('this is bad -- an unknown author succeeded in making a system change: %s, which means this code did not use checkAuthor() prior to making the change',str))
    end
        
    if isa(s,'subject')
        theStr = sprintf('%s: %s: %s\n\n',datestr(now,31),author,str);
        %disp(sprintf('appending log for subject %s:\n%s',getID(s),sprintf(theStr)));

        serverFile=fullfile(getServerDataPathForSubjectID(r,getID(s)), [getID(s) '.log.txt']);

 
        [fid errmsg] = fopen(serverFile,'at');
        if fid~=-1
            fprintf(fid,theStr);
            status=fclose(fid);
            if status~=0
                error(sprintf('could not close subject %s logfile at %s',getID(s),serverFile))
            end
        else
            error(sprintf('could not open subject %s logfile at %s, errmsg was %s',getID(s),serverFile,errmsg))
        end

    else
        error('argument is not a subject object')
    end