function spikeRecords = getSpikeRecords(analysisPath)
spikeRecordFile = fullfile(analysisPath,'cumulativeSpikeRecord.mat')
if exist(spikeRecordFile,'file')
    temp = stochasticLoad(spikeRecordFile,'cumulativeSpikeRecord');
    spikeRecords = temp.cumulativeSpikeRecords;
else
    spikeRecords = [];
end
end
