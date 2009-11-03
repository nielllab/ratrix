function retval = enableChunkedPhysAnalysis(sm)
% returns true if physAnalysis knows how to deal with, and wants each chunk
% as it comes.  true for getting each chunk, false for getting the
% combination of all chunks after analysisManagerByChunk has detected
% spikes, sorted them, and rebundled them as spikes in their chunked format

retval=false; %stim managers could sub class this method if they want to run on EVERY CHUNK, as opposed to the end of the trial

end % end function
