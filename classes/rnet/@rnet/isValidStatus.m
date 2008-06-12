function out=isValidStatus(r,s)
ss=fieldnames(r.constants.statuses);
out=false;
for i=1:length(ss)
    if r.constants.statuses.(ss{i})==s
        out= true;
    end
end