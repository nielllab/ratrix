function [subject r]=changeProtocolStep(subject,ts,r,comment,auth,stepNum)

if ~exist('stepNum','var')||isempty(stepNum)
    stepNum=subject.trainingStepNum;
end

if isa(ts,'trainingStep') && isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))
    if ~isempty(subject.protocol) && stepNum>0 && stepNum<=getNumTrainingSteps(subject.protocol)
       
        
        if authorCheck(r,auth)
                       
            newProtocol = changeStep(subject.protocol, ts, stepNum);
            
            [subject r]=setProtocolAndStep(subject,newProtocol,0,1,0,subject.trainingStepNum,r,comment,auth);
            
        else
            error('author failed authentication')
        end
    else
        error('subject does not have a protocol, or stepNum is not a valid index of trainingSteps in the protocol')
    end
else
    error('need trainingStep and ratrix that contains this subject')
end