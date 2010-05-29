function saveNidaqChunk(fullFilename,neuralData,neuralDataTimes,chunkCount,elapsedTime,samplingRate,ai_parameters)

match=regexpi(fullFilename,'.*\.mat','match');
if isempty(match)
    fullFilename=sprintf('%s.mat',fullFilename);
end

fprintf('saving chunk %d to %s\n',chunkCount,fullFilename)

evalStr=sprintf('chunk%d.neuralData = neuralData; chunk%d.neuralDataTimes = neuralDataTimes; chunk%d.elapsedTime=elapsedTime; chunk%d.samplingRate=samplingRate; chunk%d.ai_parameters=ai_parameters;',chunkCount,chunkCount,chunkCount,chunkCount,chunkCount);
eval(evalStr);

if exist(fullFilename,'file')
    evalStr=sprintf('save %s chunk%d -append', fullFilename, chunkCount);
else
    evalStr=sprintf('save %s chunk%d', fullFilename, chunkCount);
end
eval(evalStr);

end % end function