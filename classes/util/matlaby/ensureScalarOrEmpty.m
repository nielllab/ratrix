function arrayOut=ensureScalarOrEmpty(cellIn)
% changes empty ([]) to zero (0)
if isvector(cellIn)
    cellIn{cellfun(@isempty,cellIn)}=0;
    if all(cellfun(@isscalar,cellIn))
        arrayOut=[cellIn{:}];
    else
        error('not all scalar or empty')
    end
else
    error('cellIn must be cell vector')
end
end