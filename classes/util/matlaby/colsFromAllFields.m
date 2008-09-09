function out=colsFromAllFields(s,cols)
if isscalar(s) && isstruct(s)
    fn=fieldnames(s);
    for k=1:length(fn)
        out.(fn{k})=s.(fn{k})(:,cols);
    end
else
    error('s has to be a scalar struct')
end
end