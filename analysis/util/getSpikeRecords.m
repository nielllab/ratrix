function spikeRecords = getSpikeRecords(analysisPath)
spikeRecordFile = fullfile(analysisPath,'spikeRecords.mat')
if exist(spikeRecordFile,'file')
    temp = stochasticLoad(spikeRecordFile,'spikeRecords');
    spikeRecords = temp.spikeRecords;
else
    spikeRecords = [];
end
end
