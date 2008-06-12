function r = addBox(r,b)
    if isa(b,'box')
        
        [member index]=ismember(getID(b),getBoxIDs(r));
        if index>0
            error('ratrix already contains a box with that id')

        else
            n=length(r.boxes)+1;
            r.boxes{n}=b;
            r.assignments{getID(b)}={{},{}};
            saveDB(r,0);   
            clearSubjectDataDir(b);
        end
        
    else
        error('argument not box object')
    end