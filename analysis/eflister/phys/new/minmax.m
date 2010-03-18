function out=minmax(in)
out = cellfun(@(x) x(in),{@min,@max});
end