%
%reads the raw data from a neuralynx CSC file.
%
%urut/april04
function [timestamps,dataSamples] = getRawCSCData( filename, fromInd, toInd )
FieldSelection(1) = 1;%timestamps
FieldSelection(2) = 0;
FieldSelection(3) = 0;%sample freq
FieldSelection(4) = 0;
FieldSelection(5) = 1;%samples
ExtractHeader = 0;
ExtractMode = 2;
ModeArray(1)=fromInd;
ModeArray(2)=toInd;

[timestamps, dataSamples] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode,ModeArray);

%flatten
dataSamples=dataSamples(:);

