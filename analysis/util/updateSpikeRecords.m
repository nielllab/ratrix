function spikeRecord = updateSpikeRecords(updateParams,currentSpikeRecord,spikeRecord)
% All spikeRecord will have the following structure
%       spikeRecord.
% ********************* trode specific *********************
%                    (trodeStr).  n=1,2,3,....
%                               trodeChans *
%                               LFPRecord.
%                                         LFPData
%                                         LFPDataTimes
%                               spikes **
%                               spikeTimestamps
%                               spikeWaveforms
%                               trialNum
%                               chunkInd
%                               assignedClusters
%                               processedClusters
%                               spikeModel.
%                                          featureDetails
%                                          clusteringMethod
%                                          clusteringModel
% ********************* frame specific *********************
%                    frameIndices **
%                    frameTimes
%                    correctedFrameIndices **
%                    correctedFrameLengths
%                    correctedFrameTimes
%                    trialNumForFrames
%                    trialNumForCorrectedFrames
%                    chunkIDForFrames
%                    chunkIDForCorrectedFrames
%                    photoDiode
%                    stimInds ***
%                    chunkIDForDetails
% ************************* others *************************
%                    passedQualityTest
%                    chunkHasFrames
%                    trialNum
%                    chunkID
%                    sampleIndAdjustment
%                    stimIndAdjustment
% one or more of the above may be present or absent at any point during the
% update and exactly what is updated depends on updateMode

if ~exist('updateParams','var')||isempty(updateParams)
    error('need updateParams');
end

if ~exist('currentSpikeRecord','var')||isempty(currentSpikeRecord)
    error('need currentSpikeRecord');
end

if ~exist('spikeRecord','var')
    error('need spikeRecord');
end

