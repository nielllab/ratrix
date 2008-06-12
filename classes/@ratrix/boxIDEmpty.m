function out=boxIDEmpty(r,b)

        [member index]=ismember(b,getBoxIDs(r));

        if index>0

            out= isempty(r.assignments{b}{2});
            
        else
            error('no such box id')
        end