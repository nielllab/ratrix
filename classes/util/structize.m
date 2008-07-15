function s=structize(s)
if iscell(s)
    for i=1:length(s)
        s{i}=structize(s{i});
    end
elseif isobject(s) || isstruct(s)
    s=struct(s);
    f=fields(s);
    for i=1:length(f)
        setfield(s,f{i},structize(getfield(s,f{i})));
    end
else
    class(s)
end
%Everything else just pass through