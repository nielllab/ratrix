function sub=getCurrentSubject(s,r)
    if isa(r,'ratrix')
        subs=getSubjectsForStationID(r,s.id);
        if length(subs)==1
            sub=subs{1};
        else
            error('only implemented for stations in boxes with exactly one subject -- later will use RFID for group housing')
        end
    else
        error('need a ratrix')
    end