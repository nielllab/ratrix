function out=findFreqs(data,numFreqs,range)
if isNearInteger(numFreqs) && isscalar(numFreqs) && isreal(numFreqs) && inRange(numFreqs,[1 8])
    
    % for 'gaussN', N is the number of peaks to fit, 1-8
    % a is the amplitude, b is the centroid (location), c is related to the peak width.
    
    model=fittype(sprintf('gauss%d',numFreqs));
    
    names={};
    lower=[];
    upper=[];
    for i=1:numFreqs
        names(end+1:end+3)=cellfun(@(x) sprintf('%s%d',x,i),{'a','b','c'},'UniformOutput',false);
        lower(end+1:end+3)=[0 range(1) 0]; %doc suggests gaussN models don't know c >= 0, but at least fitoptions('gauss1') seems to set it ?
        upper(end+1:end+3)=[Inf range(2) Inf];
    end
    
    if ~all(cellfun(@strcmp,coeffnames(model),names'))
        coeffnames(model)
        error('coeff name error')
    end
    
    options=fitoptions(model);
    
    options.Lower=lower;
    options.Upper=upper;
    
    cfun = fit(data(1,:)',data(2,:)',model,options);
    
    vals=coeffvalues(cfun);
    inds=2+(0:3:3*(numFreqs-1));
    
    out=sort(vals(inds));
    
    ci=confint(cfun);
    if any(diff(ci(:,inds)) > diff(range))
        error('bad fit')
    end
else
    error('numFreqs must be real scalar int 1-8')
end