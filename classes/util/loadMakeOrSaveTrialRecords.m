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
    fs=dir(subPath);

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
    save(fullfile(subPath, fileName),'trialRecords');
end