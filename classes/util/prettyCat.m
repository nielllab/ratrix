function out=prettyCat(c)
    out='{';
    if iscellstr(c)
        c={c{:}};
        for i=1:length(c)
            out=[out '''' c{i} '''' ' '];
        end
        out=[out '}'];
    else
        error('input must be cell array of strings')
    end
end