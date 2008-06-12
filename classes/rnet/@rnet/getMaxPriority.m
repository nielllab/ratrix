function out=getMaxPriority(r)
ps=fieldnames(r.constants.priorities);
out=[];
for i=1:length(ps)
    if isempty(out) || r.constants.priorities.(ps{i})<out
        out= r.constants.priorities.(ps{i});
    end
end