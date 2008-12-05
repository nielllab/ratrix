function [subject r]=changeProtocolStep(subject,ts,r,comment,auth,stepNum)

if isa(ts,'trainingStep') && isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))
    if subject.trainingStepNum>0

        if ~exist('stepNum','var')||isempty(stepNum)
            stepNum=subject.trainingStepNum;
        end

        if authorCheck(r,auth)

            for i=1:getNumTrainingSteps(subject.protocol)
                if i~=stepNum
                    steps{i}=getTrainingStep(subject.protocol,i);
                else
                    steps{i}=ts;
                end
            end

            [subject r]=setProtocolAndStep(subject,protocol(getName(subject.protocol),steps),0,1,0,subject.trainingStepNum,r,comment,auth);

        else
            error('author failed authentication')
        end
    else
        error('subject not on a training step')
    end
else
    error('need trainingStep and ratrix that contains this subject')
end