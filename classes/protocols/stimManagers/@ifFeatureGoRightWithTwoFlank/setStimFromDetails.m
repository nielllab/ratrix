function s=setStimFromDetails(s,details)

%first set the defaults
p=getDefaultParameters(s);
s=getStimManager(setFlankerStimRewardAndTrialManager(p));

% then overwrite all the fields that we have in .sm
f=fields(details.sm);
for i = 1:length(f)
  s.(f{i})=details.sm.(f{i});
end


