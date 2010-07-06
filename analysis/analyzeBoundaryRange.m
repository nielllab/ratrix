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
    %% cellBoundary with support for masking
if ~exist('cellBoundary','var') || isempty(cellBoundary)
    error('cellBoundary must be a valid input argument - default value is too dangerous here!');
else 
    [boundaryRange maskInfo] = validateCellBoundary(cellBoundary);
end
    %% spikeChannelsAnalyzed
if ~exist('trodes','var') || isempty(trodes)
    channelAnalysisMode = 'allPhysChannels';
    trodes={}; % default all phys channels one by one. will be set when we know how many channels
else
    channelAnalysisMode = 'onlySomeChannels';
    % error check
    if ~(iscell(trodes))
        error('must be a cell of groups of channels');
    elseif length(trodes)>1
        warning('going to try multiple leads in analysis...');
    end
        
end
    %% create the analysisPath and see if it exists
[analysisPath analysisDirForRange]= createAnalysisPathString(boundaryRange,path,subjectID)
prevAnalysisExists =  exist(analysisPath,'dir');
    %% should we backup the analysis?
if prevAnalysisExists && makeBackup
    backupPath = fullfile(path,subjectID,'analysis','backups',sprintf('analysisDirForRange-%s',datestr(now,30)));
    makedir(backupPath);
    [succ,msg,msgID] = moviefile(analysisPath, backupPath);  % includes all subdirectory regardless of permissions
    if ~succ
        msg
        error('failed to make backup')
    end
end
    %% validate spikeDetection and spikeSorting Params
if ~exist('spikeDetectionParams','var')
    spikeDetectionParams = [];
end

if ~exist('spikeSortingParams','var')
    spikeSortingParams = [];
end
[validatedParams spikeDetectionParams spikeSortingParams] = validateAndSetDetectionAndSortingParams(spikeDetectionParams,...
    spikeSortingParams,channelAnalysisMode,trodes); 

if strcmp(channelAnalysisMode,'onlySomeChannels')
    spikeSortingParams = spikeSortingParams(order);
    spikeDetectionParams = spikeDetectionParams(order);
end
    %% createAnalysisPaths here
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
    case {'viewAnalysisOnly'}
        % do nothing
    otherwise
        error('unknown analysisMode: ''%s''',analysisMode)
end
    %% timeRangePerTrialSecs
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
    %% stimClassToAnalyze
if ~exist('stimClassToAnalyze','var') || isempty(stimClassToAnalyze)
    stimClassToAnalyze='all';
else
    if ~(iscell(stimClassToAnalyze) ) % and they are all chars
        stimClassToAnalyze
        error('must be a cell of chars of SM classes or ''all'' ')
    end
end
    %% usePhotoDiodeSpikes
if ~exist('usePhotoDiodeSpikes','var') || isempty(usePhotoDiodeSpikes)
    usePhotoDiodeSpikes=false;
end
    %% plottingParams
if ~exist('plottingParams','var') || isempty(plottingParams)
    plottingParams.showSpikeAnalysis = true;
    plottingParams.showLFPAnalysis = true;
    plottingParams.plotSortingForTesting = true;
end
    %% frameThresholds
if ~exist('frameThresholds','var') || isempty(frameThresholds)
    frameThresholds.dropBound = 1.5;   %smallest fractional length of ifi that will cause the long tail to be called a drop(s)
    frameThresholds.warningBound = 0.1; %fractional difference that will cause a warning, (after drop adjusting)
    frameThresholds.errorBound = 0.5;   %fractional difference of ifi that will cause an error (after drop adjusting)
    frameThresholds.dropsAcceptableFirstNFrames=2; % first 2 frames won't kill the default quality test               
end
%% END ERROR CHECKING



