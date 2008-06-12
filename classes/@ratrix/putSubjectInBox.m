function r=putSubjectInBox(r,s,b,author)
    sub=getSubjectFromID(r,s);
    box=getBoxFromID(r,b);
    
        if boxIDRunning(r,b)
            error('cannot put a subject in a currently running box, first call stop() on the box')
        elseif subjectIDRunning(r,s)
            error('cannot change box for a currently running subject, first call stop() on the subject''s box')
        elseif getBoxIDForSubjectID(r,s)>0 && getBoxIDForSubjectID(r,s)~=b
            error('cannot put a subject who is already in a box into a different box, first remove the subject from its current box')
        elseif getBoxIDForSubjectID(r,s)==b
            error('subject already in that box')
        else
            [p,i]=getProtocolAndStep(sub);
            if isempty(p)
                error('cannot put a subject with no protocol into a box, first assign it a protocol')
            elseif isempty(getStationsForBoxID(r,b))
                error('cannot put a subject in a box with no stations, first assign stations to box')
            elseif ~boxOKForProtocol(p,box,r)
                error('box has no stations suitable for subject''s protocol')
            elseif ~testBoxSubjectDir(box,sub)
                error('could not access subject''s directory in new box')
            elseif ~authorCheck(r,author)
                error('author does not authenticate')
            else
                r.assignments{b}{2}{end+1}=s;
                saveDB(r,0);
                recordInLog(r,sub,sprintf('put subject %s in box %d',s,b),author);
            end
        end
