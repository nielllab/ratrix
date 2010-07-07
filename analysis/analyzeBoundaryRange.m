function analyzeBoundaryRange(subjectID, path, cellBoundary, trodes, spikeDetectionParams, spikeSortingParams,...
        timeRangePerTrialSecs, stimClassToAnalyze, analysisMode, plottingParams, frameThresholds,makeBackup)
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
    neuralRecordsPath
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
[analysisPath analysisDirForRange]= createAnalysisPathString(boundaryRange,path,subjectID);
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
    if strcmp(analysisMode,'usePhotoDiodeSpikes')
        usePhotoDiodeSpikes=true;
    else
        usePhotoDiodeSpikes = false;
    end
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
    if neuralRecordsExist
        stimRecordLocation = fullfile(path,subjectID,'stimRecords',sprintf('stimRecords_%d-%s.mat',currentTrialNum,timestamp));
        neuralRecordLocation = fullfile(path,subjectID,'neuralRecords',sprintf('neuralRecords_%d-%s.mat',currentTrialNum,timestamp));
        chunksAvailable = getDetailsFromNeuralRecords(neuralRecordLocation,{'numChunks'});
    else
        disp(sprintf('skipping analysis for trial %d',currentTrialNum));
    end
    %% snippeting
    snippet = [];
    snippetTimes = [];
    %% LOOP THROUGH CHUNKS
    for currentChunkInd = chunksAvailable
        %% check if we need to analyze chunk based on input requirements
        analyzeChunk = neuralRecordsExist && verifyAnalysisForChunk(stimRecordLocation, boundaryRange, maskInfo, stimClassToAnalyze, currentTrialNum);
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
                %% find the photoInd,pulseInd and allPhysInds of neuralRecords
                photoInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'photodiode'));
                pulseInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'framePulse'));
                allPhysInds = find(~cellfun(@isempty, strfind(neuralRecord.ai_parameters.channelConfiguration,'phys')));
                %% filter neuralData (timeRangePerTrialSecs, snippets)
                neuralRecord = filterNeuralRecords(neuralRecord,timeRangePerTrialSecs)
                neuralRecord = addSnippetToNeuralData(neuralRecord,snippet,snippetTimes);
                %% get the spikeRecord
                spikeRecord = getSpikeRecords(analysisPath,analysisMode);
                %% get Frame details
                temp = stochasticLoad(stimRecordLocation,{'refreshRate'});
                ifi = 1/temp.refreshRate;
                currentSpikeRecord =  getFrameDetails(neuralRecord,pulseInd,frameThresholds,ifi,currentTrialNum,...
                    currentChunkInd);
                %% create snippet for next chunk
                [snippet snippetTimes neuralRecord chunkHasFrames] = createSnippetFromNeuralRecords(currentSpikeRecord,...
                    neuralRecord,currentChunkInd,chunksAvailable,currentTrialNum);
                %% some relevant info for future use in deciding analysis
                currentSpikeRecord.chunkHasFrames = chunkHasFrames;
                currentSpikeRecord.trialNum = currentTrialNum;
                currentSpikeRecord.chunkID = currentChunkInd;
                %% update spikeRecord
                updateParams.updateMode = 'frameAnalysis';
                spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,spikeRecord);
                spikeRecordFile = fullfile(analysisPath,'spikeRecord.mat');
                if exist(spikeRecordFile,'file')
                    save(spikeRecordFile,'spikeRecord','-append');
                else
                    save(spikeRecordFile,'spikeRecord');
                end
                %% detect relevant spikes (photoDiode or physChans)
                if usePhotoDiodeSpikes
                    currentSpikeRecord = detectPhotoDiodeSpikes(neuralRecord, photoInd,currentSpikeRecord);
                    updateParams.updateMode = 'photoDiodeSpikes';
                    sortSpikes = false;
                else
                    % loop through the necessary trodes
                    for trodeNum = 1:length(trodes)
                        currTrode = trodes{trodeNum};
                        currTrodeName = createTrodeName(currTrode);
                        % which physInds???
                        thesePhysInds = getPhysIndsForTrodeChans(neuralRecord.ai_parameters.channelConfiguration,currTrode);
                        currNeuralData = neuralRecord.neuralData(:,thesePhysInds);
                        currNeuralDataTimes = neuralRecord.neuralDataTimes;
                        currSamplingRate = neuralRecord.samplingRate;
                        currSpikeDetectionParams = spikeDetectionParams.(currTrodeName);
                        currentSpikeRecord = detectSpikeForTrode(currentSpikeRecord,currTrode, trodeNum,...
                            currNeuralData,currNeuralDataTimes,currSamplingRate,currSpikeDetectionParams,...
                            currentTrialNum, currentChunkInd);
                    end
                    updateParams.updateMode = 'physSpikes';
                end
                %% update spikeRecord                
                spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,spikeRecord);
                spikeRecordFile = fullfile(analysisPath,'spikeRecord.mat');
                if exist(spikeRecordFile,'file')
                    save(spikeRecordFile,'spikeRecord','-append');
                else
                    save(spikeRecordFile,'spikeRecord');
                end
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
                if ~exist('spikeRecord','var')
                    spikeRecord = getSpikeRecords(analysisPath,analysisMode);
                end
                %% filter Spike Records
                filterParams = setFilterParamsForAnalysisMode(analysisMode, currentTrialNum, currentChunkInd, analysisBoundaryFile);
                filteredSpikeRecord = filterSpikeRecords(filterParams,spikeRecord);
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
                    if modelExists
                        currSpikeSortingParams.method = 'klustaModel';
                    else
                        currSpikeSortingParams = spikeSortingParams.(trodeStr);
                    end
                    currentSpikeRecord = sortSpikesForTrode(currentSpikeRecord,currTrode,trodeNum,...
                        currSpikes, currSpikeWaveforms,currSpikeTimestamps, currSpikeSortingParams, spikeModel);
                end
                %% update cumulativeSpikeRecord
                updateParams.updateMode = 'sortSpikes';
                updateParams.updateSpikeModel = ~modelExists;
                spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,spikeRecord);
                spikeRecordFile = fullfile(analysisPath,'spikeRecord.mat');
                if exist(spikeRecordFile,'file')
                    save(spikeRecordFile,'spikeRecord','-append');
                else
                    save(spikeRecordFile,'spikeRecord');
                end
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
                %% initialize analysisdata
                analysisdata = []; %analysis data is set to null to begin with
                %% upload physAnalysis if necessary
                if ~exist('physAnalysis','var')
                    physAnalysisFile = getPhysAnalysis(analysisPath,analysisMode);
                end
                %% upload spikeRecord if necessary and filter
                if ~exist('spikeRecord','var')
                    spikeRecord = getSpikeRecords(analysisPath,analysisMode);
                end
                % physAnalysis is only supported per trial
                filterParams.filterMode = 'thisTrialOnly';
                filterParams.trialNum = currentTrialNum;
                filteredSpikeRecord = filterSpikeRecords(filterParams,spikeRecord);
                %% quality metrices
                quality = getQualityForSpikeRecord(filteredSpikeRecord);
                temp = stochasticLoad(neuralRecordLocation,{'samplingRate'});
                quality.samplingRate = temp.samplingRate
                %% worthPhysAnalysis?
                trialClass = getClassForTrial(stimRecordLocation); 
                evalStr = sprintf('sm = %s();',trialClass);
                eval(evalStr);
                analysisExists = false;
                overwriteAll = true;
                isLastChunkInTrial = (currentChunkInd==max(chunksAvailable));
                doAnalysis = worthPhysAnalysis(sm,quality,analysisExists,overWriteAll,isLastChunkInTrial);
                %% call to physAnalysis
                if doAnalysis
                    physAnalysisParameters=getNeuralRecordParameters(neuralRecordLocation,stimRecordLocation,subjectID,...
                            currentTrialNum,currentChunkInd,timestamp,filteredSpikeRecord,spikeDetectionParams);
                    eyeData=getEyeRecords(eyeRecordPath, currentTrial,timestamp);
                    % create the necessary figures
                    
                    for trodeNum = 1:length(trodes)
                        trodeStr = createTrodeName(trodes{trodeNum});
                        currTrode = trodes{trodeNum};
                        currSpikes = filteredSpikeRecord.(trodeStr).spikes;
                        currSpikeWaveforms = filteredSpikeRecord.(trodeStr).spikeWaveforms;
                        currSpikeTimestamps = filteredSpikeRecord.(trodeStr).spikeTimestamps;
                        if modelExists
                            currSpikeSortingParams.method = 'klustaModel';
                        else
                            currSpikeSortingParams = spikeSortingParams.(trodeStr);
                        end
                        currentSpikeRecord = sortSpikesForTrode(currentSpikeRecord,currTrode,trodeNum,...
                            currSpikes, currSpikeWaveforms,currSpikeTimestamps, currSpikeSortingParams, spikeModel);
                    end
                    [analysisdata cumulativedata] = physAnalysis(sm,filteredSpikeRecord,...
                        stimRecord.stimulusDetails,plotParameters,neuralRecord.parameters,cumulativedata,eyeData,LFPRecord);
                end
                %%
                %% now logic for switching status of analyze
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
if ~exist('updateParams','var') || isempty(updateParams) || ~isfield(updateParams,'analysisMode') || isempty(updateParams.analysisMode)
    error('make sure updateParams exists and analysisMode is specified');
