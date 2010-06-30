function spikeRecords = getSpikeRecords(analysisPath)
spikeRecordFile = fullfile(analysisPath,'cumulativeSpikeRecord.mat')
if exist(spikeRecordFile,'file')
    temp = stochasticLoad(analysisPath,'spikeRecords');
    spikeRecords = temp.cumulativeSpikeRecords;
else
    spikeRecords = [];
end
end
