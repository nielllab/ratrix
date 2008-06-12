function out=isValidError(r,e)
es=fieldnames(r.constants.errors);
out=false;
for i=1:length(es)
    if r.constants.errors.(es{i})==e
        out= true;
    end
end