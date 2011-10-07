function r = establishDB(r,dataPath,replaceExistingDB)

if ischar(dataPath)
    r.serverDataPath = dataPath;
else
    error('dataPath should be a fully resolved path string')
end

[pathstr, name, ext] = fileparts(fullfile(r.serverDataPath, filesep));  %i call it a
%bug that fileparts assumes the last piece is a file if it doesn't terminate with a filesep
%should check that it's an actual file or actual directory.

if replaceExistingDB && isempty(r.creationDate)
    r.creationDate = now; % Set the date of creation if we are initializing the db and it has not been set yet
end


if ~isempty(pathstr) && isempty(name)
    fileStr = 'db.mat';
    r.dbpath = fullfile(pathstr , fileStr);



    %     currdir = pwd;

    if checkPath(pathstr)

        %         cd(pathstr);

        %         if strcmp(pwd,pathstr)
        found=dir(r.dbpath);

        if length(found)==0
            if replaceExistingDB
            %save(fileStr,'r');
            saveDB(r,1); %used to be saveDB(r,0)
            else
                disp(r.dbpath)
                error('no db at that location')
            end
        elseif length(found)==1
            if replaceExistingDB
                disp('found existing db, replacing')
                %                        [status,message,messageid] = movefile(fileStr,['./replacedDBs/replaced.' datestr(now,30) '.' fileStr]);
                %                         if status
                %                             save(fileStr,'r');
                %                         else
                %                             error('couldn''t replace existing db: %s, %s',message,messageid)
                %                         end
                saveDB(r,1);
            else
                disp('loading existing db')
                startTime=GetSecs();
                saved=load(r.dbpath,'-mat');
                disp(sprintf('done loading ratrix db: %g s elapsed',GetSecs()-startTime))

                r=saved.r;
            end

        else
            error('unknown error -- found got %d matches',length(found))
        end

        if ~testAllSubjectBoxAndStationDirs(r)
            error('can''t find box, station, or subject dirs')
        end

        %         else
        %             error('could not find specified directory')
        %         end
        %         cd(currdir);
    else
        error('could not make specified directory')
    end
else
    pathstr
    name
    error('must provide a fully resolved path to a new or existing data base directory')
end