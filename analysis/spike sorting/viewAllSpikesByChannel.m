function  viewAllSpikesByChannel(subjectID, path, cellBoundary, spikeDetectionParams, spikeSortingParams)

if ~exist('plottingParams','var') || isempty(plottingParams)
    plottingParams.showSpikeAnalysis = true;
    plottingParams.showLFPAnalysis = true;
    plottingParams.plotSortingForTesting = true;
end
if ~isfield(spikeSortingParams,'plotSortingForTesting')
    if isfield(plottingParams,'plotSortingForTesting')
        spikeSortingParams.plotSortingForTesting = plottingParams.plotSortingForTesting;
    else
        spikeSortingParams.plotSortingForTesting = true;
    end
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
        otherwise
            error('bad type of cellBoundary!');
    end
    if boundaryRange(1) ~= boundaryRande(2)
        error('support only for single trials');
    end
elseif iscell(cellBoundary) && length(cellBoundary)==4
    error('masking not supported');    
else
    error('bad cellBoundary input');
end

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

chansRequired = [1:14]; % hard coded here.
currentTrialNum = boundaryRange(1);

% look for currentTrial's neuralRecord
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
    neuralRecordLocation = fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-%s.mat',currentTrialNum,timestamp));
elseif length(d)>1
    error('duplicates present');
else
    error('didnt find anything in d');
end

% load the neural data
load(neuralRecordLocation);

