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
    % the default state of trode is based on ascending order of the first lead in trode
    disp('the input is ');
    [vals order] = sort(cellfun(@(v)v(1),trodes));
    trodes = trodes(order)
    % error check
    if ~(iscell(trodes))
        error('must be a cell of groups of channels');
    elseif length(trodes)>1
        warning('going to try multiple leads in analysis...');
    end
        
end

% create the analysisPath and see if it exists
[analysisPath analysisDirForRange]= createAnalysisPathString(boundaryRange,path,subjectID)
prevAnalysisExists =  exist(analysisPath,'dir');

% should we backup the analysis?
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
            [succ,msg,msgID] = rmdir(analysisPath,'s');  % includes all subdirectory regardless of permissions
            if ~succ
                msg
                error('failed to remove existing files when running with ''overwriteAll=true''')
            end
            prevAnalysisExists = false;
        end
        % recreate the analysis file
        mkdir(analysisPath);        
        % lets see if spikeDetection and spikeSorting is specified for all trodesNums
        [validatedParams spikeDetectionParams spikeSortingParams] = validateAndSetDetectionAndSortingParams(spikeDetectionParams,...
            spikeSortingParams,channelAnalysisMode,trodes);        
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

% lets save the analysis boundaries in a file called analysisBoundary
% analysisoundaryFile should have everything required to recreate the analysis. 
analysisBoundaryFile = fullfile(analysisPath,'analysisBoundary.mat');
save(analysisBoundaryFile,'boundaryRange','maskInfo','trodes','spikeDetectionParams','spikeSortingParams',...
    'timeRangePerTrialSecs','stimClassToAnalyze','analysisMode','usePhotoDiodeSpikes','plottingParams','frameThresholds');
        
%% ANALYSIS LOGICALS SET HERE FOR FIRST PASS
switch analysisMode
    case 'overwriteAll'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(true, true, true, false, true,  true);
    case 'viewFirst'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(false, false, true, false, false,  false);
    case 'buildOnFirst'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(true, true, true, true, false,  true);
    case 'viewAnalysisOnly'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(false, false, false, false, false,  true);
    case 'interactiveDetectAndSortOnFirst'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(true, true, false, true, false,  false);
    case 'interactiveDetectAndSortOnAll'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(true, false, false, false, false,  false);
    case 'analyzeAtEnd'
        [detectSpikes sortSpikes inspect interactive analyze viewAnalysis] = deal(true, true, false, false, false,  false);
    otherwise
        error(sprintf('analysisMode: ''%s'' not supported',analysisMode));
end

% above logicals will change over the course of the analysis
%% MAKE SURE EVERYTHING REQUIRED FOR THE ANALYSIS GIVEN THE ANALYSIS MODE EXIST

done = false;
currentTrialNum = boundaryRange(1);
analyzeChunk = true;

while ~done
    disp(sprintf('analyzing trial number: %d',currentTrialNum));
    % how many chunks exist for currentTrialNum?
    %% find the neuralRecords
    [neuralRecordsExist timestamp] = findNeuralRecordsLocation(neuralRecordsPath, currentTrialNum);
        
    chunksAvailable = [];
    if neuralRecordExists
        stimRecordLocation = fullfile(path,subjectID,'stimRecords',sprintf('stimRecords_%d-%s.mat',currentTrialNum,timestamp));
        neuralRecordLocation = fullfile(path,subjectID,'neuralRecords',sprintf('neuralRecords_%d-%s.mat',currentTrialNum,timestamp));
        chunksAvailable = getDetailsFromNeuralRecords(neuralRecordLocation,'numChunks');
    else
        disp(sprintf('skipping analysis for trial %d',currentTrialNum));
    end
    for currentChunkInd = chunksAvailable
        analyzeChunk = verifyAnalysisForChunk(path, subjectID, boundaryRange, maskInfo, stimClassToAnalyze, currentTrialNum, neuralRecordExists);
        if analyzeChunk
            % initialize currentSpikeRecord to empty at the beginning of each chunk
            currentSpikeRecord = [];
            if detectSpikes
                % load and validate neuralRecords
                neuralRecord = getNeuralRecordForCurrentTrialAndChunk(neuralRecordLocation,currentChunkInd);                
                if ~validatedParams
                    % happens when the number of channels is unknown
                    [validatedParams spikeDetectionParams spikeSortingParams] = ...
                        validateAndSetDetectionAndSortingParams(spikeDetectionParams,...
                        spikeSortingParams,channelAnalysisMode,[],neuralRecord.ai_parameters.channelConfiguration);
                    trodes = {spikeDetectionParams.trodeChans};
                    % save spikeDetection and spikeSorting params to analysisBoundaryFile
                    save(analysisBoundaryFile,'spikeSortingParams','spikeDetectionParams','trodes','-append');
                end
                
                % where to save the spikes
                cumulativeSpikeRecord = getSpikeRecords(analysisPath);
                % loop through trodes and detect spikes
                for trodeNum = 1:length(trodes)
                    currTrode = trodes{trodeNum};
                    currNeuralData = neuralRecord.neuralData(:,currTrode);
                    currNeuralDataTimes = neuralRecord.neuralDataTimes;
                    currSamplingRate = neuralRecords.samplingRate;
                    currSpikeDetectionParams = spikeDetectionParams(trodeNum);
                    currentSpikeRecord = detectSpikeForTrode(currentSpikeRecord,currentTrode, trodeNum,...
                        currNeuralData,currNeuralDataTimes,currSamplingRate,currSpikeDetectionParams,...
                        currentTrialNum, currentchunkInd)
                end
                updateParams.updateMode = 'detectSpikes'
                cumulativeSpikeRecord = updateCumulativeSpikeRecords(updateParams,currentSpikeRecord,cumulativeSpikeRecord,currentTrialNum,currentChunkInd);
                cumulativeSpikeRecordFile = fullfile(analysisPath,'cumulativeSpikeRecord.mat');
                save(cumulativeSpikeRecordFile,'cumulativeSpikeRecord','-append');
                % now logic for switching the status of detectSpikes
                detectSpikes = updateDetectSpikesStatus(detectSpikes,analysisMode,currentTrialNum,currentChunkInd,boundaryRange,chunksAvailable);
            end
            
            if sortSpikes
                % upload cumulativeSpikeRecord if necessary
                if ~exist('cumulativeSpikeRecord','var')
                    cumulativeSpikeRecord = getSpikeRecords(analysisPath);
                end
                filterParams = setFilterParamsForAnalysisMode(analysisMode, currentTrialNum, currentChunkInd, boundaryRange);
                filteredSpikeRecord = filterSpikeRecords(filterParams,cumulativeSpikeRecords);
                % sort spikes
                for trodeNum = 1:length(trodes)

                    [assigned rank] = sortSpikesDetected(spikes, spikeWaveforms, spikeTimestamps, spikeSortingParams, analysisPath);
                end
                % now logic for switching status of sortSpikes
            end
            
            if analyze
                % analyze spikes
                % now logic for switching analyze
            end
        end
    end
    currentTrialNum = currentTrialNum+1;
    % logic for changing status of done
    if currentTrialNum>boundaryRange(3)
        done = true;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SOME FUNCTIONS TO MAKE CODE EASIER TO READ
