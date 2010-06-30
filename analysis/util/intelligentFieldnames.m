function [out finished] = intelligentFieldnames(in)
if ~exist('in','var')
    error('need and input structure');
end
out= {};
finished = false;
if isempty(in) || ~isstruct(in)
    finished = true;
    return
end
fIn = fieldnames(in);
for outer = 1:length(fIn)
    [internalFieldNames finished] = intelligentFieldnames(in.(fIn{outer}));
    if finished & ~isempty(internalFieldNames)
        for inner = 1:length(internalFieldNames)
            out(end+1) = {{fIn{outer},internalFieldNames{inner}}};
        end
    else
        out(end+1) = {fIn{outer}};
    end
end    
end
    