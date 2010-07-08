function  filteredSpikeRecord = filterSpikeRecords(filterParams,spikeRecord)
if ~exist('filterParams','var') || isempty(filterParams)
    error('filterParams is necessary for filtering spikeRecords');
end

if ~isfield(filterParams,'ignoreLengthsOfSortingInfo')
    filterParams.ignoreLengthsOfSortingInfo = false;
end

% these are the usual fields in spikeRecord. unless their indices exist,
% the data itself is not going to exist.
% % define the usual fields in spikeRecord
% fieldsWithinTrodeSizeOfSpikes = {'spikes','spikeWaveforms','spikeTimestamps','assignedClusters','processedClusters'...
%                'chunkIDForSpikes','trialNumForSpikes'}; % indexed by chunkIDForSpikes and trialNumForSpikes
% specialFieldsWithinTrodes = {'assignedClusters','processedClusters'}; may not always be sizeOfSpikes
% fieldsSizeOfFrames = {'frameIndices','frameLengths','frameTimes'}; % indexed by trialNumForFrames and chunkIDForFrames
% fieldsSizeOfCorrectedFrames = {'correctedFrameIndices','correctedFrameLengths','correctedFrameTimes',...
%     'photoDiode','stimInds'}; % indexed by trialNumForCorrectedFrames and chunkIDForCorrectedFrames
% fieldsSizeOfNumChunks = {'passedQualityTest','chunkHasFrames'}; %indexed by trialNum and chunkInd

% startFiltering
filteredSpikeRecord = [];

