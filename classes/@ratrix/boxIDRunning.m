function out=boxIDRunning(r,b)
        out=0;
        [member index]=ismember(b,getBoxIDs(r));
        if index>0
            for i=1:size(r.assignments{b}{1},1)
                out=out || r.assignments{b}{1}{i,2};
            end
        else
            error('no such box id')
        end