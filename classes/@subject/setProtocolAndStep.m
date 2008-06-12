function [s r]=setProtocolAndStep(s,p,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,i,r,comment,auth)

if isa(p,'protocol') && isa(r,'ratrix') && ~isempty(getSubjectFromID(r,s.id)) && ~subjectIDRunning(r,s.id)
    if i<=getNumTrainingSteps(p) && i>=0
        if authorCheck(r,auth)
            s.protocol=p;
            s.trainingStepNum=i;

            if strcmp(auth,'ratrix')
                s.protocolVersion.autoVersion=s.protocolVersion.autoVersion+1;
            else
                s.protocolVersion.autoVersion=1;
                s.protocolVersion.manualVersion=s.protocolVersion.manualVersion+1;
            end
            s.protocolVersion.date=datevec(now);
            s.protocolVersion.author=auth;

            r=updateSubjectProtocol(r,s,comment,auth,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum);

        else
            error('author failed authentication')
        end
    else
        error('need a valid step number')
    end
else
    isa(p,'protocol')
    isa(r,'ratrix')
    ~isempty(getSubjectFromID(r,s.id))
    ~subjectIDRunning(r,s.id)
    error('need a protocol object, a valid ratrix with that contains this subject, and this subject can''t be running')
end