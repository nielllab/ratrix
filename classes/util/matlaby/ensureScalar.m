function arrayOut=ensureScalar(cellIn)
if isvector(cellIn)
    if all(cellfun(@isscalar,cellIn))
        arrayOut=[cellIn{:}];
    else
        error('not all scalar')
    end
else
    error('cellIn must be cell vector')
end
end