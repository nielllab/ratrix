function arrayOut=ensureEqualLengthVects(cellIn)
if isvector(cellIn)
    if all(cellfun(@isvector,cellIn))
        if all(diff(cellfun(@length,cellIn))==0)
            arrayOut=cellfun(@doCat,cellIn,'UniformOutput',false);
            arrayOut=cell2mat(arrayOut);
        else
            error('not all same length')
        end
    else
        error('not all vectors')
    end
else
    error('cellIn must be cell vector')
end
end

function v=doCat(v)
if size(v,2)>1
    v=v';
end
end