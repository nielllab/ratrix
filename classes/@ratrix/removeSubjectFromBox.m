function r=removeSubjectFromBox(r,s,b,comment,author)
sub=getSubjectFromID(r,s);
box=getBoxFromID(r,b);

if boxIDRunning(r,b)
    error('cannot remove subject from running box, first call stop() on the box')
elseif subjectIDRunning(r,s)
    error('cannot remove a currently running subject, first call stop() on the subject')
elseif getBoxIDForSubjectID(r,s)~=b
    error('that subject is not in that box')
elseif ~authorCheck(r,author)
    error('author does not authenticate')
elseif ~testBoxSubjectDir(box,sub)
    error('cannot access subject''s directory in box')
else
    r.assignments{b}{2}=removeStr(r.assignments{b}{2},s);
    saveDB(r,0);
    
%     r
%     class(r)
%     sub
%     class(sub)
%     class(s)
%     class(b)
%     s
%     b
     sprintf('%s: removed subject %s from box %d',comment,s,b)
%     author
    recordInLog(r,sub,sprintf('%s: removed subject %s from box %d',comment,s,b),author);

end