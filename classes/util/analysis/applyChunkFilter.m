function neuralRecord=applyChunkFilter(neuralRecord,currentTrialStartTime,cellTimes)
% neuralRecord has fields 'neuralData','neuralDataTimes','elapsedTime',and 'samplingRate'
% we only modify the neuralData and neuralDataTimes fields
% based on the start time of the current trial (and the elapsed time of this chunk's neuralRecord)
% INPUTS:
%   neuralRecord - the chunk to modify (contains neuralData, neuralDataTimes, elapsedTime, and samplingRate)
%   currentTrialStartTime - the start time of the current trial (in matlab system time 'now')
%   cellTimes - the start and end times of the cell we want (also in matlab system time 'now')
% OUTPUTS:
%   neuralRecord - modified to only fall within cellTimes

onesec=datenum([0 0 0 0 0 1]); % equiv to one second in datenum time
currentChunkStartTime=currentTrialStartTime+neuralRecord.elapsedTime;
currentChunkEndTime=currentChunkStartTime+(size(neuralRecord.neuralData,1)/neuralRecord.samplingRate)*onesec;

% prune from front
if cellTimes(1)>currentChunkStartTime
    timeDiff=cellTimes(1)-currentChunkStartTime; % diff in time based on datenum time
    % convert datenum time to neuralData sample inds
    sampleDiff=neuralRecord.samplingRate*(timeDiff/onesec); % number of samples
    neuralRecord.neuralData(1:sampleDiff)=[];
    neuralRecord.neuralDataTimes(1:sampleDiff)=[];
end

% prune from end
if cellTimes(2)<currentChunkEndTime
    timeDiff=currentChunkEndTime - cellTimes(2); % diff in time based on datenum time
    % convert datenum time to neuralData sample inds
    sampleDiff=neuralRecord.samplingRate*(timeDiff/onesec); % number of samples
    neuralRecord.neuralData(end-sampleDiff+1:end)=[];
    neuralRecord.neuralDataTimes(end-sampleDiff+1:end)=[];
end

end % end function

