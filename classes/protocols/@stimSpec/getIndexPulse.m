function out=getIndexPulse(s,i)
if exist('i','var') && ~isempty(i)
    out=s.indexPulses(i);
else
    out=s.indexPulses;
end