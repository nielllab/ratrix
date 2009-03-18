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

    % !!!!!!!!!!!!!!!!!!!1
    % 3/17/09 - LUTizing has to happen during the 'collection' process (during replicate), because if the LUT lookup changes
    % from trial to trial, then the already saved trials have out-of-date indices
    % in old mode, these indices were updated every trial and resaved - but not anymore!
%     sessionLUT={};
%     fieldsInLUT={};
%     if length(varargin)==2 && ~isempty(trialRecords) %1/26/09 - dont do all this if no records yet
%         %12/17/08 - put LUT processing here?
%         %12/11/08 - newRecs is a struct, each field is an array/matrix of values
%         % if type is cell, then use LUT and replace with an array of indices
% 
%         fields = fieldnames(trialRecords(1));
%         % do not process the 'result' or 'type' fields because they will mess up LUT handling
%         fields(find(strcmp(fields,'result')))=[];
%         fields(find(strcmp(fields,'type')))=[];
%         [sessionLUT fieldsInLUT trialRecords] = processFields(fields,sessionLUT,fieldsInLUT,trialRecords);
%     end
    
    % 3/17/09 - short hack - only append the last element of trialRecords using a unique variable name
    % see if gives a near-constant save time instead of our bad linear growth
    if ~isempty(trialRecords)
        tn=trialRecords(end).trialNumber;
        evalStr=sprintf('tr%d = trialRecords(end);',tn);
        eval(evalStr);
        evalStr=sprintf('save ''%s'' ''tr%d'' -append',fullfile(subPath,fileName),tn);
        eval(evalStr);
    else
        tn=0;
        evalStr=sprintf('tr%d = trialRecords;',tn);
        eval(evalStr);
        evalStr=sprintf('save ''%s'' ''tr%d''',fullfile(subPath,fileName),tn);
        eval(evalStr);
    end
    

%     save(fullfile(subPath, fileName),'trialRecords','sessionLUT','fieldsInLUT');
end

end % end function



