function [out]=getPhaseStarts(phaseRecord)
out=[];
for i=1:length(phaseRecord)
    out=[out phaseRecord(i).responseDetails.startTime];
end
if isempty(out)
    out={NaN};
end
end