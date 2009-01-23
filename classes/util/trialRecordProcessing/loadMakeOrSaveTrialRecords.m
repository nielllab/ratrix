function trialRecords=loadMakeOrSaveTrialRecords(varargin)
%trialRecords=struct([]);

fileName='trialRecords.mat';

if length(varargin)>=1
    if ischar(varargin{1})
        subPath=varargin{1};
    else
        error('need a path')
    end
end

if length(varargin)==1
    if isempty(findstr('\\',subPath))
        fs=dir(subPath);
    else
        subPath
        error('not allowed to work on remote dirs due to windows networking/filesharing bug')
    end

    if ismember(fileName,{fs.name})
        in=load(fullfile(subPath, fileName),'trialRecords');
        trialRecords=in.trialRecords;
        doSave=0;
    else
        trialRecords=struct([]);
        doSave=1;
    end

elseif length(varargin)==2
    if isstruct(varargin{2})
        trialRecords=varargin{2};
    else
        error('to save trial records, pass in a struct array of trial records')
    end

    doSave=1;

else
    error('wrong number of arguments')
end

if doSave
    sessionLUT={};
    fieldsInLUT={};
    if length(varargin)==2
        %12/17/08 - put LUT processing here?
        %12/11/08 - newRecs is a struct, each field is an array/matrix of values
        % if type is cell, then use LUT and replace with an array of indices

        fields = fieldnames(trialRecords(1));
        % do not process the 'response' field
        fields(find(strcmp(fields,'response')))=[];
        [sessionLUT fieldsInLUT trialRecords] = processFields(fields,sessionLUT,fieldsInLUT,trialRecords);
    end
    
    save(fullfile(subPath, fileName),'trialRecords','sessionLUT','fieldsInLUT');
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
    %                     fn
    %                     newRecs.(fn)
    %                     class(newRecs.(fn))
%     trialRecords(1)
%     fields
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
            fieldsInLUT{end+1}=fieldPath;
        elseif isstruct(trialRecords(1).(fn)) && ~isempty(trialRecords(1).(fn)) && ~strcmp(fn,'errorRecords')...
                && ~strcmp(fn,'responseDetails') && ~strcmp(fn,'phaseRecords')% check not an empty struct
            % 12/23/08 - note that this assumes that all fields are the same structurally throughout this session
            % this doesn't work in the case of errorRecords, which is empty sometimes, and non-empty other times
            % this is a struct - recursively call processFields on all fields of the struct
            thisStructFields = fieldnames((trialRecords(1).(fn)));
            % now call processFields recursively - pass in fn as a prefix (so we know how to store to fieldsinLUT)
            trialRecords
            fn
            fieldPath
            [sessionLUT fieldsInLUT theseStructs] = processFields(thisStructFields,sessionLUT,fieldsInLUT,[trialRecords.(fn)],fieldPath);
            % we have to return a temporary 'theseStructs' and then manually reassign in trialRecords unless can figure out correct indexing
    %         size(theseStructs)
    %         size(trialRecords)
    %         theseStructs
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
                if all(cellfun('isclass',thisRecordCell,'char'))
                    [indices sessionLUT] = addOrFindInLUT(sessionLUT,thisRecordCell);
                    trialRecords(trialInd).(fn)=indices;
                    addToLUT=true;
                end
            end
            if addToLUT
                fieldsInLUT{end+1}=fieldPath;
            end

        end
    catch
        ple
        warning('LUT processing of trialRecords failed! - probably due to manual training step switching.');
    end
end

end % end helper function
% ==================================
