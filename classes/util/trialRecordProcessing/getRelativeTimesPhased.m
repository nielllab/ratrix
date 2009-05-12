function out=getRelativeTimesPhased(phaseRecord)
out=[];
for i=1:length(phaseRecord)
    out=[out cell2mat(phaseRecord(i).responseDetails.times)];
end
if isempty(out)
    out={NaN};
end
end