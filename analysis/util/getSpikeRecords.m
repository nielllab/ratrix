function spikeRecord = getSpikeRecords(analysisPath,analysisMode)
spikeRecordFile = fullfile(analysisPath,'spikeRecord.mat')
switch analysisMode
    case 'overwriteAll'
        if exist(spikeRecordFile,'file')
            temp = stochasticLoad(spikeRecordFile,{'spikeRecord'});
            spikeRecord = temp.spikeRecord;
        else
            spikeRecord = [];
        end
    otherwise
        error('unsupported analysisMode');
end
end
