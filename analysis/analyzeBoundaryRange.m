function analyzeBoundaryRange(subjectID, path, cellBoundary, trodes, spikeDetectionParams, spikeSortingParams,...
        timeRangePerTrialSecs, stimClassToAnalyze, analysisMode, usePhotoDiodeSpikes, plottingParams, frameThresholds,makeBackup)
%% START ERROR CHECKING AND CORRECTION
if ~exist('subjectID','var') || isempty(subjectID)
    subjectID = 'demo1'; %
end

if ~exist('path','var') || isempty(path)
    % path = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\Fan\datanet' % OLD
    path = '\\132.239.158.179\datanet_storage\';
end

% needed for physLog boundaryType
neuralRecordsPath = fullfile(path, subjectID, 'neuralRecords');
if ~isdir(neuralRecordsPath)
    neuralRecordsPaths
    error('unable to find directory to neuralRecords');
end

% cellBoundary with support for masking
if ~exist('cellBoundary','var') || isempty(cellBoundary)
    error('cellBoundary must be a valid input argument - default value is too dangerous here!');
else 
    [boundaryRange maskInfo] = validateCellBoundary(cellBoundary);
end

% spikeChannelsAnalyzed
if ~exist('trodes','var') || isempty(trodes)
    channelAnalysisMode = 'allPhysChannels';
    trodes={}; % default all phys channels one by one. will be set when we know how many channels
else
    channelAnalysisMode = 'onlySomeChannels';
    %error check
    if ~(iscell(trodes))
        error('must be a cell of groups of channels');
    elseif length(trodes)>1
        warning('going to try multiple leads in analysis...');
    end
        
end

% create the analysisPath and see if it exists
[analysisPath analysisDirForRange]= createAnalysisPathString(boundaryRange,path,subjectID)
prevAnalysisExists =  exist(analysisPath,'dir');

% shouldwe backup the analysis?
if prevAnalysisExists && makeBackup
    backupPath = fullfile(path,subjectID,'analysis','backups',sprintf('analysisDirForRange-%s',datestr(now,30)));
    makedir(backupPath);
    [succ,msg,msgID] = moviefile(analysisPath, backupPath);  % includes all subdirectory regardless of permissions
    if ~succ
        msg
        error('failed to make backup')
    end
end
    

% make initial assumptions about spike detection and sorting parameters
% but first make sure that the variables exist.
if ~exist('spikeDetectionParams','var')
    spikeDetectionParams = [];
end

if ~exist('spikeSortingParams','var')
    spikeSortingParams = [];    
end

%createAnalysisPaths here
switch analysisMode 
    case {'overwriteAll','detectAndSortOnFirst','detectAndSortOnOnAll','interactiveDetectAndSortOnFirst',...
            'interactiveDetectAndSortOnAll', 'analyzeAtEnd'}
        % if a previous analysis exists, delete it
        if prevAnalysisExists
            [succ,msg,msgID] = rmdir(analysisPathForTrial,'s');  % includes all subdirectory regardless of permissions
            if ~succ
                msg
                error('failed to remove existing files when running with ''overwriteAll=true''')
            end
            prevAnalysisExists = false;
        end
        % recreate the analysis file
        mkdir(analysisPath);
        % lets save the analysis boundaries in a file called analysisBoundary
        analysisBoundaryFile = fullfile(analysisPath,'analysisBoundary.mat');
        save(analysisBoundaryFile,'boundaryRange','maskInfo');
        % lets see if spikeDetection and spikeSorting is specified for all trodesNums
        [validatedParams spikeDetectionParams spikeSortingParams] = validateAndSetDetectionAndSortingParams(spikeDetectionParams,...
            spikeSortingParams,channelAnalysisMode,trodes);
        % save spikeDetection and spikeSorting params to analysispath
        detectionAndSortingParamFile = fullfile(analysisPath,'detectionAndSortingParams.mat');
        save(detectionAndSortingParamFile,'spikeSortingParams','spikeDetectionParams');
    case {'viewAnalysisOnly'}
        % do nothing
    otherwise
        error('unknown analysisMode: ''%s''',analysisMode)
end


if ~exist('timeRangePerTrialSecs','var') || isempty(timeRangePerTrialSecs)
    timeRangePerTrialSecs = [0 Inf]; %all
else
    if timeRangePerTrialSecs(1)~=0
        error('frame pulse detection has not been validated if you do not start at time=0')
        %do we throw out the first pulse?
    end
    if timeRangePerTrialSecs(2)<3
        requestedEndDuration= timeRangePerTrialSecs(2)
        error('frame pulse detection has not been validated if you do not have at least some pulses')
        %do we throw out the first pulse?
    end
