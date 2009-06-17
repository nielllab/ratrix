function retval = worthPhysAnalysis(sm,quality,analysisExists,overwriteAll)
% returns true if worth spike sorting given the values in the quality struct
% default method for all stims - can be overriden for specific stims
%
% quality.passedQualityTest (from analysisManager's getFrameTimes)
% quality.frameIndices
% quality.frameTimes
% quality.frameLengths (this was used by getFrameTimes to calculate passedQualityTest)

retval=~analysisExists; % so we dont repeat the same analysis for every chunk in this trial!

end % end function
