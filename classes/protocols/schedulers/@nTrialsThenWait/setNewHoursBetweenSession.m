function [s] = setNewHoursBetweenSession(s)
%draw from the dsitribution of possibleNumTrials

index=min(find(rand<cumsum(s.probOfHoursBetweenSessions)));
s.hoursBetweenSessions=s.possibleHoursBetweenSessions(index);
%out=s.hoursBetweenSessions;