%% SAVE ANALYSISBOUNDARIES
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
%% LOOP THROUGH TRIALS 
while ~done
    disp(sprintf('analyzing trial number: %d',currentTrialNum));
    % how many chunks exist for currentTrialNum?
    %% find the neuralRecords location
    [neuralRecordsExist timestamp] = findNeuralRecordsLocation(neuralRecordsPath, currentTrialNum);
    %% find the stim record locations and available chunks for processing
    chunksAvailable = [];
    if neuralRecordExists
        stimRecordLocation = fullfile(path,subjectID,'stimRecords',sprintf('stimRecords_%d-%s.mat',currentTrialNum,timestamp));
        neuralRecordLocation = fullfile(path,subjectID,'neuralRecords',sprintf('neuralRecords_%d-%s.mat',currentTrialNum,timestamp));
        chunksAvailable = getDetailsFromNeuralRecords(neuralRecordLocation,'numChunks');
    else
        disp(sprintf('skipping analysis for trial %d',currentTrialNum));
    end
    %% snippeting
    snippet = [];
    snippetTimes = [];
    %% LOOP THROUGH CHUNKS
    for currentChunkInd = chunksAvailable
        %% check if we need to analyze chunk based on input requirements
        analyzeChunk = neuralRecordExists && verifyAnalysisForChunk(stimRecordLocation, boundaryRange, maskInfo, stimClassToAnalyze, currentTrialNum);
        %% done
        if analyzeChunk
            %% SPIKE DETECTION
            if detectSpikes
                % initialize currentSpikeRecord to empty         
                currentSpikeRecord = [];
                %% load and validate neuralRecords and detection and sorting parameters
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
                %% find the indices of neuralRecords
                photoInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'photodiode'));
                pulseInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'framePulse'));
                allPhysInds = find(~cellfun(@isempty, strfind(neuralRecord.ai_parameters.channelConfiguration,'phys')));
                %% filter neuralData (timeRangePerTrialSecs, snippets)
                neuralRecord = filterNeuralRecords(neuralRecords,timeRangePerTrialSecs)
                neuralRecord = addSnippetToNeuralData(neuralRecord,snippet,snippetTimes);
                %% get the cumulativeSpikeRecord
                spikeRecord = getSpikeRecords(analysisPath);
                %% get Frame details
                temp = stochasticLoad(stimRecordLocation,'refreshRate');
                ifi = 1/temp.refreshRate;
                currentSpikeRecords =  getFrameDetails(neuralRecord,pulseInd,frameThresholds,ifi,currentTrialNum,currentChunkInd);
                %% create snippet for next chunk
                [snippet snippetTimes neuralRecord] = createSnippetFromNeuralRecords(spikeRecord)
                %% set updateMode='detectSpikes' and update cumulativeSpikeRecord
                updateParams.updateMode = 'frameAnalysis'
                spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,cumulativeSpikeRecord,currentTrialNum,currentChunkInd);
                spikeRecordsFile = fullfile(analysisPath,'spikeRecords.mat');
                save(spikeRecordsFile,'spikeRecord','-append');                
                %% detect relevant spikes (photoDiode or physChans)
                if usePhotoDiodeSpikes
                    currentSpikeRecord = detectPhotoDiodeSpikes(neuralRecord, photoInd,currentSpikeRecord);
                    updateParams.updateMode = 'photoDiodeSpikes';
                else
                    for trodeNum = 1:length(trodes)
                        currTrode = trodes{trodeNum};
                        currTrodeName = createTrodeName(currTrode);
                        % which physInds???
                        thesePhysInds = getPhysIndsForTrodeChans(neuralData.ai_parameter.channelConfiguration,currTrode);
                        currNeuralData = neuralRecord.neuralData(:,thesePhysInds);
                        currNeuralDataTimes = neuralRecord.neuralDataTimes;
                        currSamplingRate = neuralRecords.samplingRate;
                        currSpikeDetectionParams = spikeDetectionParams.(currTrodeName);
                        currentSpikeRecord = detectSpikeForTrode(currentSpikeRecord,currTrode, trodeNum,...
                            currNeuralData,currNeuralDataTimes,currSamplingRate,currSpikeDetectionParams,...
                            currentTrialNum, currentchunkInd)
                    end
                    updateParams.updateMode = 'physSpikes'
                end
                %% update cumulativeSpikeRecord                
                spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,cumulativeSpikeRecord,currentTrialNum,currentChunkInd);
                spikeRecordsFile = fullfile(analysisPath,'spikeRecords.mat');
                save(spikeRecordsFile,'spikeRecord','-append');
                %% now logic for switching the status of detectSpikes
                detectUpdateParams = [];
                detectUpdateParams.analysisMode = analysisMode;
                detectUpdateParams.trialNum = currentTrialNum;
                detectUpdateParams.chunkInd = currentChunkInd;
                detectUpdateParams.boundaryRange = boundaryRange;
                detectUpdateParams.chunksAvailable = chunksAvailable;
                detectSpikes = updateDetectSpikesStatus(detectUpdateParams);
            end            
            %% SPIKE SORTING
            if sortSpikes
                % initialize currentSpikeRecord to empty
                currentSpikeRecord = [];
                %% upload spikeRecord if necessary
                if ~exist('spikeRecords','var')
                    spikeRecord = getSpikeRecords(analysisPath);
                end
                %% get the relevant spikes only
                filterParams = setFilterParamsForAnalysisMode(analysisMode, currentTrialNum, currentChunkInd, analysisBoundaryFile);
                filteredSpikeRecord = filterSpikeRecords(filterParams,cumulativeSpikeRecords);
                %% do we have a model file?
                % it either already exists in spikeSortingParams(sent as an active param file) 
                % or was updated during the course of analysis.
                [spikeModel modelExists] = getSpikeModel(spikeRecord,spikeSortingParams);                
                %% loop through the trodes and sort spikes
                for trodeNum = 1:length(trodes)
                    trodeStr = createTrodeName(trodes{trodeNum});
                    currTrode = trodes{trodeNum};
                    currSpikes = filteredSpikeRecord.(trodeStr).spikes;
                    currSpikeWaveforms = filteredSpikeRecord.(trodeStr).spikeWaveforms;
                    currSpikeTimestamps = filteredSpikeRecord.(trodeStr).spikeTimestamps;
                    currSpikeSortingParams = spikeSortingParams(trodeNum);
                    if modelExists
                        currSpikeSortingParams.method = 'klustaModel';
                    end
                    currentSpikeRecord = sortSpikesForTrode(currentSpikeRecord,currTrode,trodeNum,...
                        currSpikes, currSpikeWaveforms,currSpikeTimestamps, currSpikeSortingParams, spikeModel);
                end
                %% need to update sorted spikes
                updateParams.updateMode = 'sortSpikes'
                spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,cumulativeSpikeRecord,currentTrialNum,currentChunkInd);
                spikeRecordsFile = fullfile(analysisPath,'spikeRecords.mat');
                save(spikeRecordsFile,'spikeRecord','-append');
                %% now logic for switching status of sortSpikes
                sortUpdateParams = [];
                sortUpdateParams.analysisMode = analysisMode;
                sortUpdateParams.trialNum = currentTrialNum;
                sortUpdateParams.chunkInd = currentChunkInd;
                sortUpdateParams.boundaryRange = boundaryRange;
                sortUpdateParams.chunksAvailable = chunksAvailable;
                sortSpikes = updateSortSpikesStatus(sortUpdateParams);
            end
            %% ANALYSIS ON SPIKES
            if analyze
                % analyze spikes
                % now logic for switching analyze
            end
        end
    end
    %% done        
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
%% LOGICALS DEALT WITH HERE
function detectSpikes = updateDetectSpikesStatus(updateParams)
if ~exist('updateParams','var') || isempty(updateParams) || ~isfield(updateParams,'updateMode') || isempty(updateParams.updateMode)
    error('make sure updateParams exists and updateMode is specified');