end

if ~exist('stimClassToAnalyze','var') || isempty(stimClassToAnalyze)
    stimClassToAnalyze='all';
else
    if ~(iscell(stimClassToAnalyze) ) % and they are all chars
        stimClassToAnalyze
        error('must be a cell of chars of SM classes or ''all'' ')
    end
end

if ~exist('usePhotoDiodeSpikes','var') || isempty(usePhotoDiodeSpikes)
    usePhotoDiodeSpikes=false;
end

if ~exist('overwriteAll','var') || isempty(overwriteAll)
    overwriteAll=false;
end


if ~exist('plottingParams','var') || isempty(plottingParams)
    plottingParams.showSpikeAnalysis = true;
    plottingParams.showLFPAnalysis = true;
    plottingParams.plotSortingForTesting = true;
end

if ~exist('frameThresholds','var') || isempty(frameThresholds)
    frameThresholds.dropBound = 1.5;   %smallest fractional length of ifi that will cause the long tail to be called a drop(s)
    frameThresholds.warningBound = 0.1; %fractional difference that will cause a warning, (after drop adjusting)
    frameThresholds.errorBound = 0.5;   %fractional difference of ifi that will cause an error (after drop adjusting)
    frameThresholds.dropsAcceptableFirstNFrames=2; % first 2 frames won't kill the default quality test               
end

%% ANALYSIS LOGICALS SET HERE FOR FIRST PASS
switch analysisMode
    case 'overwriteAll'
        [detect sort inspect interactive analyze viewAnalysis] = deal(true, true, true, false, true,  true);
    case 'viewFirst'
        [detect sort inspect interactive analyze viewAnalysis] = deal(false, false, true, false, false,  false);
    case 'buildOnFirst'
        [detect sort inspect interactive analyze viewAnalysis] = deal(true, true, true, true, false,  true);
    case 'viewAnalysisOnly'
        [detect sort inspect interactive analyze viewAnalysis] = deal(false, false, false, false, false,  true);
    case 'interactiveDetectAndSortOnFirst'
        [detect sort inspect interactive analyze viewAnalysis] = deal(true, true, false, true, false,  false);
    case 'interactiveDetectAndSortOnAll'
        [detect sort inspect interactive analyze viewAnalysis] = deal(true, false, false, false, false,  false);
    case 'analyzeAtEnd'
        [detect sort inspect interactive analyze viewAnalysis] = deal(true, true, false, false, false,  false);
    otherwise
        error(sprintf('analysisMode: ''%s'' not supported',analysisMode));
end
logicals.detect = detect;
logicals.sort = sort;
logicals.inspect = inspect;
logicals.interactive = interactive;
logicals.analyze = analyze;
logicals.viewAnalysis = viewAnalysis;

% above logicals will change over the course of the analysis
%% MAKE SURE EVERYTHING REQUIRED FOR THE ANALYSIS GIVEN THE ANALYSIS MODE EXIST

done = false;
currentTrialNum = boundaryRange(1);
analyzeChunk = true;

