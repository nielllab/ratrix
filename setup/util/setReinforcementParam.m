function setReinforcementParam(param,ids,val,stepNum,comment,auth)

if ~exist('auth','var')
    auth='unspecified'; %bad idea?
end

if ~exist('comment','var')
    comment='';
end

if ~exist('stepNum','var') || isempty(stepNum)
    stepNum='all';
end

r=init;
subs=getSubjectsFromIDs(r,ids);
for i=1:length(subs)
    [s r]=setReinforcementParam(subs(i),param,val,stepNum,r,comment,auth);
end