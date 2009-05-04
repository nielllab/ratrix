function [delayMs timeoutMs] = getDelayAndTimeout(hzd)
% calculate the delay and possible timeout from a uniform hazard function
% returns delay and timeout in milliseconds (ms)
% delay refers to the delay until a stimulus is shown
% timeout, if nonempty, means that no stimulus will be shown for this trial and we will go to the next trial after timeoutMs
% this should only be if we hit latestStimTime w/o triggering a stim and forceShow is off..

% HACK for now return a random uniform between earliest and latest (dont know how to do hazrad function)
timeoutMs=[];
delayMs=hzd.earliestStimTime + rand(1)*(hzd.latestStimTime - hzd.earliestStimTime);

end