end
switch updateParams.updateMode
    case 'overwriteAll'
        detectSpikes = true;
    otherwise
        error('unknown updateMode');
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
function analyzeChunk = verifyAnalysisForChunk(stimRecordLocation, boundaryRange, maskInfo, ...
    stimClassToAnalyze, currentTrialNum)

analyzeChunk = true;
temp = stochasticLoad(stimRecordLocation,{'stimManagerClass'});
trialClass = temp.stimManagerClass;
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
function thesePhysChannelInds = getPhysIndsForTrodeChans(channelConfiguration,currTrode)
chansRequired=unique(currTrode);
for c=1:length(chansRequired)
    chansRequiredLabel{c}=['phys' num2str(chansRequired(c))];
end

if any(~ismember(chansRequiredLabel,channelConfiguration))
    chansRequiredLabel
    channelConfiguration
    error(sprintf('requested analysis on channels %s but thats not available',char(setdiff(chansRequiredLabel,neuralRecord.ai_parameters.channelConfiguration))))
end
thesePhysChannelLabels = {};
thesePhysChannelInds = [];
for c=1:length(currTrode)
    thesePhysChannelLabels{c}=['phys' num2str(currTrode(c))];
    thesePhysChannelInds(c)=find(ismember(channelConfiguration,thesePhysChannelLabels{c}));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function currentSpikeRecord = detectSpikeForTrode(currentSpikeRecord,trode,trodeNum,neuralData,neuralDataTimes,...
    samplingRate,spikeDetectionParams,trialNum,chunkInd)
