function [subject r]=changeAllReinforcementManagers(subject,rm,r,comment,auth)
error('edf 12.11.08: call setup/util/setReinforcementParam instead')   
% agreed... I don't rely on this function now, so we can delete it. Thx for
% writting the util -pmm 1.12.09

if isa(rm,'reinforcementManager') && isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))
          
            for i=1:getNumTrainingSteps(subject.protocol)
                    ts=getTrainingStep(subject.protocol,i);
                    tm=getTrialManager(ts);
                    currentRm =getReinforcementManager(tm);
                    
                    %edf 12.05.08: this immutable thing is bad design, i'm removing it:
                    %1) we are not changing the reinforcementManager, but rather the trialManager.  
                    %2) it's not the subject's business to know
                    %       about/enforce immutability of other objects.  such
                    %       logic should be contained in those objects' setter
                    %       methods.
                    %3) it does not throw an error/warning if immutable
                    
                    %immutable=getImmutable(currentRm);
                    %if ~immutable
                        tm =setReinforcementManager(tm,rm);
                        ts=setTrialManager(ts,tm);
                    %end

                    [subject r]=changeProtocolStep(subject,ts,r,comment,auth,i);
            end
           
else
    error('need reinforcement manager and ratrix that contains this subject')
end