function cumulativeSpikeRecords = updateCumulativeSpikeRecords(currentSpikeRecord,cumulativeSpikeRecords,currentTrialNum,currentChunkInd,analysisPath)
cumulativeFieldNames = intelligentFieldnames(cumulativeSpikeRecords);
currentFieldNames = intelligentFieldnames(currentSpikeRecord);
for fieldNum = 1:length(currentFieldNames)
    thisFieldName = currentFieldNames{fieldNum};
end    
end