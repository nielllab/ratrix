%this works when normfit doesn't -- normfit assumes you sampled from the whole distribution
%here we allow you to have sampled some range of the support which may not have even included the mean
function out=gaussMeanFit(data,range)
data(2,:)=data(2,:)-min(data(2,:));

if false
    model=fittype('normpdf(x,mu,sigma)'); %actually this is wrong cuz we miss amplitude
    if ~all(cellfun(@strcmp,coeffnames(model),{'mu','sigma'}'))
        coeffnames(model)
        error('coeff name error')
    end
    
    lower=[range(1) 0];
    upper=[range(2) Inf]; %consider limiting variance?  doesn't matter that we fit it well...
    options=fitoptions(model);
    options=fitoptions(options,'Lower',lower,'Upper',upper);
    
    ind = 1;
else
    % for 'gaussN', N is the number of peaks to fit, 1-8
    % a is the amplitude, b is the centroid (location), c is related to the peak width.
    model=fittype('gauss1');
    
    if ~all(cellfun(@strcmp,coeffnames(model),{'a1','b1','c1'}'))
        coeffnames(model)
        error('coeff name error')
    end
    
    options=fitoptions(model);
    %options=fitoptions('gauss1');
    
    options.Lower=[0 range(1) 0]; %doc suggests gaussN models don't know c >= 0, but fitoptions('gauss1') seems to set it ?
    options.Upper=[Inf range(2) Inf]; 
    %options.Upper=[1 range(2) 1]; %don't need accurate amp or width -- without this it sometimes just puts the mean in the middle of the range -- but with it it doesn't work at all?
    ind = 2;
end

cfun = fit(data(1,:)',data(2,:)',model,options);

vals=coeffvalues(cfun);
mu=vals(ind);

ci=confint(cfun);
if diff(ci(:,ind)) > diff(range)
    %warning('bad fit')
    mu=nan;
end

out=[mu vals(1)]';
end