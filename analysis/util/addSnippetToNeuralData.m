function neuralRecord = addSnippetToNeuralData(neuralRecord,snippet,snippetTimes)
neuralRecord.preModifiedStartStopTimes=neuralRecord.neuralDataTimes([1 end]); %keep a record of start stop before the modifications
if ~isempty(snippet)
    %this is the data after the last flip (+ a few few sample indices for padding)
    %if we do not do this, analysis will "drop" (fail to find) a frame between chunks
    %the neural data is MOVED to the next chunk
    neuralRecord.neuralData=[snippet; neuralRecord.neuralData ];
    neuralRecord.neuralDataTimes=[snippetTimes; neuralRecord.neuralDataTimes];
end
end
