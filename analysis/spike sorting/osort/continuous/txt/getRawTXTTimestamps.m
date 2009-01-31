%
%read txt file format
%
%for now this function is very inefficient - it reads the entire file to extract the timestamps.
%
%urut/april07
function	[timestamps,nrBlocks,nrSamples] = getRawTXTTimestamps( filename )

%fid=fopen(filename);
D=dlmread(filename);
timestamps=D(:,1);

%convert to uS
Fs=24000;
timestamps = timestamps .* (1e6/Fs);
 
nrBlocks=size(D,1)/512000;
nrSamples=size(D,1);
