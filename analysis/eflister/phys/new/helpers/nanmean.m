function out = nanmean (in)
if length(size(in))==2 && ~isvector(in) && ~any(size(in)==1)
    out=nan(1,size(in,2));
    for i=1:size(in,2)
        nanmap=~isnan(in(:,i));
        nonnans=sum(nanmap);
        if nonnans>0
            out(i)=sum(in(nanmap,i))/nonnans;
        end
    end
else
    error('arg must be matrix')
end