function s=getStationsForBoxID(r,id)
    b=getBoxFromID(r,id);
    if ~isempty(b)
        s=[r.assignments{id}{1}{:,1}];
    else
        error('box id not contained in ratrix')
    end