function [out]=getDiscrimPhaseStart(phaseRecord)
out=[];
for i=1:length(phaseRecord)
    if strcmp(phaseRecord(i).phaseLabel,'discrim')
      out=[out phaseRecord(i).responseDetails.startTime];
    end
end
if isempty(out)
    out={NaN};
end
end