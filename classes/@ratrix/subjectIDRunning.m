function out=subjectIDRunning(r,s)
    bx=getBoxIDForSubjectID(r,s);
    if bx==0
        out=0;
    else  
        out=boxIDRunning(r,bx);
    end