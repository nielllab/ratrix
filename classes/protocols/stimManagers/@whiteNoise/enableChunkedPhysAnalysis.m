function retval = enableChunkedPhysAnalysis(sm)
% returns true if physAnalysis knows how to deal with, and wants each chunk
% as it comes. 

retval=true; %white noise wants to run on EVERY CHUNK, as opposed to the end of the trial
% this helps for memory problems on really long trials... its also have the
% cumulative analysis is currently built to work

end % end function
