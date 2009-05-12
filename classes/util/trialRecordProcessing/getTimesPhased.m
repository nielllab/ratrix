function out=getTimesPhased(phaseRecord)
out=[];
for i=1:length(phaseRecord)
    out=[out cell2mat(phaseRecord(i).responseDetails.times)+phaseRecord(i).responseDetails.startTime];
end
if isempty(out)
    out={NaN};
end
end