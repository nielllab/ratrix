function [stimOn stimDuration] = getRewardStimParams(s)

if any(strcmp(fieldnames(s), 'setRewardStimOn')) 
   stimOn =s.setRewardStimOn;
    stimDuration=s.rewardOnDuration;
else
    stimOn=0;
    stimDuration=0;
end