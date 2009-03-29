function [physRecords success]=getPhysRecords(subjectDataPath,when,what,filter)
% INPUTS:
%   subjectDataPath - the location of this subject's physiology records
%   	this location should have folders named 'neuralRecords', 'stimRecords', and 'analysis'
%       the 'analysis' folder contains a separate folder for each trial; each trial's folder contains the physAnalysis and spikeRecords files
%   when - a trialRange [min max] specifying which trials to load records for
%   what - what type of records to load (eg 'stim','neural','spike','analysis')
%   filter - how to filter the records (eg 'whiteNoise')
% OUTPUTS:
%   analysisdata - the physiology records loaded for the specified type of analysis

if ~exist('when','var') || isempty(when)
    when={'all'};
end

if ~exist('what','var') || isempty(what)
    what={'stim','neural','spike','analysis'};
end

goodFiles=[];

trials={};

try
%  go through each 'what' and get the intersection of their good trialNums and timestamps
for w=1:length(what)
    trials{w}={};
    switch what{w}
        case 'stim'
            d=dir(fullfile(subjectDataPath,'stimRecords'));
            searchStr='stimRecords_(\d+)-(.*)\.mat';
        case 'neural'
            d=dir(fullfile(subjectDataPath,'neuralRecords'));
            searchStr='neuralRecords_(\d+)-(.*)\.mat';
        case 'spike'
            goods=[];
            d=dir(fullfile(subjectDataPath,'analysis'));
            for i=1:length(d)
                searchStr='(\d+)-(.*)';
                [trialFolder]=getGoodFile(d(i).name,searchStr);
                if ~isempty(trialFolder) && d(i).isdir
                    dd=dir(fullfile(subjectDataPath,'analysis',trialFolder));
                    searchStr='spikeRecords_(\d+)-(.*)\.mat';
                    for j=1:length(dd)
                        [analysisFileName trialNum timestamp]=getGoodFile(dd(j).name,searchStr);
                        if ~isempty(analysisFileName) % found a physAnalysis file in this trial's folder
                            if isempty(goods)
                                goods=dd(j);
                            else
                                goods(end+1)=dd(j);
                            end
                        end
                    end
                end
            end
            d=goods;
            searchStr='spikeRecords_(\d+)-(.*)\.mat';
        case 'analysis'
            % hard to do
            goods=[];
            d=dir(fullfile(subjectDataPath,'analysis'));
            for i=1:length(d)
                searchStr='(\d+)-(.*)';
                [trialFolder]=getGoodFile(d(i).name,searchStr);
                if ~isempty(trialFolder) && d(i).isdir
                    dd=dir(fullfile(subjectDataPath,'analysis',trialFolder));
                    searchStr='physAnalysis_(\d+)-(.*)\.mat';
                    for j=1:length(dd)
                        [analysisFileName trialNum timestamp]=getGoodFile(dd(j).name,searchStr);
                        if ~isempty(analysisFileName) % found a physAnalysis file in this trial's folder
                            if isempty(goods)
                                goods=dd(j);
                            else
                                goods(end+1)=dd(j);
                            end
                        end
                    end
                end
            end
            d=goods;
            searchStr='physAnalysis_(\d+)-(.*)\.mat';
        otherwise
            error('unknown what');
    end
    for i=1:length(d)
        [name trialNum timestamp]=getGoodFile(d(i).name,searchStr);
        if ~isempty(trialNum) && ~isempty(timestamp)
            trials{w}{end+1}=[num2str(trialNum) '-' timestamp];
        end
    end
end

% now intersect the elements of trials so we only get the trials that have all the files in 'what'
goodTrials=trials{end};
for i=1:length(trials)-1
    goodTrials=intersect(goodTrials,trials{i});
end
goodFiles=[];
searchStr='(\d+)-(.*)';
for i=1:length(goodTrials)
    [match trialNum timestamp]=getGoodFile(goodTrials{i},searchStr);
    goodFiles(end+1).trialStart=trialNum;
    goodFiles(end).trialStop=trialNum;
    goodFiles(end).dateStart=timestamp;
    goodFiles(end).dateStop=timestamp;
end

if ~isempty(goodFiles)
    [sorted order]=sort([goodFiles.trialStart]);
    goodFiles=goodFiles(order);
    goodFiles=applyTrialFilter(goodFiles,when);
end

% then filter the remaining files based on 'filter', and retrieve the most recent file that fits our criteria
% then we will filter out goodFiles based on 'filter'
physRecords=[];
success=false;

while ~success && ~isempty(goodFiles)
    
    % check that stimManagerClass==filter for now, but we should make filter more general
    fn=sprintf('stimRecords_%d-%s.mat', goodFiles(end).trialStart, goodFiles(end).dateStart);
    record=load(fullfile(subjectDataPath,'stimRecords',fn),'stimManagerClass'); % only get the class
 
    % allows identity of a subclass to be determined based on the relevant params
    switch record.stimManagerClass
        case 'whiteNoise'
            record=load(fullfile(subjectDataPath,'stimRecords',fn),'stimulusDetails');
            if any(record.stimulusDetails.spatialDim>1)
                stimIdentity='spatialWhiteNoise';
            else
                stimIdentity='temporalWhiteNoise';
            end
        otherwise
            stimIdentity=record.stimManagerClass;
    end
    
    switch filter
        case 'whiteNoise'
           error('whiteNoise must specify spatialWhiteNoise or temporalWhiteNoise')
        case {'gratings','spatialWhiteNoise','temporalWhiteNoise'}
            %okay to pass
        case 'anything'
            stimIdentity='anything'; %will match filter now
        otherwise
            filter
            error('bad filter request');
            %could turn this error off, and allow all stim types to be checked
    end
    
    if strcmp(stimIdentity,filter)
         success=true;
    end
            
    if success
        % load files desired in 'what'
        for w=1:length(what)
            switch what{w}
                case 'stim'
                    fn=sprintf('stimRecords_%d-%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                    record=load(fullfile(subjectDataPath,'stimRecords',fn));
                case 'neural'
                    fn=sprintf('neuralRecords_%d-%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                    record=load(fullfile(subjectDataPath,'neuralRecords',fn));
                case 'analysis'
                    ff=sprintf('%d-%s',goodFiles(end).trialStart,goodFiles(end).dateStart);
                    fn=sprintf('physAnalysis_%d-%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                    record=load(fullfile(subjectDataPath,'analysis',ff,fn));
                case 'spike'
                    ff=sprintf('%d-%s',goodFiles(end).trialStart,goodFiles(end).dateStart);
                    fn=sprintf('spikeRecords_%d-%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                    record=load(fullfile(subjectDataPath,'analysis',ff,fn));
                otherwise
                    error('unsupported what');
            end
            fields=fieldnames(record);
            for f=1:length(fields)
                physRecords.(fields{f})=record.(fields{f});
            end
        end
        % also add on the trialNum and timestamp
        physRecords.trialNum=goodFiles(end).trialStart;
        physRecords.timestamp=goodFiles(end).dateStart;
    else
        goodFiles(end)=[];% remove last record from goodFiles since it failed our filter
    end
end

catch ex
    sca
    edit(mfilename)
    getReport(ex)
    disp('check editor')
    keyboard
end

end % end function

function [name trialNum timestamp] = getGoodFile(filename,searchStr)
[matches tokens] = regexpi(filename, searchStr, 'match', 'tokens');

if length(matches)==1
    name=filename;
    trialNum = str2double(tokens{1}{1});
    timestamp = tokens{1}{2};
else
    %        no match or outside of range
    name=[];
    trialNum=[];
    timestamp=[];
end
end % end function