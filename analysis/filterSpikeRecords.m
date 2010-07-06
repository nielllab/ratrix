function  filteredSpikeRecord = filterSpikeRecords(filterParams,spikeRecords)
if ~exist('filterParams','var') || isempty(filterParams)
    error('filterParams is necessary for filtering spikeRecords');
end
filteredSpikeRecord = [];
switch filterParams.filterMode
    case 'thisTrialAndChunkOnly'
        %% thisTrialAndChunkOnly
        trialNum = filterParams.trialNum;
        chunkInd = filterParams.chunkInd;
        trodesInRecord = fieldnames(spikeRecords);
        trodesInRecord = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
        for trodeNum = 1:length(trodesInRecord)
            currTrode = trodesInRecord{trodeNum};
            filteredSpikeRecord.(currTrode).trodeChans = spikeRecords.(currTrode).trodeChans;
            which = (spikeRecords.(currTrode).trialNum==trialNum) && (spikeRecords.(currTrode).chunkInd==chunkInd);
            filteredSpikeRecord.(currTrode).spikes = spikeRecords.(currTrode).spikes(which);
            filteredSpikeRecord.(currTrode).spikeTimestamps = spikeRecords.(currTrode).spikeTimestamps(which);
            filteredSpikeRecord.(currTrode).spikeWaveforms = spikeRecords.(currTrode).spikeWaveforms(which);
        end
        %% END
    otherwise
        %% otherwise
        filterParams.filterMode
        error('unsupported filterMode');
        %% end
end
            
end