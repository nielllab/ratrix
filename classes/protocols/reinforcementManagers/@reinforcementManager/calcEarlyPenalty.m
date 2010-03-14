function [r rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateTM] = ...
    calcEarlyPenalty(r,trialRecords, subject)

%currently only cuedGoNoGo+asymetricReinforcement relies on this, but in principle other tm that punish early responses could use it
%... if that is the case consider factoring code out of
%cuedGoNoGo.updateTrialState and into trialmanager.updateTrialState

updateTM=0;

%this is an early penalty and so base and base request are forced to 0
base=0;
baseRequest=0;
[rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = calcCommonValues(r,base,baseRequest);



