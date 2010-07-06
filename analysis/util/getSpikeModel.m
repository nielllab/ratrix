function [spikeModel modelExists] = getSpikeModel(spikeRecord,spikeSortingParams)
if ~exist('spikeRecord','var')||isempty(spikeRecord)
    error('spikeRecord not well defined')
end
if ~exist('spikeSortingParams','var')||isempty(spikeSortingParams)
    error('spikeSortingParams not well defined')
end

spikeModel = [];
modelExists = false;
% find the trodes in spikeRecord
trodesInRecord = fieldnames(spikeRecord);
trodesInRecord = trodesInCurrent(~cellfun(@isempty,regexp(trodesInCurrent,'^trode')));
for trodeNum = 1:length(trodesInRecord)
    if exist(spikeRecord.(trodesInRecord{trodeNum}).spikeModel)
        modelExists(trodeNum) = true;
        spikeModel.(trodesInRecord{trodeNum}) = cumulativeSpikeRecord.(trodesInRecord{trodeNum}).spikeModel;
    else
        modelExists(trodeNum) = false;
    end
end

if ~all(modelExists)
    spikeModel = [];
    modelExists = false;
    if strcmp(spikeSortingParams.method,'useSpikeModelFromPreviousAnalysis')
        boundaryRangeStr = sprintf('%d-%d',spikeSortingParams.boundaryRange(1),spikeSortingParams.boundaryRange(2));
        prevSpikeRecordPath = fullfile(spikeSortingParams.path,spikeSortingParams.subjectID,'analysis',boundaryRangeStr,'spikeRecord.mat')
        temp = stochasticLoad(prevSpikeRecordPath,'spikeRecord');
        prevSpikeRecord = temp.spikeRecord;
        % find all the field names with trode in them
        trodesInRecord = fieldnames(prevSpikeRecord);
        trodesInRecord = trodesInRecord(~cellfun(@isempty,regexp(trodesInRecord,'^trode')));
        for trodeNum = 1:length(trodesInRecord)
            if ~isfield(prevSpikeRecord.(trodesInRecord{trodeNum}),'spikeModel')
                spikeModel = [];
                return;
            else
                spikeModel.(trodesInRecord{trodeNum}) = prevSpikeRecord.(trodesInRecord{trodeNum}).spikeModel;
            end
        end
        modelExists = true;
    end
end     
% % analysisPath will have a file named spikeModel.mat
% spikeModelFile = fullfile(analysisPath,'spikeModel.mat');
% if exist(spikeModelFile,'file')
%     temp = stochasticLoad(spikeModelFile,'spikeModel');
%     spikeModel = temp.spikeModel;
%     modelExists = true;
% end
end