%DETERMINE CHUNKS TO PROCESS
chunksToProcess = who('chunk*');
[matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
for i = 1:length(tokens)
    chunkNums(i) = tokens{i}{1};
end
[chunksOrdered orderOfChunks] = sort(chunkNums);
chunksToProcess = chunksToProcess(orderOfChunks);
% make temporary analysis folder and locate the neuralRecordLocation
analysisPathForTrial = fullfile(path,subjectID,'analysis','tempAnalysisFolder',num2str(currentTrialNum));
% spikeRecord.mat will contain info about all the channels for that trial.
spikeRecordLocation=fullfile(path,subjectID,'analysis','tempAnalysisFolder',num2str(currentTrialNum),'spikeRecords.mat');
% first delete folder if it exists
if exist(analysisPath,'dir')
    [succ,msg,msgID] = rmdir(analysisPathForTrial,'s');  % includes all subdirectory regardless of permissions
    if ~succ
        msg
        error('failed to remove existing files when running with ''overwriteAll=true''')
    end
end
% now make it again
if ~isdir(analysisPathForTrial)
    mkdir(analysisPathForTrial);
end

for currentChunkInd=1:size(chunksToProcess,1)
        try
            % =================================================================================
            chunkStr=sprintf('chunk%d',chunksToProcess(currentChunkInd));
            fprintf('*********DOING %s*************\n',chunkStr)
            
            % load the chunk
            neuralRecord=stochasticLoad(neuralRecordLocation,{chunkStr,'samplingRate'});
            temp=neuralRecord.samplingRate;
            neuralRecord=neuralRecord.(chunkStr);
            neuralRecord.samplingRate=temp;
            neuralRecord.neuralDataTimes=linspace(neuralRecord.neuralDataTimes(1),neuralRecord.neuralDataTimes(end),size(neuralRecord.neuralData,1))';
            if ~isfield(neuralRecord,'ai_parameters')
                neuralRecord.ai_parameters.channelConfiguration={'framePulse','photodiode','phys1'};
                if size(neuralRecord.neuralData,2)~=3
                    error('only expect old unlabeled data with 3 channels total... check assumptions')
                end
            end
            
            
            thisPhysChannelLabel=['phys' num2str(currChannel)];
            thisPhysChannelInd=find(ismember(neuralRecord.ai_parameters.channelConfiguration,thisPhysChannelLabel));
            
            photoInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'photodiode'));
            pulseInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'framePulse'));
            allPhysInds = find(~cellfun(@isempty, strfind(neuralRecord.ai_parameters.channelConfiguration,'phys')));
            
            spikeRecord.spikeDetails=[];
            spikeRecord.samplingRate=neuralRecord.samplingRate;
            spikeDetectionParams.samplingFreq=neuralRecord.samplingRate; % always overwrite with current value
            
            % business happens here
            [spikeRecord.spikes spikeRecord.spikeWaveforms spikeRecord.spikeTimestamps spikeRecord.assignedClusters ...
                spikeRecord.rankedClusters]=...
                getSpikesFromNeuralData(neuralRecord.neuralData(:,thisPhysChannelInd),neuralRecord.neuralDataTimes,...
                spikeDetectionParams,spikeSortingParams,analysisPath);
            spikeRecord.chunkID=ones(length(spikeRecord.spikes),1)*chunksToProcess(currentChunkInd);
            spikeRecord.chunkIDForDetails=chunksToProcess(currentChunkInd);
            spikeRecord.trialNum=ones(length(spikeRecord.spikes),1)*currentTrialNum;
            spikeRecord.trialNumForDetails=currentTrialNum;
            
            if exist(spikeRecordLocation,'file')
                prev=stochasticLoad(spikeRecordLocation);
                
                try
                    % 6/3/09 - offset each chunk's stimInds by the last stimInd from previous chunk (moved 2/2/10)
                    %maybe it should be after the ~proccessed || overwriteAll else
                    which=find(prev.trialNumForCorrectedFrames==currentTrial);
                    if ~isempty(which)
                        startingStimIndAdjustment=max(prev.stimInds(which));
                        startingSampleIndAdjustment=prev.correctedFrameIndices(which(end))+numPaddedSamples;
                    else
                        startingStimIndAdjustment=0;
                        startingSampleIndAdjustment=0;
                    end
                catch ex
                    warning('a prob here')
                    keyboard
                    rethrow(ex)
                end
                if prev.correctedFrameIndices(end)~=prev.frameIndices(end)
                    corrected=prev.correctedFrameIndices(end)
                    raw=prev.frameIndices(end)
                    error('the end frame was assumed to be the same... will this mess things up?')
                end
            else
                prev.spikes=[];
                prev.spikeWaveforms=[];
                prev.spikeTimestamps=[];
                prev.assignedClusters=[];
                prev.spikeDetails=[];
                prev.frameIndices=[];
                prev.frameTimes=[];
                prev.frameLengths=[];
                prev.correctedFrameIndices=[];
                prev.correctedFrameTimes=[];
                prev.correctedFrameLengths=[];
                prev.stimInds=[];
                prev.photoDiode=[];
                prev.passedQualityTest=[];
                prev.samplingRate=[];
                prev.chunkID=[];
                prev.chunkIDForFrames=[];
                prev.chunkIDForCorrectedFrames=[];
                prev.chunkIDForDetails=[];
                prev.trialNum=[];
                prev.trialNumForFrames=[];
                prev.trialNumForCorrectedFrames=[];
                prev.trialNumForDetails=[];
                prev.LFPRecord.data = [];
                prev.LFPRecord.dataTimes = [];
                prev.LFPRecord.LFPSamplingRateHz = [];
                startingStimIndAdjustment=0;
                startingSampleIndAdjustment=0;
                
            end
            % now append! (and take acount chunk counters like startingStimIndAdjustment startingSampleIndAdjustment)
            
            spikes=[prev.spikes;spikeRecord.spikes                                                  + startingSampleIndAdjustment];
            spikeWaveforms=[prev.spikeWaveforms;spikeRecord.spikeWaveforms];
            spikeTimestamps=[prev.spikeTimestamps;spikeRecord.spikeTimestamps];
            assignedClusters=[prev.assignedClusters;spikeRecord.assignedClusters];
            spikeDetails=[prev.spikeDetails;spikeRecord.spikeDetails];
            frameIndices=[prev.frameIndices;spikeRecord.frameIndices                                + startingSampleIndAdjustment];
            frameTimes=[prev.frameTimes;spikeRecord.frameTimes];
            frameLengths=[prev.frameLengths;spikeRecord.frameLengths];
            correctedFrameIndices=[prev.correctedFrameIndices;spikeRecord.correctedFrameIndices     + startingSampleIndAdjustment];
            correctedFrameTimes=[prev.correctedFrameTimes;spikeRecord.correctedFrameTimes];
            correctedFrameLengths=[prev.correctedFrameLengths;spikeRecord.correctedFrameLengths];
            stimInds=[prev.stimInds;spikeRecord.stimInds                                            + startingStimIndAdjustment];
            photoDiode=[prev.photoDiode;spikeRecord.photoDiode];
            passedQualityTest=[prev.passedQualityTest;spikeRecord.passedQualityTest];
            samplingRate=[prev.samplingRate;spikeRecord.samplingRate];
            chunkID=[prev.chunkID;spikeRecord.chunkID];
            chunkIDForFrames=[prev.chunkIDForFrames;spikeRecord.chunkIDForFrames];
            chunkIDForCorrectedFrames=[prev.chunkIDForCorrectedFrames;spikeRecord.chunkIDForCorrectedFrames];
            chunkIDForDetails=[prev.chunkIDForDetails;spikeRecord.chunkIDForDetails];
            trialNum=[prev.trialNum;spikeRecord.trialNum];
            trialNumForFrames=[prev.trialNumForFrames;spikeRecord.trialNumForFrames];
            trialNumForCorrectedFrames=[prev.trialNumForCorrectedFrames;spikeRecord.trialNumForCorrectedFrames];
            trialNumForDetails=[prev.trialNumForDetails;spikeRecord.trialNumForDetails];
            LFPRecord.data = [prev.LFPRecord.data; spikeRecord.LFPRecord.data];
            LFPRecord.dataTimes = [prev.LFPRecord.dataTimes; spikeRecord.LFPRecord.dataTimes];
            LFPRecord.LFPSamplingRateHz= [prev.LFPRecord.LFPSamplingRateHz;spikeRecord.LFPSamplingRateHz];
            
            
            
        catch ex
            disp(['CAUGHT EX: ' getReport(ex)])
            %             break
            % 11/25/08 - restart dir loop if tried to load corrupt file
            rethrow(ex)
            error('failed to load from file');
        end
    end
    
    
    
end