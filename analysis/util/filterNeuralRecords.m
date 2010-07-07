function neuralRecord = filterNeuralRecords(neuralRecord,timeRangePerTrialSecs)
% avoid making big variables to filter the data if you can...
if timeRangePerTrialSecs(1)==0 & timeRangePerTrialSecs(2)> diff(neuralRecord.neuralDataTimes([1 end]))% use all
    % do nothing, b/c using all
else %filter
    timeSinceTrialStart=neuralRecord.neuralDataTimes-neuralRecord.neuralDataTimes(1);
    withinTimeRange=timeSinceTrialStart>=timeRangePerTrialSecs(1) & timeSinceTrialStart<=timeRangePerTrialSecs(2);
    neuralRecord.neuralData=neuralRecord.neuralData(withinTimeRange,:);
    neuralRecord.neuralDataTimes=neuralRecord.neuralDataTimes(withinTimeRange);
end

end