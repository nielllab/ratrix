function saveNidaqChunk(fullFilename,neuralData,neuralDataTimes,chunkCount,elapsedTime,samplingRate,ai_parameters)

match=regexpi(fullFilename,'.*\.mat','match');
if isempty(match)
    fullFilename=sprintf('%s.mat',fullFilename);
end

dur=neuralDataTimes(end)-neuralDataTimes(1);
fprintf('saving chunk %d of duration %4.2f to %s\n',chunkCount,dur,fullFilename)

evalStr=sprintf('chunk%d.neuralData = neuralData; chunk%d.neuralDataTimes = neuralDataTimes; chunk%d.elapsedTime=elapsedTime; chunk%d.samplingRate=samplingRate; chunk%d.ai_parameters=ai_parameters;',chunkCount,chunkCount,chunkCount,chunkCount,chunkCount);
eval(evalStr);

tic
if exist(fullFilename,'file')
    evalStr=sprintf('save %s chunk%d -append', fullFilename, chunkCount);
else
    evalStr=sprintf('save %s chunk%d', fullFilename, chunkCount);
end
eval(evalStr);
saveDur=toc;
disp(sprintf('that save took %4.2f sec',saveDur))
end % end function