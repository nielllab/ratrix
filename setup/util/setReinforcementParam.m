function r=setReinforcementParam(param,ids,val,stepNum,comment,auth)

r=getRatrix;
subs=getSubjectsFromIDs(r,ids);
for i=1:length(subs)
    [s r]=setReinforcementParam(subs{i},param,val,stepNum,r,comment,auth);
end