function [subject r]=changeAllPercentCorrectionTrials(subject,newValue,r,comment,auth)
   
if isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))
          
            for i=1:getNumTrainingSteps(subject.protocol)
                    ts=getTrainingStep(subject.protocol,i);
                    sm=getStimManager(ts);
                    updatable =hasUpdatablePercentCorrectionTrial(sm);
                    if updatable
                        sm=setPercentCorrectionTrials(sm,newValue);
                        ts=setStimManager(ts,sm);
                    end 
                    steps{i}=ts;
            end
            
            [subject r]=setProtocolAndStep(subject,protocol(getName(subject.protocol),steps),0,1,0,subject.trainingStepNum,r,comment,auth);
           
else
    error('needs ratrix that contains this subject')
end