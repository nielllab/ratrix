function r=updateSubjectProtocol(r,s,comment,auth,listProtocol,listTrainingStep,listStepNum)
[member index]=ismember(getID(s),getSubjectIDs(r));
if isa(s,'subject') && member && index>0 && ~subjectIDRunning(r,getID(s))
    if authorCheck(r,auth)
        
        r.subjects{index}=s;

        [p i]=getProtocolAndStep(s);
        
        if listProtocol
            protocolListing=sprintf('\n%s',display(p));
        else
            protocolListing='';
        end

        if listTrainingStep
            stepListing=sprintf('\n%s',display(getTrainingStep(p,i)));
        else
            stepListing='';
        end

        if listStepNum
            newStepStr=[': setting to step ' num2str(i) '/' num2str(getNumTrainingSteps(p)) ' of protocol: ' getName(p)];
        else
            newStepStr='';
        end
        
        recordInLog(r,s,[comment newStepStr protocolListing stepListing],auth);
        saveDB(r,0);

    else
        error('author failed authentication')
    end
else
    error('either not a subject or not a subject in this ratrix or subject is running')
end