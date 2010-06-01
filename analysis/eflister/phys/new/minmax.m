function out=minmax(in)
try
    if ~isempty(in)
        out = cellfun(@(x) x(in(:)),{@min,@max});
    else
        out=[];
        %preserves old minnax's handling of []
    end
catch ex
    warning('minmax fail')
    keyboard
    getReport(ex)
end
end