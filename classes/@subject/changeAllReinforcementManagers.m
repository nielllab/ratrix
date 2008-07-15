function [subject r]=changeAllReinforcementManagers(subject,rm,r,comment,auth)
   
if isa(rm,'reinforcementManager') && isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))
          
            for i=1:getNumTrainingSteps(subject.protocol)
                    ts=getTrainingStep(subject.protocol,i);
                    tm=getTrialManager(ts);
                    currentRm =getReinforcementManager(tm);
                    immutable=getImmutable(currentRm);
                    if ~immutable
                        tm =setReinforcementManager(tm,rm);
                        ts=setTrialManager(ts,tm);
                    end 
                    steps{i}=ts;
            end
            
            [subject r]=setProtocolAndStep(subject,protocol(getName(subject.protocol),steps),0,1,0,subject.trainingStepNum,r,comment,auth);
           
else
    error('need reinforcement manager and ratrix that contains this subject')
end