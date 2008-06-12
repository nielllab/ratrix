function [s] = setNewNumTrials(s)
%draw from the dsitribution of possibleNumTrials

index=min(find(rand<cumsum(s.probOfNumTrials)));
s.numTrials=s.possibleNumTrials(index);
%out=s.numTrials;


