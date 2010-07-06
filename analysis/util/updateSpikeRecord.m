function spikeRecords = updateSpikeRecord(updateParams,currentSpikeRecord,spikeRecords)
% All spikeRecords will have the following structure
%       spikeRecords.
% ********************* trode specific *********************
%                    (trodeStr).  n=1,2,3,....
%                               trodeChans *
%                               LFPRecord.
%                                         LFPData
%                                         LFPDataTimes
%                               spikes
%                               spikeTimestamps
%                               spikeWaveforms
%                               trialNum
%                               chunkInd
%                               assignedClusters
%                               spikeModel.
%                                          featureDetails
%                                          clusteringMethod
%                                          clusteringModel
% ********************* frame specific *********************
%                    frameIndices
%                    frameTimes
%                    correctedFrameIndices
%                    correctedFrameLengths
%                    correctedFrameTimes
%                    trialNumForFrames
%                    trialNumForCorrectedFrames
%                    chunkIDForFrames
%                    chunkIDForCorrectedFrames
%                    photoDiode
%                    stimInds
%                    chunkIDForDetails
% ************************* others *************************
%                    passedQualityTest
%                    spikeDetails
%                    trialNumForDetails
% one or more of the above may be present or absent at any point during the
% update and exactly what is updated depends on updateMode

if ~exist('updateParams','var')||isempty(updateParams)
    error('need updateParams');
end

if ~exist('currentSpikeRecord','var')||isempty(currentSpikeRecord)
    error('need currentSpikeRecord');
end

if ~exist('cumulativeSpikeRecords','var')||isempty(cumulativeSpikeRecords)
    error('need cumulativeSpikeRecords');
end

switch updateParams.updateMode
    case 'physSpikes'
        trodesInCurrent = fieldnames(currentSpikeRecord);
        trodesInCurrent = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
        for currentTrode = trodesInCurrent % loop through all the trode fields
            trodeInfo = currentSpikeRecord.(currentTrode{:});
            if ~isfield(spikeRecords,currentTrode{:}) % the analysis was never run for the trode 
                spikeRecords.(currentTrode{:}) = currentSpikeRecord.(currentTrode{:});
            else % prev analysis exists. check if the trodeChans are identical
                if(spikeRecords.(currentTrode{:}).trodeChans ~= ...
                        currentSpikeRecord.(currentTrode{:}).trodeChans)
                    spikeRecords.(currentTrode{:}).trodeChans
                    currentSpikeRecord.(currentTrode{:}).trodeChans
                    error('attempting to update analyses for different trodes.');
                end
                nonUpdatedFields = {'trodeChans'};
                specialFields = {'LFPRecord'};
                fieldsToBeUpdated = fieldnames(currentSpikeRecord.(currentTrode{:}));
                fieldsToBeUpdated = fieldsToBeUpdated(~ismember(fieldsToBeUpdated,{nonUpdatedFields{:},specialFields{:}}));
                % support for most fields which are spike num dependent
                for currentUpdateField = fieldsToBeUpdated
                    if ~exist(spikeRecords.(currentTrode{:}).(currentUpdateField{:}))
                        spikeRecords.(currentTrode{:}).(currentUpdateField{:}) = ...
                            currentSpikeRecord.(currentTrode{:}).(currentUpdateField{:});
                    else
                        spikeRecords.(currentTrode{:}).(currentUpdateField{:}) = [...
                            spikeRecords.(currentTrode{:}).(currentUpdateField{:});...
                            currentSpikeRecord.(currentTrode{:}).(currentUpdateField{:})];
                    end
                end
                % support for LFPRecord
                if isfield(currentSpikeRecord.(currentTrode{:}),'LFPRecord')
                    if ~isfield(spikeRecords.(currentTrode{:}),'LFPRecord')
                        spikeRecords.(currentTrode{:}).LFPRecord = ...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord;
                    else
                        spikeRecords.(currentTrode{:}).LFPRecord.LFPData = ...
                            [spikeRecords.(currentTrode{:}).LFPRecord.LFPData;...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord.LFPData];
                        spikeRecords.(currentTrode{:}).LFPRecord.LFPDataTimes = ...
                            [spikeRecords.(currentTrode{:}).LFPRecord.LFPDataTimes;...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord.LFPDataTimes]
                    end
                end
            end
        end
    case 'photoDiodeSpikes'
        
    case 'sortSpikes'
        
    case 'frameAnalysis'
        
    otherwise
        error('unknown updateMode');
end
end