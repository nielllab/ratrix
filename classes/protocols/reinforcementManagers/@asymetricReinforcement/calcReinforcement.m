function [r rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = ...
    calcReinforcement(r,trialRecords, subject)


%confirm trial redords contains THIS trial (not merely the trials before this trial)

sm=trialRecords(emd).stimManager
details=trialRecords(emd).stimDetails;
targetIsPresent=checkTargetIsPresent(sm,details);

if targetIsPresent==1
    rewardSizeULorMS=getScalar(r) * r.hitRewardSizeULorMS;
        msPenalty=r.falseAlarmMsPenalty;
elseif targetIsPresent==0;
        rewardSizeULorMS=getScalar(r) * r.correctRejectRewardSizeULorMS;
        msPenalty=r.missMsPenalty;
else  %(ie. any negative value)
    class(sm)
    targetIsPresent
    error('this reinforcement manager requires the stim manager to report that the target is present or absent')
end

rewardSizeULorMS= getScalar(r) * base;

requestRewardSizeULorMS = getScalar(r) * getRequestRewardSizeULorMS(r);
msPuff=getMsPuff(r);
msRewardSound=rewardSizeULorMS*r.fractionOpenTimeSoundIsOn;
msPenaltySound=msPenalty*r.fractionPenaltySoundIsOn;

updateRM=0;