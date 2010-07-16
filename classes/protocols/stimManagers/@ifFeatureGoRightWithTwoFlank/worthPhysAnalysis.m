function retval = worthPhysAnalysis(sm,quality,analysisExists,overwriteAll,isLastChunkInTrial)
% returns true if worth spike sorting given the values in the quality struct
% default method for all stims - can be overriden for specific stims
%
% quality.passedQualityTest (from analysisManager's getFrameTimes)
% quality.frameIndices
% quality.frameTimes
% quality.frameLengths (this was used by getFrameTimes to calculate passedQualityTest)

% retval=quality.passedQualityTest && isLastChunkInTrial;


if length(quality.passedQualityTest)>1
    %if many chunks, the last one might have no frames or spikes, but the
    %analysis should still complete if the the previous chunks are all
    %good. to be very thourough, a stim manager may wish to confirm that
    %the reason for last chunk failing, if it did, is an acceptable reason.
    qualityOK=all(quality.passedQualityTest(1:end-1));
else
    qualityOK=quality.passedQualityTest;
end

 warning('force quality true!!!')
 qualityOK=true;

retval=qualityOK && ...
    (isLastChunkInTrial || enableChunkedPhysAnalysis(sm)) &&...    
    (overwriteAll || ~analysisExists);


end % end function