switch filterParams.filterMode
    case {'thisTrialAndChunkOnly','thisTrialOnly'}
        % which?
        %% for these cases the structure of the filtered spike record is maintained
        switch filterParams.filterMode
            case 'thisTrialAndChunkOnly'
                thisTrial = filterParams.trialNum;
                thisChunk = filterParams.chunkID;
                
                % fields size of numChunks
                filterForFieldsSizeNumChunks.exists = false;
                if isfield(spikeRecord,'trialNum')
                    filterForFieldsSizeNumChunks.exists = true;
                    filterForFieldsSizeNumChunks.which = (spikeRecord.trialNum==thisTrial) & (spikeRecord.chunkID==thisChunk);
                end
                
                % fields size of frames
                filterForFieldsSizeFrames.exists = false;
                if isfield(spikeRecord,'trialNumForFrames')
                    filterForFieldsSizeFrames.exists = true;
                    filterForFieldsSizeFrames.which = (spikeRecord.trialNumForFrames==thisTrial) & (spikeRecord.chunkIDForFrames==thisChunk);
                end
                
                % fields size of correctedFrames
                filterForFieldsSizeCorrectedFrames.exists = false;
                if isfield(spikeRecord,'trialNumForCorrectedFrames')
                    filterForFieldsSizeCorrectedFrames.exists = true;
                    filterForFieldsSizeCorrectedFrames.which = (spikeRecord.trialNumForCorrectedFrames==thisTrial) & (spikeRecord.chunkIDForCorrectedFrames==thisChunk);
                end
                
                %fields size of detectedSpikes
                filterForFieldsSizeDetectedSpikes=[];
                trodesInRecord = fieldnames(spikeRecord);
                trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
                filterForFieldsSizeDetectedSpikes.exists = false;
                for currTrode = trodesInRecord'
                    if isfield(spikeRecord.(currTrode{:}),'trialNumForDetectedSpikes')
                        filterForFieldsSizeDetectedSpikes.exists = true;
                        filterForFieldsSizeDetectedSpikes.(currTrode{:}).which = (spikeRecord.(currTrode{:}).trialNumForDetectedSpikes==thisTrial) & (spikeRecord.(currTrode{:}).chunkIDForDetectedSpikes==thisChunk);
                    end
                end
                
                %fields size of SortedSpikes
                filterForFieldsSizeSortedSpikes=[];
                trodesInRecord = fieldnames(spikeRecord);
                trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
                filterForFieldsSizeSortedSpikes.exists = false;
                for currTrode = trodesInRecord'
                    if isfield(spikeRecord.(currTrode{:}),'trialNumForSortedSpikes')
                        filterForFieldsSizeSortedSpikes.exists = true;
                        filterForFieldsSizeSortedSpikes.(currTrode{:}).which = (spikeRecord.(currTrode{:}).trialNumForSortedSpikes==thisTrial) & (spikeRecord.(currTrode{:}).chunkIDForSortedSpikes==thisChunk);
                    end
                end
                
            case 'thisTrialOnly'
                thisTrial = filterParams.trialNum;
                
                % fields size of numChunks
                filterForFieldsSizeNumChunks.exists = false;
                if isfield(spikeRecord,'trialNum')
                    filterForFieldsSizeNumChunks.exists = true;
                    filterForFieldsSizeNumChunks.which = (spikeRecord.trialNum==thisTrial);
                end
                
                % fields size of frames
                filterForFieldsSizeFrames.exists = false;
                if isfield(spikeRecord,'trialNumForFrames')
                    filterForFieldsSizeFrames.exists = true;
                    filterForFieldsSizeFrames.which = (spikeRecord.trialNumForFrames==thisTrial);
                end
                
                % fields size of correctedFrames
                filterForFieldsSizeCorrectedFrames.exists = false;
                if isfield(spikeRecord,'trialNumForCorrectedFrames')
                    filterForFieldsSizeCorrectedFrames.exists = true;
                    filterForFieldsSizeCorrectedFrames.which = (spikeRecord.trialNumForCorrectedFrames==thisTrial);
                end
                
                %fields size of detectedSpikes
                filterForFieldsSizeDetectedSpikes=[];
                trodesInRecord = fieldnames(spikeRecord);
                trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
                filterForFieldsSizeDetectedSpikes.exists = false;
                for currTrode = trodesInRecord'
                    if isfield(spikeRecord.(currTrode{:}),'trialNumForDetectedSpikes')
                        filterForFieldsSizeDetectedSpikes.exists = true;
                        filterForFieldsSizeDetectedSpikes.(currTrode{:}).which = (spikeRecord.(currTrode{:}).trialNumForDetectedSpikes==thisTrial);
                    end
                end
                
                %fields size of SortedSpikes
                filterForFieldsSizeSortedSpikes=[];
                trodesInRecord = fieldnames(spikeRecord);
                trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
                filterForFieldsSizeSortedSpikes.exists = false;
                for currTrode = trodesInRecord'
                    if isfield(spikeRecord.(currTrode{:}),'trialNumForSortedSpikes')
                        filterForFieldsSizeSortedSpikes.exists = true;
                        filterForFieldsSizeSortedSpikes.(currTrode{:}).which = (spikeRecord.(currTrode{:}).trialNumForSortedSpikes==thisTrial);
                    end
                end
                
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % this parts does the filtering while maintaining the structure of
        % spikeRecords
        if filterForFieldsSizeNumChunks.exists
            fieldsSizeOfNumChunks = {'passedQualityTest','chunkHasFrames','trialNum','chunkID'}; %indexed by trialNum and chunkInd
            which = filterForFieldsSizeNumChunks.which;
            for currentField = fieldsSizeOfNumChunks
                if isfield(spikeRecord,currentField{:})
                    temp = spikeRecord.(currentField{:});
                    filteredSpikeRecord.(currentField{:}) = temp(which,:);
                end
            end
        end
        
        if filterForFieldsSizeFrames.exists
            fieldsSizeOfFrames = {'frameIndices','frameLengths','frameTimes','trialNumForFrames','chunkIDForFrames'}; % indexed by trialNumForFrames and chunkIDForFrames
            which = filterForFieldsSizeFrames.which;
            for currentField = fieldsSizeOfFrames
                if isfield(spikeRecord,currentField{:})
                    temp = spikeRecord.(currentField{:});
                    filteredSpikeRecord.(currentField{:}) = temp(which,:);
                end
            end
        end
        
        if filterForFieldsSizeCorrectedFrames.exists
            fieldsSizeOfCorrectedFrames = {'correctedFrameIndices','correctedFrameLengths','correctedFrameTimes',...
                'photoDiode','stimInds','trialNumForCorrectedFrames','chunkIDForCorrectedFrames'}; % indexed by trialNumForCorrectedFrames and chunkIDForCorrectedFrames
            which = filterForFieldsSizeCorrectedFrames.which;
            for currentField = fieldsSizeOfCorrectedFrames
                if isfield(spikeRecord,currentField{:})
                    temp = spikeRecord.(currentField{:});
                    filteredSpikeRecord.(currentField{:}) = temp(which,:);
                end
            end
        end
        
        if filterForFieldsSizeDetectedSpikes.exists
            fieldsWithinTrodeSizeOfDetectedSpikes = {'spikes','spikeWaveforms','spikeTimestamps',...
                'chunkIDForDetectedSpikes','trialNumForDetectedSpikes'}; % indexed by chunkIDForSpikes and trialNumForSpikes
            trodesInFilter = fieldnames(filterForFieldsSizeDetectedSpikes);
            trodesInFilter = trodesInFilter(~cellfun(@isempty,regexp(trodesInFilter,'^trode')));
            for currentTrode = trodesInFilter'
                which = filterForFieldsSizeDetectedSpikes.(currentTrode{:}).which;
                for currentField = fieldsWithinTrodeSizeOfDetectedSpikes
                    if isfield(spikeRecord.(currentTrode{:}),currentField{:})
                        temp = spikeRecord.(currentTrode{:}).(currentField{:});
                        filteredSpikeRecord.(currentTrode{:}).(currentField{:}) = temp(which,:);
                    end
                end
            end
        end
        
        if filterForFieldsSizeSortedSpikes.exists
            fieldsWithinTrodeSizeOfSortedSpikes = {'assignedClusters','processedClusters'...
                'chunkIDForSortedSpikes','trialNumForSortedSpikes'}; % indexed by chunkIDForSpikes and trialNumForSpikes
            trodesInFilter = fieldnames(filterForFieldsSizeSortedSpikes);
            trodesInFilter = trodesInFilter(~cellfun(@isempty,regexp(trodesInFilter,'^trode')));
            for currentTrode = trodesInFilter'
                which = filterForFieldsSizeSortedSpikes.(currentTrode{:}).which;
                for currentField = fieldsWithinTrodeSizeOfSortedSpikes
                    if isfield(spikeRecord.(currentTrode{:}),currentField{:})
                        temp = spikeRecord.(currentTrode{:}).(currentField{:});
                        filteredSpikeRecord.(currentTrode{:}).(currentField{:}) = temp(which,:);
                    end
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %% do not maintain the structure of field names
    case 'onlyThisTrodeAndFlatten'
        trodeStr = filterParams.trodeStr;
        % get all the fields outside the trodes and put them in filteredSpikeRecord
        nonTrodeFields = fieldnames(spikeRecord);
        nonTrodeFields = nonTrodeFields(cellfun(@isempty,regexp(nonTrodeFields,'^trode')));
        for currField = nonTrodeFields'
            filteredSpikeRecord.(currField{:}) = spikeRecord.(currField{:});
        end
        fieldsInRelevantTrode = fieldnames(spikeRecord.(trodeStr));
        for currFieldInTrode = fieldsInRelevantTrode'
            filteredSpikeRecord.(currFieldInTrode{:}) = spikeRecord.(trodeStr).(currFieldInTrode{:});
        end
        %% otherwise
    otherwise
        filterParams.filterMode
        error('unsupported filterMode');
end




end