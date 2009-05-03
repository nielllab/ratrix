function [delay timeout]=constantDelay()
% this function needs to return a delay time
% and also a timeout time
% delayFunction class: hazard(rate, earliestStimTime, latestStimTime, forceshowAtLastChance)
% 
%     defaults: earliestStimTime=0, latestStimTime=infinity, forceshowAtLastChance=F;
%     forceshow_at_last_chance is logical, if true then when latesttime arrives or phase timelimit reached etc
%     show the stimulus; otherwise trial ends with no stimulus shown, trial is neither Correct nor Incorrect 
delay=60;%frames
timeout=300;%frames
end