end
switch updateParams.analysisMode
    case 'overwriteAll'
        detectSpikes = true;
    otherwise
        error('unknown updateMode');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sortSpikes = updateSortSpikesStatus(updateParams)
if ~exist('updateParams','var') || isempty(updateParams) || ~isfield(updateParams,'analysisMode') || isempty(updateParams.analysisMode)
    error('make sure updateParams exists and analysisMode is specified');
end
switch updateParams.analysisMode
    case 'overwriteAll'
        sortSpikes = true;
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
neuralRecord = getDetailsFromNeuralRecords(neuralRecordLocation,{chunkStr});
neuralRecord.samplingRate = getDetailsFromNeuralRecords(neuralRecordLocation,{'samplingRate'});
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
currentSpikeRecord.(trodeStr).processedClusters = spikeDetails.processedClusters';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spikeRecord =  getFrameDetails(neuralRecord,pulseInd,frameThresholds,ifi,trialNum,chunkInd)
[spikeRecord.frameIndices spikeRecord.frameTimes spikeRecord.frameLengths spikeRecord.correctedFrameIndices...
    spikeRecord.correctedFrameTimes spikeRecord.correctedFrameLengths spikeRecord.stimInds spikeRecord.passedQualityTest] = ...
    getFrameTimes(neuralRecord.neuralData(:,pulseInd),neuralRecord.neuralDataTimes,neuralRecord.samplingRate,...
    frameThresholds.dropBound, frameThresholds.warningBound, frameThresholds.errorBound,ifi, frameThresholds.dropsAcceptableFirstNFrames);
