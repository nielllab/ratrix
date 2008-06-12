function out=notMember(list,p)
out=1;
if iscell(list) && iscell(p) && length(p)==2
    for i=1:length(list)
        x=list{i};
        if iscell(x) && length(x)==2
            if strcmp(p{1},x{1}) && p{2}==x{2}
                out=0;
            end
        else
            error('need cells, p is {''hexaddr'',pinNum} and list is a cell of them')
        end
    end
else
    error('need cells, p is {''hexaddr'',pinNum} and list is a cell of them')
end