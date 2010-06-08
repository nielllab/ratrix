function  viewAllSpikesByChannel(subjectID, path, cellBoundary, spikeDetectionParams, spikeSortingParams)

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
    neuralRecordsPath
    error('unable to find directory to neuralRecords');
end

if ~exist('cellBoundary','var') || isempty(cellBoundary)
    error('cellBoundary must be a valid input argument - default value is too dangerous here!');
elseif iscell(cellBoundary) && length(cellBoundary)==2
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

% activeParamFile = fullfile('\\132.239.158.179\datanet_storage\',subjectID,'activeSortingParams.mat');
% if ~exist('spikeDetectionParams','var') || isempty(spikeDetectionParams)
%     spikeDetectionParams.method='oSort';
%     spikeDetectionParams.ISIviolationMS=2;
% elseif strcmp(spikeDetectionParams.method,'activeSortingParameters')
%     % get spikeDetectionParams from activeSortingParameters.mat
%     spikeDetectionParams=load(activeParamFile,'spikeDetectionParams');
% elseif strcmp(spikeDetectionParams.method,'activeSortingParametersThisAnalysis')
%     %will load below
% end
%
% if ~exist('spikeSortingParams','var') || isempty(spikeSortingParams)
%     spikeSortingParams.method='oSort';
% elseif strcmp(spikeSortingParams.method,'activeSortingParameters')
%     % get spikeSortingParams from activeSortingParameters.mat
%     spikeSortingParams=load(activeParamFile,'spikeSortingParams');
% end
%
% if ~exist('timeRangePerTrialSecs','var') || isempty(timeRangePerTrialSecs)
%     timeRangePerTrialSecs = [0 Inf]; %all
% else
%     if timeRangePerTrialSecs(1)~=0
%         error('frame pulse detection has not been validated if you do not start at time=0')
%         %do we throw out the first pulse?
%     end
%     if timeRangePerTrialSecs(2)<3
%         requestedEndDuration= timeRangePerTrialSecs(2)
%         error('frame pulse detection has not been validated if you do not have at least some pulses')
%         %do we throw out the first pulse?
%     end
% end

% if ~exist('stimClassToAnalyze','var') || isempty(stimClassToAnalyze)
%     stimClassToAnalyze='all';
% else
%     if ~(iscell(stimClassToAnalyze) ) % and they are all chars
%         stimClassToAnalyze
%         error('must be a cell of chars of SM classes or ''all'' ')
%     end
% end

% if ~exist('usePhotoDiodeSpikes','var') || isempty(usePhotoDiodeSpikes)
%     usePhotoDiodeSpikes=false;
% end
%
% if ~exist('overwriteAll','var') || isempty(overwriteAll)
%     overwriteAll=false;
% end


% if ~exist('plottingParams','var') || isempty(plottingParams)
%     plottingParams.showSpikeAnalysis = true;
%     plottingParams.showLFPAnalysis = true;
%     plottingParams.plotSortingForTesting = true;
% end
%
% if ~exist('frameThresholds','var') || isempty(frameThresholds)
%     frameThresholds.dropBound = 1.5;   %smallest fractional length of ifi that will cause the long tail to be called a drop(s)
%     frameThresholds.warningBound = 0.1; %fractional difference that will cause a warning, (after drop adjusting)
%     frameThresholds.errorBound = 0.5;   %fractional difference of ifi that will cause an error (after drop adjusting)
%     frameThresholds.dropsAcceptableFirstNFrames=2; % first 2 frames won't kill the default quality test
% end


% if ~exist('paramUtil','var') || isempty(paramUtil)
%    paramUtil=[]; % don't do anything
% end
for currentTrialNum = boundaryRange(1):boundaryRange(3)
    % look for currentTrial's neuralRecord
    dirStr=fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-*.mat',currentTrial));
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
    elseif length(d)>1
        disp('duplicates present');
        currentTrial = min(currentTrial+1,boundaryRange(3));
        continue;
    else
        disp('didnt find anything in d');
        currentTrial=min(currentTrial+1,boundaryRange(3));
        continue;
    end
    % make temporary analysis folder
    analysisPath = fullfile(path,ratID,'tempAnalysisFolder');
    % first delete folder if it exists
    if exist(analysisPath,'dir')
        [succ,msg,msgID] = rmdir(baseAnalysisPath,'s');  % includes all subdirectory regardless of permissions
        
        if ~succ
            msg
            error('failed to remove existing files when running with ''overwriteAll=true''')
        else
            haveDeletedAnalysisRecords=true;
        end
    end
    % now make it again
    if ~isdir(analysisPath)
        mkdir(analysisPath);
    end
    
    %DETERMINE CHUNKS TO PROCESS
    if 0
        %a faster way of doing this once we save the num chunks explicitly in a variable
        varIn=load(neuralRecordLocation,'numChunks');
        for chunkN=1:varIn.numChunks
            if ~isempty(processedChunks) && ~isempty(find(processedChunks(:,2)==chunkN&processedChunks(:,1)==currentTrial))
                % already processed - pass
            elseif chunkN>=currentChunkBoundary(1) && chunkN<=currentChunkBoundary(2)
                chunksToProcess=[chunksToProcess; currentTrial chunkN];
            end
        end
    else % slower back compatible method
        % look at the neuralRecord and see if there are any new chunks to process
        disp('checking chunk names... may be slow remotely...'); tic;
        chunkNames=who('-file',neuralRecordLocation);
        fprintf(' %2.2f seconds',toc)
        chunksToProcess=[];
        for i=1:length(chunkNames)
            [matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
            if length(matches) ~= 1
                continue;
            else
                chunkN = str2double(tokens{1}{1});
            end
        end
    end
    
end