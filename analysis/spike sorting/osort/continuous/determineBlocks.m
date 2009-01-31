%
%determines the blocksize and how many of those are to be processed, based on the raw number of samples available in
%the file
%
%
function [nrRuns, blocksize] = determineBlocks( totNrSamples )

blocksize=512000;
nrRuns = fix( totNrSamples/ blocksize ) + 1;


