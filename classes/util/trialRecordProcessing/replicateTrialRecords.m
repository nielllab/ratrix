function replicateTrialRecords(paths,deleteOnSuccess, recordInOracle)
% Copy the trial records stored in the ratrixData directory to the
% set of paths given in paths.

subDirs=struct([]);
boxDirs=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','Boxes');
boxDirsToCheck=dir(boxDirs);
for b=1:length(boxDirsToCheck)
    boxDir=boxDirsToCheck(b).name;
    if findstr('box',boxDir)==1
        subjectDirs=fullfile(boxDirs,boxDir,'subjectData');
        subjectDirsToCheck=dir(subjectDirs);
        for s=1:length(subjectDirsToCheck)
            subDir=subjectDirsToCheck(s).name;
            if ~ismember(subDir,{'.','..'}) %&& findstr('test',lower(subDir))~=1
                subName=subDir;
                subDir=fullfile(subjectDirs,subName);
                if length(dir(fullfile(subDir,'trialRecords.mat')))==1
                    subDirs(end+1).dir=subDir; %fullfile(subjectDirs,subDir);
                    subDirs(end).name=subName;
                    subDirs(end).file='trialRecords.mat';
                    %subDirs(end+1)=sub;
                end
            end
        end
    end
end

for f=1:length(subDirs)
    subjectName=subDirs(f).name;
    filePath=subDirs(f).dir;
    fileName=subDirs(f).file;

    [fp,fn,fe,fv]=fileparts(fileName);
    try
        tr=load(fullfile(filePath,fileName)); %this is safe cuz it's local
    catch loaderror
        if strcmp(loaderror.identifier,'MATLAB:load:unableToReadMatFile')
            fullfile(filePath,fileName)
            loaderror.message
            warning('can''t load file, renaming')
            tr.trialRecords=[];
            [sMV msgMV idMV]=movefile(fullfile(filePath,fileName),fullfile(filePath,['corrupt.' fileName '.' datestr(now,30) '.corrupt']));
            if ~sMV
                ple(loaderror)
                msgMV
                idMV
                error('error trying to rename unreadable trialrecords file')
            end
        else
            ple(loaderror)
            error('unknown load problem')
        end
    end

    if ~isempty(tr.trialRecords)
        trialNums=[tr.trialRecords.trialNumber];
        if ~all(diff(trialNums)==1)
            diff(trialNums)
            error('missing trials!')
        end

        newFileName=[fn '_' num2str(trialNums(1)) '-' num2str(trialNums(end)) '_' ...
            datestr(tr.trialRecords(1).date,30) '-' datestr(tr.trialRecords(end).date,30) fe];

        for j=1:length(paths)
            [success(j) message messageID]=mkdir(fullfile(paths{j},subjectName));
            if success(j) %ignore warning if directory exists
                d=dir(fullfile(paths{j},subjectName)); %not safe cuz of windows networking/filesharing bug -- but will just result in overwriting existing trialRecord file in case of name collision, should never happen -- ultimately just compare against filenames in oracle
                for i=1:length(d)
                    if strcmp(d(i).name,newFileName)
                        if ~d(i).isdir
                            dt=datevec(now);
                            frac=dt(6)-floor(dt(6));
                            [successM messageM messageIDM]=movefile(fullfile(paths{j},subjectName,newFileName),fullfile(paths{j},subjectName,['old.' newFileName '.old.' datestr(dt,30) '.' sprintf('%03d',floor(frac*1000))]));
                            if ~successM
                                messageM
                                messageIDM
                                %error('couldn''t make backup of file with same name')
                            end
                            success(j)=success(j) && successM;
                        else
                            success(j)=false;
                            error('got an unexpected directory')
                        end
                    end
                end
                if success(j)
                    if recordInOracle

                        % Attempt to do both the copy of the file and the db add
                        try
                            conn = dbConn();
                            % This method tries to do both the file copy and the db add as closely together in time as possible
                            s = getSubject(conn,subjectName);
                            % Only if the subject is not a test rat should we
                            % add the file to the permanent store
                            if ~s.test
                                successC = copyAndAddTrialRecordFile(conn,subjectName,newFileName,fullfile(filePath,fileName),fullfile(paths{j},subjectName,newFileName));
                            else
                                % Don't add the trial records for this test subject
                                successC = true;
                            end
                            closeConn(conn);
                        catch ex
                            ple(ex)
                            successC = false;
                        end
                    else
                        %only do the copy; don't do the db add 
                        [successC messageC messageIDC]=copyfile(fullfile(filePath,fileName),fullfile(paths{j},subjectName,newFileName));
                        if ~successC
                            messageC
                            messageIDC
                            error('couldn''t copy file')
                        end
                    end
                    success(j)=success(j) && successC;
                end
            else
                message
                messageID
                %error('couldn''t make destination directory')
            end
        end
        if deleteOnSuccess && all(success)
            %delete(fullfile(filePath,fileName))

            [succ message messageID]=mkdir(fullfile(filePath,'backups'));
            if ~succ
                message
                messageID
            end
            'Moving old local trial records file'
            filePath
            fileName
            [successM messageM messageIDM]=movefile(fullfile(filePath,fileName),fullfile(filePath,'backups',newFileName));
            if ~successM
                messageM
                messageIDM
            end
        end
        if ~all(success)
            ple
            'BAD DB FILE COPY ISSUE!!!!!!!!!'
            lastwarn
        end

    else
        %delete(fullfile(filePath,fileName))?
    end
end
