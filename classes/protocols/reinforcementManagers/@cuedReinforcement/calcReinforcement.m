function [r rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = ...
    calcReinforcement(r,trialRecords, subject)
verbose=0;

reward = trialRecords(end).stimDetails.selectedTrialValue;

[rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = ...
    calcCommonValues(r,reward,getRequestRewardSizeULorMS(r));

updateRM=0;