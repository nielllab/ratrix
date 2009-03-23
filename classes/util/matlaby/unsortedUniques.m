function out = unsortedUniques(input)
% this finds the unique elements of input, and returns them in the order in which they are found in the input vector
% instead of matlab automatically sorting them

if ~isvector(input)
    error('only works for vectors');
end
out=[];

for i=1:length(input)
    if isempty(find(out==input(i)))
        out=[out input(i)];
    end
end

end