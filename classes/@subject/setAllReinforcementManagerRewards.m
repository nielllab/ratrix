function [subject r]=setAllReinforcementManagerRewards(subject,val,r,comment,auth)

if isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))

    for i=1:getNumTrainingSteps(subject.protocol)
        ts=getTrainingStep(subject.protocol,i);
        tm=getTrialManager(ts);
        currentRm =getReinforcementManager(tm);
        if ismember('setRewardSizeULorMS',methods(currentRm))
            rm=setRewardSizeULorMS(currentRm,val);
            tm =setReinforcementManager(tm,rm);
            ts=setTrialManager(ts,tm);

            [subject r]=changeProtocolStep(subject,ts,r,comment,auth,i);
        else
            class(currentRm)
            warning('can''t setRewardSizeULorMS for that reinforcement manager class')
        end
    end

else
    error('need reinforcement manager and ratrix that contains this subject')
end