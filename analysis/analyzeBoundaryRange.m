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
    [boundaryRange maskOn maskType maskRange] = validateCellBoundary(cellBoundary);
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
    elseif ~all(size(trodes{1})==[1 1])
            warning('going to try multiple leads in analysis...');
    end
        
end

% activeParamFile = fullfile('\\132.239.158.179\datanet_storage\',subjectID,'activeSortingParams.mat');

% create the analysisPath and see if it exists
analysisPath = createAnalysisPathString(boundaryRange,path,subjectID)
prevAnalysisExists =  exist(analysisPath,'dir');

% shouldwe backup the analysis

% make initial assumptions about spike detection and sorting parameters
switch analysisMode 
    case {'overwriteAll','detectAndSortOnFirst','detectAndSortOnOnAll','interactiveDetectAndSortOnFirst','interactiveDetectAndSortOnAll'}
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
        save(analysisBoundaryFile,'boundaryRange','maskOn','maskType','maskRange');
        % lets see if spikeDetection and spikeSorting is specified for all trodesNums
        [spikeDetectionParams spikeSortingParams] = validateAndSetDetectionAndSortingParams(spikeDetectionParams,spikeSortingParams,trodes,channelAnalysisMode);
end


if ~exist('spikeDetectionParams','var') || isempty(spikeDetectionParams)
    spikeDetectionParams.method='oSort';
    spikeDetectionParams.ISIviolationMS=2;
elseif strcmp(spikeDetectionParams.method,'activeSortingParameters')
    % get spikeDetectionParams from activeSortingParameters.mat
    spikeDetectionParams=load(activeParamFile,'spikeDetectionParams');
elseif strcmp(spikeDetectionParams.method,'activeSortingParametersThisAnalysis')
    %will load below
end

if ~exist('spikeSortingParams','var') || isempty(spikeSortingParams)
    spikeSortingParams.method='oSort';
elseif strcmp(spikeSortingParams.method,'activeSortingParameters')
    % get spikeSortingParams from activeSortingParameters.mat
    spikeSortingParams=load(activeParamFile,'spikeSortingParams');
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
    otherwise
        error(sprintf('analysisMode: ''%s'' not supported',analysisMode));
end
%% MAKE SURE EVERYTHING REQUIRED FOR THE ANALYSIS GIVEN THE ANALYSIS MODE EXIST

done = false;
currentTrialNum = boundaryRange(1);

while ~done
    if detect
        % detect spikes
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
    
    % logic for changing status of done
end

end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [boundaryRange maskOn maskType maskRange] =validateCellBoundary(cellBoundary)
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
    maskType = 'none';
    maskON = false;
    maskRange = [];
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
    maskON = true;
else
    error('bad cellBoundary input');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analysisPath = createAnalysisPathString(boundaryRange,path,subjectID)
if boundaryRange(1)==boundaryRange(3)
    analysisDirForRange = sprintf('%d',boundaryRange(1));
else
    analysisDirForRange = sprintf('%d-%d',boundaryRange(1),boundaryRange(3));
end
analysisPath = fullfile(path,subjectID,'analysis',analysisDirForRange);
end