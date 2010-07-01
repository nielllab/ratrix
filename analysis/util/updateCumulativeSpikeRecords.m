function cumulativeSpikeRecords = updateCumulativeSpikeRecords(updateParams,currentSpikeRecord,cumulativeSpikeRecords)
% This function is going to assume that the over all "shape" of
% currentSpikeRecord and cumulativeSpikeRecord will not undergo substantial
% change. All currentSpikeRecords will have the following structure
% currentSpikeRecords.
% ********************* trode specific *********************
%                    (troden).  n=1,2,3,....
%                             trodeChans *
%                             LFPRecord.
%                                       LFPData
%                                       LFPDataTimes
%                             spikes
%                             spikeTimestamps
%                             spikeWaveforms
%                             trialNum
%                             chunkID
%                             assignedClusters
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
    case 'detectSpikes'
        trodesInCurrent = fieldnames(currentSpikeRecord);
        trodesInCurrent = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
        for currentTrode = trodesInCurrent % loop through all the trode fields
            trodeInfo = currentSpikeRecord.(currentTrode{:});
            if ~isfield(cumulativeSpikeRecords,currentTrode{:}) % the analysis was never run for the trode 
                cumulativeSpikeRecords.(currentTrode{:}) = currentSpikeRecord.(currentTrode{:});
            else % prev analysis exists. check if the trodeChans are identical
                if(cumulativeSpikeRecords.(currentTrode{:}).trodeChans ~= ...
                        currentSpikeRecord.(currentTrode{:}).trodeChans)
                    cumulativeSpikeRecords.(currentTrode{:}).trodeChans
                    currentSpikeRecord.(currentTrode{:}).trodeChans
                    error('attempting to update analyses for different trodes.');
                end
                nonUpdatedFields = {'trodeChans'};
                specialFields = {'LFPRecord'};
                fieldsToBeUpdated = fieldnames(currentSpikeRecord.(currentTrode{:}));
                fieldsToBeUpdated = fieldsToBeUpdated(~ismember(fieldsToBeUpdated,{nonUpdatedFields{:},specialFields{:}}));
                % support for most fields which are spike num dependent
                for currentUpdateField = fieldsToBeUpdated
                    if ~exist(cumulativeSpikeRecords.(currentTrode{:}).(currentUpdateField{:}))
                        cumulativeSpikeRecords.(currentTrode{:}).(currentUpdateField{:}) = ...
                            currentSpikeRecord.(currentTrode{:}).(currentUpdateField{:});
                    else
                        cumulativeSpikeRecords.(currentTrode{:}).(currentUpdateField{:}) = [...
                            cumulativeSpikeRecords.(currentTrode{:}).(currentUpdateField{:});...
                            currentSpikeRecord.(currentTrode{:}).(currentUpdateField{:})];
                    end
                end
                % support for LFPRecord
                if isfield(currentSpikeRecord.(currentTrode{:}),'LFPRecord')
                    if ~isfield(cumulativeSpikeRecords.(currentTrode{:}),'LFPRecord')
                        cumulativeSpikeRecords.(currentTrode{:}).LFPRecord = ...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord;
                    else
                        cumulativeSpikeRecords.(currentTrode{:}).LFPRecord.LFPData = ...
                            [cumulativeSpikeRecords.(currentTrode{:}).LFPRecord.LFPData;...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord.LFPData];
                        cumulativeSpikeRecords.(currentTrode{:}).LFPRecord.LFPDataTimes = ...
                            [cumulativeSpikeRecords.(currentTrode{:}).LFPRecord.LFPDataTimes;...
                            currentSpikeRecord.(currentTrode{:}).LFPRecord.LFPDataTimes]
                    end
                end
            end
        end
    case 'sortSpikes'
        
    case 'frameAnalysis'
        
    otherwise
        error('unknown updateMode');
end
end