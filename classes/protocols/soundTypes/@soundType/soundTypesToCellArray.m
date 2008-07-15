function out=soundTypesToCellArray(array)
% calls soundTypeToString on each element of the input array (assuming they are soundType objects)

out = cell(1, length(array));
for i=1:length(array)
    out{i} = soundTypeToString(array{i});
end
