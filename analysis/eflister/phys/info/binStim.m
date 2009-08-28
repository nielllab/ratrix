function [h binnedStim counts]=binStim(filteredStim,edges)

filteredStim(filteredStim>=max(edges))=(edges(end)+edges(end-1))/2;
filteredStim(filteredStim<=min(edges))=(edges(1)+edges(2))/2;

[nDims stimLength]=size(filteredStim);
binsPerDim=length(edges-1);

[h binnedStim]=histc(filteredStim',edges);

if min(binnedStim(:))<1 || max(binnedStim(:))>length(edges)-1
    error('bad histc output')
end

if nDims>1
    sz=binsPerDim*ones(1,nDims);
else
    sz=[binsPerDim 1];
end

h=accumarray(binnedStim,ones(1,stimLength),sz); %i forget why we need this and can't use the h from histc?

counts=h;

if 1 %normalize
    h=h/stimLength;

    tol=0.001;
    if abs(1-sum(h(:)))>tol
        sum(h(:))
        error('n-d pdist don''t sum to 1')
    end
end