function [neuralRecordExists timestamp] = findNeuralRecordsLocation(neuralRecordsPath, currentTrialNum)
dirStr=fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-*.mat',currentTrialNum));
d=dir(dirStr);
neuralRecordExists = false;
timestamp = '';
if length(d)==1
    neuralRecordFilename=d(1).name;
    % get the timestamp
    [matches tokens] = regexpi(d(1).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
    if length(matches) ~= 1
        %         warning('not a neuralRecord file name');
    else
        timestamp = tokens{1}{2};
    end
    neuralRecordExists = true;
elseif length(d)>1
    disp('duplicates present. skipping trial');
else
    disp('didnt find anything in d. skipping trial');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analyzeChunk = verifyAnalysisForChunk(path, subjectID, boundaryRange, maskInfo, ...
    stimClassToAnalyze, currentTrialNum)

analyzeChunk = true;
trialClass = getClassForTrial(path, subjectID, currentTrialNum);    
if (currentTrialNum<boundaryRange(1) || currentTrialNum>boundaryRange(3)) ||...
        (~strcmpi(stimClassToAnalyze, 'all') && ~any(strcmpi(stimClassToAnalyze, trialClass)))
    analyzeChunk = false;    
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function neuralRecord = getNeuralRecordForCurrentTrialAndChunk(neuralRecordLocation,currentChunkInd)
chunkStr=sprintf('chunk%d',currentChunkInd);

disp(sprintf('%s from %s',chunkStr,neuralRecordLocation)); tic;
neuralRecord = getDetailsFromNeuralRecords(neuralRecordLocation,chunkStr);
neuralRecord.samplingRate = getDetailsFromNeuralRecords(neuralRecordLocation,'samplingRate');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function currentSpikeRecord = detectSpikeForTrode(currentSpikeRecord,trode,trodeNum,neuralData,neuralDataTimes,...
    samplingRate,spikeDetectionParams,trialNum,chunkInd)
spikeDetectionParams.samplingFreq = samplingRate; % spikeDetectionParams needs samplingRate
[spikes spikeWaveforms spikeTimestamps] = detectSpikesFromNeuralData(neuralData, neuralDataTimes, spikeDetectionParams);

% update currentSpikeRecords
trodeStr = sprintf('trode%d',trodeNum);
currentSpikeRecord.(trodeStr).trodeChans        = trode;
currentSpikeRecord.(trodeStr).spikes            = spikes;
currentSpikeRecord.(trodeStr).spikeWaveforms    = spikeWaveforms;
currentSpikeRecord.(trodeStr).spikeTimestamps   = spikeTimestamps;
% fill in details about trial and chunk
currentSpikeRecord.(trodeStr).chunkID = chunkInd*ones(size(spikes));
currentSpikeRecord.(trodeStr).trialNum = trialNum*ones(size(spikes));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOGICALS DEALT WITH HERE
function detectSpikes = updateDetectSpikesStatus(detectSpikes,analysisMode,currentTrialNum,...
    currentChunkInd,boundaryRange,chunksAvailable)
detectSpikes = true;
end


