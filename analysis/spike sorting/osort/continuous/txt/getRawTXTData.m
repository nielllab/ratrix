%
%read data from txt file
%
%urut/april07
function	[timestamps,dataSamples] = getRawTXTData( filename, fromInd, toInd )

%fid=fopen(filename);

%TODO -- this inefficient. only read part of file that is really needed.

D=dlmread(filename);
dataSamples=D(fromInd:toInd,2);

timestamps=D(fromInd:toInd,1);

%convert to uS
Fs=24000;
timestamps = timestamps .* (1e6/Fs);
 
dataSamples=dataSamples(:);
timestamps=timestamps(:);