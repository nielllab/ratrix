function out=findClosestInds(samps,set)
if isvector(samps) && isvector(set)
    if size(samps,1)~=1
        samps=samps';
    end
    if size(set,1)~=1
        set=set';
    end
    diffs=abs(repmat(samps',1,length(set))-repmat(set,length(samps),1));
    [garbage order]=sort(diffs,2,'ascend');
    out=order(:,1);
else
    samps
    set
    error('samps and sets must both be vectors')
end