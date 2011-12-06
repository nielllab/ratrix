function [subject r]=setReinforcementParam(subject,param,val,stepNums,r,comment,auth)

if isa(r,'ratrix') && ~isempty(getSubjectFromID(r,subject.id))
    if isempty(subject.protocol)
       error('subject must have non-empty protocol') 
    end
    
    switch stepNums
        case 'all'
            steps=uint8(1:getNumTrainingSteps(subject.protocol));
        case 'current'
            steps=subject.trainingStepNum;
        otherwise
            if isvector(stepNums) && isNearInteger(stepNums) && all(stepNums>0 & stepNums<=getNumTrainingSteps(subject.protocol))
                steps=uint8(stepNums);
            else
                error('stepNums must be ''all'', ''current'', or an integer vector of stepnumbers between 1 and numSteps')
            end
    end
    
    for i=steps
        ts=getTrainingStep(subject.protocol,i);
        
        ts=setReinforcementParam(ts,param,val);
        [subject r]=changeProtocolStep(subject,ts,r,comment,auth,i);
        
    end
    
else
    error('need reinforcement manager and ratrix that contains this subject')
end