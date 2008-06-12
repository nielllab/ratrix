function out=getSubjectIDsForBoxID(r,b)

    bx=getBoxFromID(r,b);
%     'assign'
%     b
%     r.assignments{b}{2}
    out=[r.assignments{b}{2}];