% get the integral below the photoDiode
spikeRecord.photoDiode = getPhotoDiode(neuralRecord.neuralData(:,photoInd),spikeRecord.correctedFrameIndices);


spikeRecord.chunkIDForCorrectedFrames=ones(length(spikeRecord.stimInds),1)*chunkInd;
spikeRecord.chunkIDForFrames=ones(size(spikeRecord.frameIndices,1),1)*chunkInd;
spikeRecord.trialNumForCorrectedFrames=ones(length(spikeRecord.stimInds),1)*trialNum;
spikeRecord.trialNumForFrames=ones(size(spikeRecord.frameIndices,1),1)*trialNum;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function quality = getQualityForSpikeRecord(spikeRecord);
quality.passedQualityTest=spikeRecord.passedQualityTest;
quality.chunkHasFrames=spikeRecord.chunkHasFrames;
quality.frameIndices=spikeRecord.frameIndices;
quality.frameTimes=spikeRecord.frameTimes;
quality.frameLengths=spikeRecord.frameLengths;
quality.correctedFrameIndices=spikeRecord.correctedFrameIndices;
quality.correctedFrameTimes=spikeRecord.correctedFrameTimes;
quality.correctedFrameLengths=spikeRecord.correctedFrameLengths;
quality.chunkIDForCorrectedFrames=spikeRecord.chunkIDForCorrectedFrames;
quality.chunkIDForFrames=spikeRecord.chunkIDForFrames;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parameters=getNeuralRecordParameters(neuralRecordLocation,stimRecordLocation,subjectID,...
                            currentTrialNum,currentChunkInd,timestamp,filteredSpikeRecord,spikeDetectionParams)
out=stochasticLoad(neuralRecordLocation,{'parameters'});
if isfield(out,'parameters')
    parameters=out.parameters;
else
    p=[];
    temp = stochasticLoad(neuralRecordLocation,{'samplingRate'});
    p.samplingRate=temp.samplingRate;
    p.subjectID=subjectID;
end
%Add some more activeParameters about the trial
p.trialNumber=currentTrialNum;
p.chunkID=currentChunkInd;
p.date=datenumFor30(timestamp);

%% now make parameters by trode (from filteredSpikeRecord)
trodesInRecord = fieldnames(filteredSpikeRecord);
trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
for currTrode = trodesInRecord'
    parameters.(currTrode{:}) = p;
    if isfield(spikeDetectionParams.(currTrode{:}),'ISIviolationMS')
        parameters.(currTrode{:}).ISIviolationMS = spikeDetectionParams.(currTrode{:}).ISIviolationMS;
    else
        parameters.(currTrode{:}).ISIviolationMS = 2;
    end
    temp = stochasticLoad(stimRecordLocation,{'refreshRate'});
    parameters.(currTrode{:}).refreshRate = temp.refreshRate;
end
end                  
