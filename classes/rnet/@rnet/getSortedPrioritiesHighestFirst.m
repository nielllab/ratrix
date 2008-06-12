function out=getSortedPrioritiesHighestFirst(r)
ps=fieldnames(r.constants.priorities);
out=[];
for i=1:length(ps)
    out=[out r.constants.priorities.(ps{i})];
end
out=sort(out);