function  filteredSpikeRecord = filterSpikeRecords(filterParams,spikeRecords)
if ~exist('filterParams','var') || isempty(filterParams)
    error('filterParams is necessary for filtering spikeRecords');
end
% these are the usual fields in spikeRecord. unless their indices exist,
% the data itself is not going to exist.
% % define the usual fields in spikeRecord
% fieldsWithinTrodeSizeOfSpikes = {'spikes','spikeWaveforms','spikeTimestamps','assignedClusters',...
%     'processedClusters'}; % indexed by chunkID and trialNum
% fieldsSizeOfFrames = {'frameIndices','frameLengths','frameTimes'}; % indexed by trialNumForFrames and chunkIDForFrames
% fieldsSizeOfCorrectedFrames = {'correctedFrameIndices','correctedFrameLengths','correctedFrameTimes',...
%     'photoDiode','stimInds'}; % indexed by trialNumForCorrectedFrames and chunkIDForCorrectedFrames
% fieldsSizeOfNumChunks = {'passedQualityTest','chunkHasFrames'}; %indexed by trialNum and chunkInd

% which?
switch filterParams.filterMode
    case 'thisTrialAndChunkOnly'
        thisTrial = filterParams.trialNum;
        thisChunk = filterParams.chunkID;
        
        % fields size of numChunks
        filterForFieldsSizeNumChunks.exists = false;
        if isfield(spikeRecords,'trialNum')
            filterForFieldsSizeNumChunks.exists = true;
            filterForFieldsSizeNumChunks.which = (spikeRecord.trialNum==thisTrial) & (spikeRecord.chunkID==thisChunk);
        end
        
        % fields size of frames
        filterForFieldsSizeFrames.exists = false;
        if isfield(spikeRecords,'trialNumForFrames')
            filterForFieldsSizeFrames.exists = true;
            filterForFieldsSizeFrames.which = (spikeRecord.trialNumForFrames==thisTrial) & (spikeRecord.chunkIDForFrames==thisChunk);
        end
        
        % fields size of correctedFrames
        filterForFieldsSizeCorrectedFrames.exists = false;
        if isfield(spikeRecords,'trialNumForCorrectedFrames')
            filterForFieldsSizeCorrectedFrames.exists = true;
            filterForFieldsSizeCorrectedFrames.which = (spikeRecord.trialNumForCorrectedFrames==thisTrial) & (spikeRecord.chunkIDForCorrectedFrames==thisChunk);
        end
        
        %fields size of spikes
        filterForFieldsSizeSpikes=[];
        trodesInRecord = fieldnames(spikeRecords);
        trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
        for currTrode = trodesInRecord'
            if isfield(spikeRecord.(currTrode{:}),'trialNum')
                filterForFieldsSizeSpikes.(currTrode{:}).which = (spikeRecord.(currTrode{:}).trialNum==thisTrial) & (spikeRecord.(currTrode{:}).chunkID==thisChunk);
            end
        end
        
    case 'thisTrialOnly'
        thisTrial = filterParams.trialNum;
        
        % fields size of numChunks
        filterForFieldsSizeNumChunks.exists = false;
        if isfield(spikeRecords,'trialNum')
            filterForFieldsSizeNumChunks.exists = true;
            filterForFieldsSizeNumChunks.which = (spikeRecord.trialNum==thisTrial);
        end
        
        % fields size of frames
        filterForFieldsSizeFrames.exists = false;
        if isfield(spikeRecords,'trialNumForFrames')
            filterForFieldsSizeFrames.exists = true;
            filterForFieldsSizeFrames.which = (spikeRecord.trialNumForFrames==thisTrial);
        end
        
        % fields size of correctedFrames
        filterForFieldsSizeCorrectedFrames.exists = false;
        if isfield(spikeRecords,'trialNumForCorrectedFrames')
            filterForFieldsSizeCorrectedFrames.exists = true;
            filterForFieldsSizeCorrectedFrames.which = (spikeRecord.trialNumForCorrectedFrames==thisTrial);
        end
        
        %fields size of spikes
        filterForFieldsSizeSpikes.exist=false;
        trodesInRecord = fieldnames(spikeRecords);
        trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
        for currTrode = trodesInRecord'
            if isfield(spikeRecord.(currTrode{:}),'trialNum')
                filterForFieldsSizeSpikes.exist=true;
                filterForFieldsSizeSpikes.(currTrode{:}).which = (spikeRecord.(currTrode{:}).trialNum==thisTrial);
            end
        end
    otherwise
        filterParams.filterMode
        error('unsupported filterMode');
end

% startFiltering
filteredSpikeRecord = [];

if filterForFieldsSizeNumChunks.exist
    fieldsSizeOfNumChunks = {'passedQualityTest','chunkHasFrames','trialNum','chunkID'}; %indexed by trialNum and chunkInd
    which = filterForFieldsSizeNumChunks.which;
    for currentField = fieldsSizeOfNumChunks
        if isfield(spikeRecord,currentField{:})
            temp = spikeRecord.(currentField{:});
            filteredSpikeRecord.(currentField{:}) = temp(which,:);
        end
    end
end

if filterForFieldsSizeFrames.exist
    fieldsSizeOfFrames = {'frameIndices','frameLengths','frameTimes','trialNumForFrames','chunkIDForFrames'}; % indexed by trialNumForFrames and chunkIDForFrames
    which = filterForFieldsSizeFrames.which;
    for currentField = fieldsSizeOfNumChunks
        if isfield(spikeRecord,currentField{:})
            temp = spikeRecord.(currentField{:});
            filteredSpikeRecord.(currentField{:}) = temp(which,:);
        end
    end
end

if filterForFieldsSizeCorrectedFrames.exist
    fieldsSizeOfCorrectedFrames = {'correctedFrameIndices','correctedFrameLengths','correctedFrameTimes',...
    'photoDiode','stimInds','trialNumForCorrectedFrames','chunkIDForCorrectedFrames'}; % indexed by trialNumForCorrectedFrames and chunkIDForCorrectedFrames
    which = filterForFieldsSizeNumChunks.which;
    for currentField = fieldsSizeOfNumChunks
        if isfield(spikeRecord,currentField{:})
            temp = spikeRecord.(currentField{:});
            filteredSpikeRecord.(currentField{:}) = temp(which,:);
        end
    end
end

if filterForFieldsSizeSpikes.exist
    fieldsWithinTrodeSizeOfSpikes = {'spikes','spikeWaveforms','spikeTimestamps','assignedClusters',...
    'processedClusters'}; % indexed by chunkID and trialNum    
    trodesInFilter = fieldnames(filterForFieldsSizeSpikes);
    trodesInFilter = trodesInFilter(~cellfun(@isempty,regexp(trodesInFilter,'^trode')));
    for currentTrode = trodesInFilter'
        which = filterForFieldsSizeSpikes.(currentTrode{:}).which;
        for currentField = fieldsWithinTrodeSizeOfSpikes
            if isfield(spikeRecord.(currentTrode{:}),currentField{:})
                temp = spikeRecord.(currentTrode{:}).(currentField{:});
                filteredSpikeRecord.(currentTrode{:}).(currentField{:}) = temp(which,:);
            end
        end
    end
end

end