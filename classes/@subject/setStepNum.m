function [s r]=setStepNum(s,i,r,comment,auth)

if isa(r,'ratrix') && ~isempty(getSubjectFromID(r,s.id)) && ~subjectIDRunning(r,s.id)
    [p t]=getProtocolAndStep(s);
    
    if isscalar(i) && isinteger(i) && i<=getNumTrainingSteps(p) && i>=0
        if authorCheck(r,auth)
            [s r]=setProtocolAndStep(s,p,0,0,1,i,r,comment,auth);
        else
            error('author failed authentication')
        end
    else
        error('need a valid integer step number')
    end
else
    error('need a valid ratrix with that contains this subject, and this subject can''t be running')
end