while ~done
    disp(sprintf('analyzing trial number: %d',currentTrialNum));
    % how many chunks exist for currentTrialNum?
    %% find the neuralRecords
    dirStr=fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-*.mat',currentTrialNum));
    d=dir(dirStr);
    if length(d)==1
        neuralRecordFilename=d(1).name;
        % get the timestamp
        [matches tokens] = regexpi(d(1).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            %         warning('not a neuralRecord file name');
        else
            timestamp = tokens{1}{2};
            currentTrialStartTime=datenumFor30(timestamp);
        end
        neuralRecordExists = true;
    elseif length(d)>1
        disp('duplicates present. skipping trial');
        neuralRecordExists = false;
    else
        disp('didnt find anything in d. skipping trial');
        neuralRecordExists = false;
    end
    
    if neuralRecordExists
        % setup filenames and paths -- could be a function...
        stimRecordLocation = fullfile(path,subjectID,'stimRecords',sprintf('stimRecords_%d-%s.mat',currentTrial,timestamp));
        neuralRecordLocation = fullfile(path,subjectID,'neuralRecords',sprintf('neuralRecords_%d-%s.mat',currentTrial,timestamp));
        
        % look at the neuralRecord and see if there are any new chunks to process
        disp('checking chunk names... may be slow remotely...'); tic;
        chunkNames=who('-file',neuralRecordLocation);
        fprintf(' %2.2f seconds',toc)
        chunksAvailable=[];
        for i=1:length(chunkNames)
            [matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
            if length(matches) ~= 1
                continue;
            else
                chunkN = str2double(tokens{1}{1});
                chunksAvailable(end+1)=chunkN;
            end
        end
        chunksAvailable = sort(chunksAvailable);
    end
    
    for currentChunkInd = chunksAvailable
        analyzeChunk = verifyAnalysisForChunk(path, subjectID, boundaryRange, maskInfo, stimClassToAnalyze, currentTrialNum, neuralRecordExists);
        if analyzeChunk
            if detect
                % load and validate neuralRecords (check if faster if function is inline)
                neuralRecord = getNeuralRecordForCurrentTrialAndChunk(neuralRecordLocation,currentChunkInd);
                
                if ~validatedParams
                    % happens when no the number of channels is unknown
                    [validatedParams spikeDetectionParams spikeSortingParams] = ...
                        validateAndSetDetectionAndSortingParams(spikeDetectionParams,...
                        spikeSortingParams,channelAnalysisMode,[],neuralRecord.ai_parameters.channelConfiguration)
                    if ~validatedParams
                    % is params not validated here, something is fishy
                        error('something wrong with parameters given in');
                    end
                    % save spikeDetection and spikeSorting params to analysispath
                    detectionAndSortingParamFile = fullfile(analysisPath,'detectionAndSortingParams.mat');
                    save(detectionAndSortingParamFile,'spikeSortingParams','spikeDetectionParams');
                end    
                % loop through trodes and detect spikes
                [spikes spikeWaveforms spikeTimestamps] = detectSpikesFromNeuralData(neuralData,neuralDataTimes,spikeDetectionParams,analysisPath);
                % now logic for switching the status of detect
            end
            if sort
                % sort spikes
                % now logic for switching status of sort
            end
            if analyze
                % analyze spikes
                % now logic for switching analyze
            end
        end
    end
    % logic for changing status of done
end

end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [boundaryRange maskInfo] =validateCellBoundary(cellBoundary)
if iscell(cellBoundary) && length(cellBoundary)==2
    boundaryType = cellBoundary{1};
    switch boundaryType
        case 'trialRange'
            if any(~isnumeric(cellBoundary{2}))
                error('invalid parameters for trialRange cellBoundary');
            end
            switch length(cellBoundary{2})
                case 2
                    %okay, thats normal
                case 1
                    %start trial is the stop trial
                    cellBoundary{2}=[cellBoundary{2} cellBoundary{2}];
                otherwise
                    error('must be length 2 for [start stop] or a single trial number')
            end
            boundaryRange=[cellBoundary{2}(1) 1 cellBoundary{2}(2) Inf]; % [startTrial startChunk endTrial endChunk]
        case 'trialAndChunkRange'
            if ~iscell(cellBoundary{2}) || length(cellBoundary{2})~=2 || length(cellBoundary{2}{1})~=2 || length(cellBoundary{2}{2})~=2
                error('trialAndChunkRange cellBoundary must be in format {''trialAndChunkRange'',{[startTrial startChunk], [endTrial endChunk]}}');
            end
            boundaryRange=[cellBoundary{2}{1}(1) cellBoundary{2}{1}(2) cellBoundary{2}{2}(1) cellBoundary{2}{2}(2)]; % [startTrial startChunk endTrial endChunk]
        case 'physLog'
            boundaryRange = getCellBoundaryFromEventLog(subjectID,cellBoundary{2},neuralRecordsPath);
            startSysTime=boundaryRange(3);
            endSysTime=boundaryRange(6);
            boundaryRange=boundaryRange([1 2 4 5]);
        otherwise
            error('bad type of cellBoundary!');
    end
    maskInfo.maskType = 'none';
    maskInfo.maskON = false;
    maskInfo.maskRange = [];
elseif iscell(cellBoundary) && length(cellBoundary)==4
    boundaryType = cellBoundary{1};
    switch boundaryType
        case 'trialRange'
            if any(~isnumeric(cellBoundary{2}))
                error('invalid parameters for trialRange cellBoundary');
            end
            switch length(cellBoundary{2})
                case 2
                    %okay, thats normal
                case 1
                    %start trial is the stop trial
                    cellBoundary{2}=[cellBoundary{2} cellBoundary{2}];
                otherwise
                    error('must be length 2 for [start stop] or a single trial number')
            end
            boundaryRange=[cellBoundary{2}(1) 1 cellBoundary{2}(2) Inf]; % [startTrial startChunk endTrial endChunk]
        case 'trialAndChunkRange'
            if ~iscell(cellBoundary{2}) || length(cellBoundary{2})~=2 || length(cellBoundary{2}{1})~=2 || length(cellBoundary{2}{2})~=2
                error('trialAndChunkRange cellBoundary must be in format {''trialAndChunkRange'',{[startTrial startChunk], [endTrial endChunk]}}');
            end
            boundaryRange=[cellBoundary{2}{1}(1) cellBoundary{2}{1}(2) cellBoundary{2}{2}(1) cellBoundary{2}{2}(2)]; % [startTrial startChunk endTrial endChunk]
        case 'physLog'
            boundaryRange = getCellBoundaryFromEventLog(subjectID,cellBoundary{2},neuralRecordsPath);
            startSysTime=boundaryRange(3);
            endSysTime=boundaryRange(6);
            boundaryRange=boundaryRange([1 2 4 5]);
        otherwise
            error('bad type of cellBoundary!');
    end
    maskType = cellBoundary{3};
    switch maskType
        case 'trialMask'
            if any(~isnumeric(cellBoundary{4}))
                error('invalid parameters for maskRange');
            end
            maskRange = cellBoundary{4};
        otherwise
            error('mask type is not supported');
    end
    maskInfo.maskType = maskType;
    maskInfo.maskRange = maskRange;
    maskInfo.maskON = true;
else
    error('bad cellBoundary input');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [analysisPath analysisDirForRange]= createAnalysisPathString(boundaryRange,path,subjectID)
if boundaryRange(1)==boundaryRange(3)
    analysisDirForRange = sprintf('%d',boundaryRange(1));
else
    analysisDirForRange = sprintf('%d-%d',boundaryRange(1),boundaryRange(3));
end
analysisPath = fullfile(path,subjectID,'analysis',analysisDirForRange);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [detectionAndSortingParamsValidated spikeDetectionParams spikeSortingParams] = ...
    validateAndSetDetectionAndSortingParams(spikeDetectionParams,spikeSortingParams,channelAnalysisMode,trodes,channelConfiguration)
% This deals with the logic of when spikeDetectionParams and
% spikeSortingParams are set. When the trodes are pre-specified, then this
% function is called without channelConfiguration. Else, channelConfiguration
% is required.

if ~exist('spikeDetectionParams','var') || ~exist('spikeSortingParams','var')
    error('spikeDetectionParams and spikeSortingParams should exist here');
end
    
detectionAndSortingParamsValidated = false;
switch channelAnalysisMode
    case 'onlySomeChannels'
        % here trodes data should exist and this determines how many
        % channels. 
        if ~exist('trodes','var')|| isempty(trodes)
            error('channelAnalysisMode:''%s'' requires the variable trode',channelAnalysisMode);
        end
        numTrodes = length(trodes);
    case 'allPhysChannels'
        % it typically comes in here only when we dont know what the
        % channels we want to analyze are.
        % make sure that channelConfiguration exists
        if ~exist('channelConfiguration','var') || isempty(channelConfiguration)
            warning('channelConfiguration is needed for channelAnalysisMode:''%s''. returning input values for params',channelAnalysisMode);
            return;
        end
        
        % what does the neuralData say about trode info?
        trodesFromNeuralData = {};
        % find the physInds
        allPhysInds = find(~cellfun(@isempty, strfind(channelConfiguration,'phys')));
        for thisPhysInd = allPhysInds
            tokens = regexpi(channelConfiguration{thisPhysInd},'phys(\d+)','tokens');
            trodesFromNeuralData{end+1} = str2num(tokens{1}{1});
        end
        
        if ~exist('trodes','var') || isempty(trodes)
            trodes = trodeFromNeuralData;
        end
        numTrodes = length(trodes);
        
    otherwise
        error('channelAnalysisMode: ''%s'' is not supported',channelAnalysisMode);
end

% now we have all the trode nums. if spikeDetection and spikesortingParams 
% have same length as numTrodes, return them; if spikeSortingParams and
% spikeDetectionParams are empty, create standard ones; if they
% have length 1, repmat.

% spikeDetectionParams
switch length(spikeDetectionParams)
    case 0
        % provide standard values
        % spikeDetectionParams
        spikeDetectionParams.method = 'oSort';
        spikeDetectionParams.ISIviolationMS=2;
        spikeDetectionParams = repmat(spikeDetectionParams,numTrodes,1);
        for i = 1:numTrodes
            spikeDetectionParams(i).trodeChans = trodes{i};
        end
    case 1
        % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
        if strcmp(spikeDetectionParams.method,'activeSortingParams')
            % get the active paramfile and error check
            spikeDetectionParams = load(spikeDetectionParams.activeParamLocation,'spikeDetectionParams');
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            if length(spikeDetectionParams) ~= numTrodes
                spikeDetectionParams
                numTrodes
                error('activeParamLocation does not have spikeDetectionParams with the right number of trodes');
            end
        else
            % here just repmat, and name the trodes
            spikeDetectionParams = repmat(spikeDetectionParams,numTrodes,1);
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            for i = 1:numTrodes
                spikeDetectionParams(i).trodeChans = trodes{i};
            end
        end
        
    case numTrodes
        % do nothing
    otherwise
        spikeDetectionParams        
        numTrodes
        error('given parameter length for spikeDetectionParams and number of trodes do not match')
end

% spikeSortingParams
switch length(spikeSortingParams)
    case 0
        % provide standard values
        spikeSortingParams.method = 'oSort';
        spikeSortingParams = repmat(spikeSortingParams,numTrodes,1)
        for i = 1:numTrodes
            spikeSortingParams(i).trodeChans = trodes{i};
        end
    case 1
        % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
        if strcmp(spikeSortingParams.method,'activeSortingParams')
            % get the active paramfile and error check
            spikeSortingParams = load(spikeSortingParams.activeParamLocation,'spikeSortingParams');
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            if length(spikeSortingParams) ~= numTrodes
                spikeSortingParams
                numTrodes
                error('activeParamLocation does not have spikeSortingParams with the right number of trodes');
            end
        else
            % here just repmat, and name the trodes
            spikeSortingParams = repmat(spikeSortingParams,numTrodes,1);
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            for i = 1:numTrodes
                spikeSortingParams(i).trodeChans = trodes{i};
            end
        end        
    case numTrodes
        % do nothing
    otherwise
        spikeSortingParams
        numTrodes
        error('given parameter length for spikeSortingParams and number of trodes do not match')
end
detectionAndSortingParamsValidated = true;            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analyzeChunk = verifyAnalysisForChunk(path, subjectID, boundaryRange, maskInfo, ...
    stimClassToAnalyze, trialNum, neuralRecordExists)

analyzeChunk = true;
trialClass = getClassForTrial(path, subjectID, currentTrialNum);    
if (currentTrialNum<boundaryRange(1) || currentTrialNum>boundaryRange(3)) ||...
        (~strcmpi(stimClassToAnalyze, 'all') && ~any(strcmpi(stimClassToAnalyze, trialClass)))||...
        ~neuralRecordExists    
    analyzeChunk = false;    
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trialClass = getClassForTrial(path, subjectID, currentTrialNum)
stimRecordsPath = fullfile(path,subjectId,'stimRecords');
stimRecordName = sprintf('stimRecord_%d-*',trialNum);
d = dir(fullfile(stimRecordsPath,stimRecordName));
if length(d)>1
    error('duplicates present.');
end
stimRecordName = d.name;
load(fullfile(stimRecordsPath,stimRecordName),'stimManagerClass')
trialClass = stimManagerClass;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function neuralRecord = getNeuralRecordForCurrentTrialAndChunk(neuralRecordLocation,currentChunkInd)
chunkStr=sprintf('chunk%d',currentChunkInd);

disp(sprintf('%s from %s'),chunkStr,neuralRecordLocation); tic;
neuralRecord=stochasticLoad(neuralRecordLocation,{chunkStr,'samplingRate'});
temp=neuralRecord.samplingRate;
neuralRecord=neuralRecord.(chunkStr);
neuralRecord.samplingRate=temp;
disp(sprintf(' %2.2f seconds',toc));

% reconstitute neuralDataTimes from start/end based on samplingRate
neuralRecord.neuralDataTimes=linspace(neuralRecord.neuralDataTimes(1),neuralRecord.neuralDataTimes(end),size(neuralRecord.neuralData,1))';

% check if calculated samplingRate is close to expected samplingRate
if any(abs(((unique(diff(neuralRecord.neuralDataTimes))-(1/neuralRecord.samplingRate))/(1/neuralRecord.samplingRate)))>10^-7)
    samplingRateInterval=(1/neuralRecord.samplingRate)
    foundSamplesSpaces=unique(diff(neuralRecord.neuralDataTimes))
    error('error on the length of one of the frames lengths was more than 1/ ten millionth')
end

%check channel configuration is good for requestedAnalysis
if ~isfield(neuralRecord,'ai_parameters')
    neuralRecord.ai_parameters.channelConfiguration={'framePulse','photodiode','phys1'};
    if size(neuralRecord.neuralData,2)~=3
        error('only expect old unlabeled data with 3 channels total... check assumptions')
    end
end
end