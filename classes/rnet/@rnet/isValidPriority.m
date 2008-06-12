function out=isValidPriority(r,p)
ps=fieldnames(r.constants.priorities);
out=false;
for i=1:length(ps)
    if r.constants.priorities.(ps{i})==p
        out= true;
    end
end