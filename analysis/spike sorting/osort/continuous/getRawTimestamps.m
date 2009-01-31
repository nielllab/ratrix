%
%reads raw timestamps; calls the appropriate routine for the data format used.
%
%the fileFormat variable is defined in defineFileFormat.m (all possible values).
%
%urut/april07
function [timestamps,nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawTimestamps( filename, fileFormat )

%neuralynx
if fileFormat<=2
	[timestamps,nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawCSCTimestamps( filename );
end

%txt file
if fileFormat==3
	[timestamps,nrBlocks,nrSamples] = getRawTXTTimestamps( filename );
	
	%this file format doesnt support these variables.
	headerInfo=[];
	isContinous=1;
	sampleFreq=0;	
end
