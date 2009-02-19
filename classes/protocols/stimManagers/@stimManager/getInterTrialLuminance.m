%this needs to have access class 'protected' (subclasses need to use it,
%but others should not be allowed to access it).  but have to upgrade to
%matlab's new OOP architecture to get protected members.
function i=getInterTrialLuminance(s)
    i=s.interTrialLuminance;