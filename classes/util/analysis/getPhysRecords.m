function [physRecords success]=getPhysRecords(subjectDataPath,when,what,filter)
% INPUTS:
%   subjectDataPath - the location of this subject's physiology records
%   	this location should have folders named 'neuralRecords', 'stimRecords', and 'analysis'
%       the 'analysis' folder contains a separate folder for each trial; each trial's folder contains the physAnalysis and spikeRecords files
%   when - a trialFilter
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

% error checking
if ~iscell(what) || ~iscell(when)
    error('what and when must be cell arrays');
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
            case 'eye'
                d=dir(fullfile(subjectDataPath,'eyeRecords'));
                searchStr='eyeRecords_(\d+)_(.*)\.mat';
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
                    [analysisFolder]=getGoodFile(d(i).name,searchStr);
                    if ~isempty(analysisFolder) && d(i).isdir
                        dd=dir(fullfile(subjectDataPath,'analysis',analysisFolder));
                        for j=1:length(dd)
                            searchStr='(\d+)-(.*)';
                            [trialFolder trialNum timestamp]=getGoodFile(dd(j).name,searchStr);
                            %dd(j).name
                            %trialFolder
                            if ~isempty(trialFolder) && dd(j).isdir
                                ddd=dir(fullfile(subjectDataPath,'analysis',analysisFolder,trialFolder));
                                for k=1:length(ddd)
                                    searchStr='physAnalysis_(\d+)-(.*)\.mat';
                                    [analysisFileName trialNum timestamp]=getGoodFile(ddd(k).name,searchStr);
                                    %[j k]
                                    %dd(j).name
                                    %ddd(k).name
                                    %trialFolder
                                    %analysisFileName
                                    if ~isempty(analysisFileName) % found a physAnalysis file in this trial's folder
                                        if isempty(goods)
                                            goods=ddd(k);
                                            analysisFolderLog{1}=analysisFolder;
                                        else
                                            goods(end+1)=ddd(k);
                                            analysisFolderLog{end+1}=analysisFolder;
                                        end
                                    end
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
    analysisPosition=find(strcmp(what,'analysis'));
    for i=1:length(trials)-1
        [goodTrials prevInds theseInds]=intersect(goodTrials,trials{i});
        
        %analysisFolderLog should be kept track of here: prevInds theseInds
        if analysisPosition==length(what)
            %if at the end
            analysisFolderLog=analysisFolderLog(prevInds);
            warning('never used yet...manually confirm this is the right answer once')
            keyboard
        elseif i>=analysisPosition
            %for the first time its encountered, and every time afterwards
            % keep reducing the analysisFolderLog appropriately
            if length(analysisFolderLog)==length(trials{i})
                analysisFolderLog=analysisFolderLog(theseInds);
            else
                length(analysisFolderLog)
                length(trials{i})
                length(goodTrials)
                error('should never happen')
            end
        elseif  i<analysisPosition
            %have not processed analysis yet
        elseif isempty(analysisPosition)
            %analysis not asked for, so never process
        else
            error('unexpected')
        end
        
    end
    goodFiles=[];
    searchStr='(\d+)-(.*)';
    for i=1:length(goodTrials)
        [match trialNum timestamp]=getGoodFile(goodTrials{i},searchStr);
        goodFiles(end+1).trialStart=trialNum;
        goodFiles(end).trialStop=trialNum;
        goodFiles(end).dateStart=timestamp;
        goodFiles(end).dateStop=timestamp;
        if ~isempty(analysisPosition)
            goodFiles(end).analysisFolderLog=analysisFolderLog{i};
        end
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
            case 'grating'
                if record.stimulusDetails.changeableAnnulusCenter==1
                    stimIdentity='gratingWithChangeableAnnulusCenter';
                else
                    stimIdentity='grating';
                end
            otherwise
                stimIdentity=record.stimManagerClass;
        end
        
        switch filter
            case 'whiteNoise'
                error('whiteNoise must specify spatialWhiteNoise or temporalWhiteNoise')
            case {'gratings','spatialWhiteNoise','temporalWhiteNoise','gratingWithChangeableAnnulusCenter'}
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
                        ff1=sprintf('%s',goodFiles(end).analysisFolderLog);
                        ff2=sprintf('%d-%s',goodFiles(end).trialStart,goodFiles(end).dateStart);
                        fn=sprintf('physAnalysis_%d-%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                        record=load(fullfile(subjectDataPath,'analysis',ff1,ff2,fn));
                    case 'spike'
                        ff=sprintf('%d-%s',goodFiles(end).trialStart,goodFiles(end).dateStart);
                        fn=sprintf('spikeRecords_%d-%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                        record=load(fullfile(subjectDataPath,'analysis',ff,fn));
                    case 'eye'
                        fn=sprintf('eyeRecords_%d_%s.mat',goodFiles(end).trialStart,goodFiles(end).dateStart);
                        record=load(fullfile(subjectDataPath,'eyeRecords',fn));
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