function setStepNum(ids,stepNum,comment,auth)

if ~exist('auth','var')
    auth='unspecified'; %bad idea?
end

if ~exist('comment','var')
    comment='';
end

r=init;
subs=getSubjectsFromIDs(r,ids);
for i=1:length(subs)
    [s r]=setStepNum(subs{i},stepNum,r,comment,auth);
end