switch updateParams.updateMode
    case 'frameAnalysis'
        fieldsToUpdateWithoutAdj = {'frameTimes','frameLengths','correctedFrameTimes','correctedFrameLengths',...
            'passedQualityTest','chunkIDForCorrectedFrames','chunkIDForFrames','trialNumForCorrectedFrames',...
            'trialNumForFrames','chunkHasFrames','trialNum','chunkID','photoDiode'};
        fieldsToUpdateWithSampAdj = {'frameIndices','correctedFrameIndices'};
        fieldsToUpdateWithStimAdj = {'stimInds'};
        fieldsToUpdateOther = {'sampleIndAdjustment','stimIndAdjustment'};
        
        % when to reset sampleIndAdjustment & stimIndAdjustment??? for a
        % new trial or when no cumulative records exist
        if isempty(spikeRecord) || ... % when just initiating analysis
                (isstruct(spikeRecord) && (~isfield(spikeRecord,'trialNumForFrames'))) || ... % maybe analyzeFrames is not called first
                ~any(unique(spikeRecord.trialNumForFrames)==unique(currentSpikeRecord.trialNumForFrames)) %% if this trial was never analyzed before
            spikeRecord.sampleIndAdjustment = 0;
            spikeRecord.stimIndAdjustment = 0;
        elseif isfield(spikeRecord,'trialNumForFrames') && ...
                any(unique(spikeRecord.trialNumForFrames)==unique(currentSpikeRecord.trialNumForFrames))
            currentTrial = unique(currentSpikeRecord.trialNumForFrames);
            numPaddedSamples = 2; %% ENSURE THAT THIS IS IDENTICAL TO numPaddedSamples IN createSnippetFromNeuralRecords
            which = find(spikeRecord.trialNumForCorrectedFrames==currentTrial);
            spikeRecord.stimIndAdjustment=max(spikeRecord.stimInds(which));
            spikeRecord.sampleIndAdjustment=spikeRecord.correctedFrameIndices(which(end))+numPaddedSamples;
        end
        for currField = fieldsToUpdateWithoutAdj
            if ~isfield(spikeRecord,currField{:})
                spikeRecord.(currField{:}) = [];
            end
            spikeRecord.(currField{:}) = [spikeRecord.(currField{:});currentSpikeRecord.(currField{:})];
        end
        for currField = fieldsToUpdateWithSampAdj
            if ~isfield(spikeRecord,currField{:})
                spikeRecord.(currField{:}) = [];
            end
            adjustedValues = currentSpikeRecord.(currField{:}) + spikeRecord.sampleIndAdjustment;
            spikeRecord.(currField{:}) = [spikeRecord.(currField{:}); adjustedValues];
        end
        for currField = fieldsToUpdateWithStimAdj
            if ~isfield(spikeRecord,currField{:})
                spikeRecord.(currField{:}) = [];
            end
            adjustedValues = currentSpikeRecord.(currField{:}) + spikeRecord.stimIndAdjustment;
            spikeRecord.(currField{:}) = [spikeRecord.(currField{:}); adjustedValues];
        end       
        
    case 'physSpikes'
        trodesInCurrent = fieldnames(currentSpikeRecord);
        trodesInCurrent = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
        for currentTrode = trodesInCurrent' % loop through all the trode fields
            trodeInfo = currentSpikeRecord.(currentTrode{:});
            if ~isfield(spikeRecord,currentTrode{:}) % the analysis was never run for the trode 
                spikeRecord.(currentTrode{:}) = currentSpikeRecord.(currentTrode{:});
            else % prev analysis exists. check if the trodeChans are identical
                if(spikeRecord.(currentTrode{:}).trodeChans ~= ...
                        currentSpikeRecord.(currentTrode{:}).trodeChans)
                    spikeRecord.(currentTrode{:}).trodeChans
                    currentSpikeRecord.(currentTrode{:}).trodeChans
                    error('attempting to update analyses for different trodes.');
                end
                nonUpdatedFields = {'trodeChans'};
                specialFields = {'LFPRecord','spikes'};
                fieldsToBeUpdated = {'spikes','spikeWaveforms','spikeTimestamps','chunkIDForDetectedSpikes','trialNumForDetectedSpikes'};
                fieldsToBeUpdated = fieldsToBeUpdated(~ismember(fieldsToBeUpdated,{nonUpdatedFields{:},specialFields{:}}));
                % support for most fields which are spike num dependent
                for currentUpdateField = fieldsToBeUpdated
                    if ~isfield(spikeRecord.(currentTrode{:}),currentUpdateField{:})
                        spikeRecord.(currentTrode{:}).(currentUpdateField{:}) = ...
                            currentSpikeRecord.(currentTrode{:}).(currentUpdateField{:});
                    else
                        spikeRecord.(currentTrode{:}).(currentUpdateField{:}) = [...
                            spikeRecord.(currentTrode{:}).(currentUpdateField{:});...
                            currentSpikeRecord.(currentTrode{:}).(currentUpdateField{:})];
                    end
                end
                % support for LFPRecord
                if isfield(currentSpikeRecord.(currentTrode{:}),'LFPRecord')
                    if ~isfield(spikeRecord.(currentTrode{:}),'LFPRecord')
                        spikeRecord.(currentTrode{:}).LFPRecord = ...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord;
                    else
                        spikeRecord.(currentTrode{:}).LFPRecord.LFPData = ...
                            [spikeRecord.(currentTrode{:}).LFPRecord.LFPData;...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord.LFPData];
                        spikeRecord.(currentTrode{:}).LFPRecord.LFPDataTimes = ...
                            [spikeRecord.(currentTrode{:}).LFPRecord.LFPDataTimes;...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord.LFPDataTimes]
                    end
                end
                % support for 'spikes'
                if isfield(currentSpikeRecord.(currentTrode{:}),'spikes')
                    if ~isfield(spikeRecord.(currentTrode{:}),'spikes')
                        spikeRecord.(currentTrode{:}).spikes = [];
                    end
                    adjustedValues = currentSpikeRecord.(currentTrode{:}).spikes + spikeRecord.sampleIndAdjustment;
                    spikeRecord.(currentTrode{:}).spikes = [spikeRecord.(currentTrode{:}).spikes ; adjustedValues];                    
                end
                
                % support for 'trodeChans'
                if isfield(currentSpikeRecord.(currentTrode{:}),'trodeChans')
                    if ~isfield(spikeRecord.(currentTrode{:}),'trodeChans')
                        spikeRecord.(currentTrode{:}).trodeChans = currentSpikeRecord.(currentTrode{:}).trodeChans;
                    end
                end                
            end
        end        
    case 'photoDiodeSpikes'
        fieldsToUpdate = {};
        error('photoDiodeSpikes not yet supported');
        
    case 'sortSpikes'
        if updateParams.updateSpikeModel
            fieldsToUpdate = {'assignedClusters','rankedClusters','processedClusters',...
                'trialNumForSortedSpikes','chunkIDForSortedSpikes','spikeModel'};
        else
            fieldsToUpdate = {'assignedClusters','rankedClusters','processedClusters',...
                'trialNumForSortedSpikes','chunkIDForSortedSpikes'};
        end
        trodesInCurrent = fieldnames(currentSpikeRecord);
        trodesInCurrent = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
        for currentTrode = trodesInCurrent'
            for currentField = fieldsToUpdate
                if ~isfield(spikeRecord.(currentTrode{:}),currentField{:})
                    spikeRecord.(currentTrode{:}).(currentField{:}) = [];
                end
                spikeRecord.(currentTrode{:}).(currentField{:}) = ...
                    [spikeRecord.(currentTrode{:}).(currentField{:}); ...
                    currentSpikeRecord.(currentTrode{:}).(currentField{:})];
            end
        end
    otherwise
        error('unknown updateMode');
end
end