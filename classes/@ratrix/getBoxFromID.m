function b=getBoxFromID(r,id)
    [member index]=ismember(id,getBoxIDs(r));
    if index>0
        b=r.boxes{index};
    else
        error('request for box id not contained in ratrix')
    end