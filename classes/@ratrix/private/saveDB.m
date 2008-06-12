function saveDB(r,alsoReplaceSubjectData)

disp(sprintf('saving db'))
startTime=GetSecs();

[pathstr, name, ext, versn] = fileparts(r.dbpath);

if ~isempty(pathstr) && ~isempty(name)

    %     currdir = pwd;
    %
    %     cd(pathstr);
    %     if strcmp(pwd,pathstr)
    fName=fullfile(pathstr, [name ext]);
    found=dir(fName);


    doIt=0;

    if length(found)==0
        warning('didn''t find existing database, writing new one')
        doIt=1;
    elseif length(found)==1

        newDir=fullfile(pathstr,'replacedDBs',['replaced.' datestr(now,30)]); %['replacedDBs' filesep 'replaced.' datestr(now,30)];
        [success,message,messageid] = mkdir(newDir);

        if success
            disp('replacing exisiting database')

            [status,message,messageid] = movefile(fName,newDir);
            if status
                if alsoReplaceSubjectData
                    subPath=getSubjectDataPath(r);
                    if length(dir(subPath))>0

                        [status,message,messageid] = movefile(subPath,newDir);

                        if status
                            doIt=1;
                        else
                            error('couldn''t move subjectData directory: %s, %s',message,messageid)
                        end
                    end

                    makeAllSubjectServerDirectories(r);
%                     subIDs=getSubjectIDs(r);
%                     for subInd=1:length(subIDs)
%                         makeSubjectServerDirectory(r,subIDs{subInd});
%                     end

                else
                    doIt=1;
                end
            else
                error('couldn''t move existing db: %s, %s',message,messageid)
            end
        else
            error('couldn''t create directory %s: %s, %s',newDir,message,messageid)
        end

    else
        error('unknown error -- found got %d matches',length(found))
    end

    r=decache(r);
    if doIt
        save(fName,'r');
    end
    
    % else
    %     error('could not find specified directory')
    % end
    % cd(currdir);

else
    error(sprintf('can''t read database path %s',r.dpbpath))
end

disp(sprintf('done saving db: %g s elapsed',GetSecs()-startTime))