function  filteredSpikeRecord = filterSpikeRecords(filterParams,cumulativeSpikeRecords)
if ~exist('filterParams','var') || isempty(filterParams)
    error('filterParams is necessary for filtering spikeRecords');
end
filteredSpikeRecord = [];
switch filterParams.filterMode
    case 'thisTrialAndChunkOnly'
        trialNum = filterParams.trialNum;
        chunkInd = filterParams.chunkInd;
        trodesInRecord = fieldnames(cumulativeSpikeRecords);
        trodesInRecord = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
        for trodeNum = 1:length(trodesInRecord)
            currTrode = trodesInRecord{trodeNum};
            filteredSpikeRecord.(currTrode).trodeChans = cumulativeSpikeRecords.(currTrode).trodeChans;
            which = (cumulativeSpikeRecords.(currTrode).trialNum==trialNum);
            filteredSpikeRecord.(currTrode).spikes = cumulativeSpikeRecords.(currTrode).spikes(which);
            filteredSpikeRecord.(currTrode).spikeTimestamps = cumulativeSpikeRecords.(currTrode).spikeTimestamps(which);
            filteredSpikeRecord.(currTrode).spikeWaveforms = cumulativeSpikeRecords.(currTrode).spikeWaveforms(which);
        end
    otherwise
        error('unknown filterMode');
end
            
end