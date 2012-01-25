function s=setDotParams(s,b)
f=fields(b);
for i=1:length(f)
    if ismember(f{i},fields(s))
        s.(f{i})=b.(f{i});
    end
end