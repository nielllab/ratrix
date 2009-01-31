%
%get header, scale factor from there
%
%urut/may06
function [headerInfo, scaleFact, fileExists] = getRawHeader( filename )
scaleFact=0;
headerInfo='';
if exist(filename)==0
    fileExists=0;
    return;
end
fileExists=1;

isContinous=false;

FieldSelection(1) = 0;%timestamps
FieldSelection(2) = 0;
FieldSelection(3) = 0;%sample freq
FieldSelection(4) = 0;
FieldSelection(5) = 0;

ExtractHeader = 1;
ExtractMode = 1;

[headerInfo] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode);
tmp=headerInfo{15};
pos= strfind(tmp,'0.');
scaleFact = str2num( tmp(pos:end) );
