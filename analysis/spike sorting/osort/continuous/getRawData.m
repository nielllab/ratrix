%
%reads raw continous data 
%calls the appropriate routine for the data format used.
%
%the fileFormat variable is defined in defineFileFormat.m (all possible values).
%
%urut/april07
function [timestamps,dataSamples] = getRawData( filename, fromInd, toInd, fileFormat )

%neuralynx
if fileFormat<=2
    
    %neuralynx format is in blocks of 512, so divide
    fromInd=ceil(fromInd/512);
    toInd = toInd/512;
    
	[timestamps,dataSamples] = getRawCSCData( filename, fromInd, toInd );
end

%txt file
if fileFormat==3
	[timestamps,dataSamples] = getRawTXTData( filename, fromInd, toInd );
end
