function r=setReinforcementParam(param,ids,val,stepNum,comment,auth)

r=getRatrix;
if ~exist('ids','var') || isempty(ids)
    ids=getSubjectIDs(r);
elseif ~iscellstr(ids)
    error('ids must be cellstr')
end
subs=getSubjectsFromIDs(r,ids);

for i=1:length(subs)
    [s r]=setReinforcementParam(subs{i},param,val,stepNum,r,comment,auth);
end