spikeDetectionParams.samplingFreq = samplingRate; % spikeDetectionParams needs samplingRate
[spikes spikeWaveforms spikeTimestamps] = detectSpikesFromNeuralData(neuralData, neuralDataTimes, spikeDetectionParams);

% update currentSpikeRecords
trodeStr = createTrodeName(trode);
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
function spikeRecord = detectPhotoDiodeSpikes(neuralRecord, photoInd, spikeRecord)
[spikeRecord.spikes spikeRecord.spikeWaveforms spikeRecord.photoDiode]=...
    getSpikesFromPhotodiode(neuralRecord.neuralData(:,photoInd),...
    neuralRecord.neuralDataTimes, spikeRecord.correctedFrameIndices,neuralRecord.samplingRate);
spikeRecord.spikeTimestamps = neuralRecord.neuralDataTimes(spikeRecord.spikes);
spikeRecord.assignedClusters=[ones(1,length(spikeRecord.spikeTimestamps))]';
spikeRecord.processedClusters=spikeRecord.assignedClusters'; % select all of them as belonging to a processed group
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function currentSpikeRecord = sortSpikesForTrode(currentSpikeRecord,currTrode,trodeNum,...
    currSpikes, currSpikeWaveforms,currSpikeTimestamps, currSpikeSortingParams, spikeModel)
trodeStr = createTrodeName(currTrode);
if isstruct(spikeModel) && isfield(spikeModel,trodeStr)
    currSpikeModel = spikeModel.(trodeStr);
else
    currSpikeModel = [];
end
[assignedClusters rankedClusters currSpikeModel] = sortSpikesDetected(currSpikes,...
    currSpikeWaveforms, currSpikeTimestamps, currSpikeSortingParams, currSpikeModel);
spikeDetails = postProcessSpikeClusters(assignedClusters,...
    rankedClusters,currSpikeSortingParams,currSpikeWaveforms);

currentSpikeRecord.(trodeStr).spikeModel = currSpikeModel;
currentSpikeRecord.(trodeStr).assignedClusters = assignedClusters;
currentSpikeRecord.(trodeStr).rankedClusters = rankedClusters;
currentSpikeRecord.(trodeStr).processedClusters = spikeDetails.processedClusters;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spikeRecord =  getFrameDetails(neuralRecord,pulseInd,frameThresholds,ifi,trialNum,chunkInd)
[spikeRecord.frameIndices spikeRecord.frameTimes spikeRecord.frameLengths spikeRecord.correctedFrameIndices...
    spikeRecord.correctedFrameTimes spikeRecord.correctedFrameLengths spikeRecord.stimInds spikeRecord.passedQualityTest] = ...
    getFrameTimes(neuralRecord.neuralData(:,pulseInd),neuralRecord.neuralDataTimes,neuralRecord.samplingRate,...
    frameThresholds.dropBound, frameThresholds.warningBound, frameThresholds.errorBound,ifi, frameThresholds.dropsAcceptableFirstNFrames);
spikeRecord.chunkIDForCorrectedFrames=ones(length(spikeRecord.stimInds),1)*chunkInd;
spikeRecord.chunkIDForFrames=ones(size(spikeRecord.frameIndices,1),1)*chunkInd;
spikeRecord.trialNumForCorrectedFrames=ones(length(spikeRecord.stimInds),1)*trialNum;
spikeRecord.trialNumForFrames=ones(size(spikeRecord.frameIndices,1),1)*trialNum;
end




