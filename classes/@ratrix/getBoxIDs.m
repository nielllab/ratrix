function out=getBoxIDs(r)
    out=[];
    for i=1:length(r.boxes)
        out(i)=getID(r.boxes{i});
    end