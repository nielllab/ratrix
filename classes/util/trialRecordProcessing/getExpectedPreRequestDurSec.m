function [out]=getExpectedPreRequestDurSec(phaseRecord,resolution)
out=[];
for i=1:length(phaseRecord)
    if strcmp(phaseRecord(i).phaseLabel,'pre-request')
      out=phaseRecord(i).timeoutLengthInFrames/resolution.hz;
    end
end
if isempty(out)
    out=NaN;
end
end