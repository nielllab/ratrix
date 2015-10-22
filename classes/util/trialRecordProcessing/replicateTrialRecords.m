function replicateTrialRecords(paths,deleteOnSuccess, recordInOracle, source)
% This function transforms the raw, local trialRecords file into the formatted permanent-store trialRecords file.
% Does the following:
%   1) calls collectTrialRecords to format from {tr1,tr2,tr3,etc} to vectorized format
%   2) does LUT processing
%   3) Copy the trial records stored in the (local) ratrixData directory to the
%       set of paths given in paths. Typically, paths is a location on the fileserver (ie each subject's permanent store path).

input_paths = paths;

subDirs=struct([]);
boxDirs=fullfile(source,'Boxes');;%fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','Boxes'); %edf 11.08.11
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

    [fp,fn,fe]=fileparts(fileName);
    try
        tr=load(fullfile(filePath,fileName)); %this is safe cuz it's local
    catch ex
        if strcmp(ex.identifier,'MATLAB:load:unableToReadMatFile')
            fullfile(filePath,fileName)
            ex.message
            warning('can''t load file, renaming')
            tr.trialRecords=[];
            [sMV msgMV idMV]=movefile(fullfile(filePath,fileName),fullfile(filePath,['corrupt.' fileName '.' datestr(now,30) '.corrupt']));
            if ~sMV
                disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                msgMV
                idMV
                error('error trying to rename unreadable trialrecords file')
            end
        else
            disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
            error('unknown load problem')
        end
    end

    fullfile(filePath,fileName)
    if length(fieldnames(tr))>1

        % collection process
        trialRecords = collectTrialRecords(tr);

        trialNums=[trialRecords.trialNumber];
        if ~all(diff(trialNums)==1)
            diff(trialNums)
            error('missing trials!')
        end

        % 3/17/09 - do the 'collection' and LUTizing here, then resave to local trialRecords.mat
        % because the replicate processes uses movefile instead of matlab save
        sessionLUT={};
        fieldsInLUT={};

        % 5/5/09 - lets try splitting the processFields according to trainingStepNum
        tsNums=double([trialRecords.trainingStepNum]);
        tsIntervals=[];
        tsIntervals(:,1)=[tsNums(find(diff(tsNums))) tsNums(end)]';
        tsIntervals(:,2)=[1 find(diff(tsNums))+1];
        tsIntervals(:,3)=[find(diff(tsNums)) length(tsNums)];

        for i=1:size(tsIntervals,1) % for each interval, process
            fields=fieldnames([trialRecords(tsIntervals(i,2):tsIntervals(i,3))]);
            % do not process the 'result' or 'type' fields because they will mess up LUT handling
            % both fields could potentially contain strings and numerics mixed (bad for LUT indexing!)
            fields(find(strcmp(fields,'result')))=[];
            fields(find(strcmp(fields,'type')))=[];
            [sessionLUT fieldsInLUT trialRecords(tsIntervals(i,2):tsIntervals(i,3))] = ...
                processFields(fields,sessionLUT,fieldsInLUT,trialRecords(tsIntervals(i,2):tsIntervals(i,3)));
        end

        save(fullfile(filePath,fileName),'trialRecords','sessionLUT','fieldsInLUT');

        newFileName=[fn '_' num2str(trialNums(1)) '-' num2str(trialNums(end)) '_' ...
            datestr(trialRecords(1).date,30) '-' datestr(trialRecords(end).date,30) fe];

        % =======================================================================
        % 9/16/08 - change here to get paths from oracle db (specific for each subject)
        % - if oracle has a path for this subject that is not null, use it; otherwise use ratrix default path

        gotPathFromOracle = 0;
        if isempty (input_paths) % if path not provided as input, get from oracle, otherwise use provided (for standAloneRun)
            conn = dbConn();
            possible_path = getPermanentStorePathBySubject(conn, subjectName);
            closeConn(conn);
            if ~isempty(possible_path{1})
                paths = possible_path;
                gotPathFromOracle = 1; %used to set paths appropriately at the last step (move files to perm store)
            end
        end

        % =======================================================================

        for j=1:length(paths)
            % edited to switch on whether or not we are using subject-specific paths
            if gotPathFromOracle
                [success(j) message messageID]=mkdir(paths{j});
                fprintf('made directory %s\n', paths{j})
            else
                [success(j) message messageID]=mkdir(fullfile(paths{j},subjectName));
                fprintf('made directory %s\n', fullfile(paths{j},subjectName))
            end

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

                    % if didn't get paths from oracle, then append subjectName to paths{j}
                    if ~gotPathFromOracle
                        paths{j} = fullfile(paths{j},subjectName);
                    end

                    if recordInOracle

                        % Attempt to do both the copy of the file and the db add
                        try
                            conn = dbConn();
                            % This method tries to do both the file copy and the db add as closely together in time as possible
                            s = getSubject(conn,subjectName);
                            % Only if the subject is not a test rat should we
                            % add the file to the permanent store
                            if ~s.test
                                successC = copyAndAddTrialRecordFile(conn,subjectName,newFileName,fullfile(filePath,fileName),fullfile(paths{j},newFileName));
                            else
                                % Don't add the trial records for this test subject
                                successC = true;
                            end
                            closeConn(conn);
                        catch ex
                            disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                            successC = false;
                        end
                    else
                        %only do the copy; don't do the db add
                        %                         filePath
                        %                         fileName
                        %                         paths{j}
                        %                         subjectName
                        %                         newFileName
                        [successC messageC messageIDC]=copyfile(fullfile(filePath,fileName),fullfile(paths{j},newFileName));
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
            fprintf('Moving old local trial records file:\n')
            fprintf('\t%s\t%s\n',filePath, fileName)
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

end % end function

% ==================================
% HELPER FUNCTION
% this function will be used recursively to look through structs
function [sessionLUT fieldsInLUT trialRecords] = processFields(fields,sessionLUT,fieldsInLUT,trialRecords,prefix)

% if prefix is defined, then use it for fieldsInLUT
if ~exist('prefix','var')
    prefix='';
end

for ii=1:length(fields)
    fn = fields{ii};
    try
        if ~isempty(prefix)
            fieldPath = [prefix '.' fn];
        else
            fieldPath = fn;
        end
        if ischar(trialRecords(1).(fn))
            % this field is a char - use LUT
            [indices sessionLUT] = addOrFindInLUT(sessionLUT,{trialRecords.(fn)});
            for i=1:length(indices)
                trialRecords(i).(fn) = indices(i);
            end
            if ~ismember(fieldPath,fieldsInLUT)
                fieldsInLUT{end+1}=fieldPath;
            end
        elseif isstruct(trialRecords(1).(fn)) && ~isempty(trialRecords(1).(fn)) && ~strcmp(fn,'errorRecords')...
                && ~strcmp(fn,'responseDetails') && ~strcmp(fn,'phaseRecords') && ~strcmp(fn,'trialDetails') ...
                && ~strcmp(fn,'stimDetails') % check not an empty struct
            % 12/23/08 - note that this assumes that all fields are the same structurally throughout this session
            % this doesn't work in the case of errorRecords, which is empty sometimes, and non-empty other times
            % this is a struct - recursively call processFields on all fields of the struct
            thisStructFields = fieldnames((trialRecords(1).(fn)));
            % now call processFields recursively - pass in fn as a prefix (so we know how to store to fieldsinLUT)
            [sessionLUT fieldsInLUT theseStructs] = processFields(thisStructFields,sessionLUT,fieldsInLUT,[trialRecords.(fn)],fieldPath);
            % we have to return a temporary 'theseStructs' and then manually reassign in trialRecords unless can figure out correct indexing
            for j=1:length(trialRecords)
                trialRecords(j).(fn)=theseStructs(j);
            end
        elseif iscell(trialRecords(1).(fn))
            % if a simple cell (all entries are strings), then do LUT stuff
            % otherwise, we should recursively look through the entries, but this is complicated and no easy way to track in fieldsInLUT
            % because the places where you might find struct/cell in the cell array is not consistent across trials
            % keeping track of each exact location in fieldsInLUT will result in trialRecords.stimDetails.imageDetails{i} for all i in trialRecords
            % this kills the point of using a LUT! - for now, just don't handle complicated cases (leave as is)
            addToLUT=false;
            for trialInd=1:length(trialRecords)
                thisRecordCell=[trialRecords(trialInd).(fn)];
                if all(cellfun('isclass',thisRecordCell,'char') | cellfun('isreal',thisRecordCell)) % 3/3/09 - should change to if all(ischar or isscalar)
                    [indices sessionLUT] = addOrFindInLUT(sessionLUT,thisRecordCell);
                    trialRecords(trialInd).(fn)=indices;
                    addToLUT=true;
                end
            end
            if addToLUT && ~ismember(fieldPath,fieldsInLUT)
                fieldsInLUT{end+1}=fieldPath;
            end
        elseif ismember(fieldPath,fieldsInLUT)
            % 5/5/09 - if this field was LUTized in a prior training step interval, ALWAYS LUTize it here!
            % just do basic processing on this field (fails for char -> struct/cell conversions)
            [indices sessionLUT] = addOrFindInLUT(sessionLUT,{trialRecords.(fn)});
            for i=1:length(indices)
                trialRecords(i).(fn) = indices(i);
            end
        end
    catch ex
        disp(['CAUGHT EX: ' getReport(ex)]);
        warning('LUT processing of trialRecords failed! - probably due to manual training step switching.');
    end
end

end % end helper function
% ==================================
