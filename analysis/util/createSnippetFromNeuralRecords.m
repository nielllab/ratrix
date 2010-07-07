function [snippet snippetTimes neuralRecord chunkHasFrames] = createSnippetFromNeuralRecords(spikeRecord,neuralRecord,currentChunkInd,chunksAvailable,currentTrialNum)
if ~isempty(spikeRecord.correctedFrameIndices)
    numPaddedSamples=2; % in each dirrection % ENSURE THAT THIS IS IDENTICAL TO numPaddedSamples IN updateSpikeRecords
    lastSampleKept=spikeRecord.correctedFrameIndices(end); % these are still relative to the chenk, and so can index neural data
    snippet=neuralRecord.neuralData(lastSampleKept-numPaddedSamples-1:end,:); %same the snippet after the last frame
    snippetTimes=neuralRecord.neuralDataTimes(lastSampleKept-numPaddedSamples-1:end,:);
    neuralRecord.neuralData=neuralRecord.neuralData(1:lastSampleKept,:); %remove snippet after the late frame
    neuralRecord.neuralDataTimes=neuralRecord.neuralDataTimes(1:lastSampleKept,:); %remove snippet after the late frame
    chunkHasFrames = true;
else
    %if no frames found
    %probably the last chunk, in which case go to the next trial,
    %but if not the last chunk error
    if currentChunkInd==max(chunksAvailable)
        warning(sprintf('no frames found on the last chunk (%d) of trial %d...skipping to next trial',currentChunkInd,currentTrialNum));
        chunkHasFrames = false;
%         warning('this stuff errors, going to next trial')
%         break % chunksToProcess loop
%         %option to do analysis in this odd location, that happens sometimes
%         doAnalysis=worthPhysAnalysis(sm,quality,analysisExists,overwriteAll,isLastChunkInTrial); %doAnalysis = isLastChunkInTrial;
%         if doAnalysis
%             filteredSpikeRecord=getCurrentTrialSpikeRecords(currentTrial,trialNum,trialNumForCorrectedFrames,trialNumForDetails,...
%                 spikes,spikeTimestamps,spikeWaveforms,assignedClusters,chunkID,correctedFrameIndices,correctedFrameTimes,...
%                 stimInds,chunkIDForCorrectedFrames,photoDiode,spikeDetails,chunkIDForDetails,chunksToProcess,currentChunkInd);
%             eyeData=getEyeRecords(eyeRecordPath, currentTrial,timestamp);
%             
%             %DON't LIKE HAVING THIS REDUNDANTCODE HERE .. but here it is
%             neuralRecord.parameters=getNeuralRecordParameters(neuralRecord,neuralRecordLocation,subjectID);
%             %Add some more activeParameters about the trial
%             neuralRecord.parameters.trialNumber=currentTrial;
%             neuralRecord.parameters.chunkID=chunksToProcess(currentChunkInd,2);
%             neuralRecord.parameters.date=datenumFor30(timestamp);
%             neuralRecord.parameters.ISIviolationMS=spikeDetectionParams.ISIviolationMS;
%             neuralRecord.parameters.refreshRate=stimRecord.refreshRate; % where?
%             
%             [analysisdata cumulativedata] = physAnalysis(sm,filteredSpikeRecord,stimRecord.stimulusDetails,plotParameters,neuralRecord.parameters,cumulativedata,eyeData,LFPRecord);
%             drawnow
%         end
        
    else
        spikeRecord
        error(sprintf('no frames found on chunk %d which is not the last one! (trial %d has %d chunks)',currentChunkInd,currentTrialNum,max(chunksAvailable)))
    end
end