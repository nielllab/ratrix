function cellIn=ensureTypedVector(cellIn,t)
if isvector(cellIn)
    if all(cellfun(@isvector,cellIn) | cellfun(@isempty,cellIn))
        if strcmp(t,'index') && all(cellfun(@(x)(all(arrayfun(@isNearInteger,x)) && all(round(x)>0) && all(isreal(x))),cellIn))
            %pass
        elseif all(cellfun(@(x)strcmp(class(x),t),cellIn))
            %pass
        else
            cellfun(@class,cellIn,'UniformOutput',false)
            error('not all of class')
        end
    else
        tmp=cellfun(@size,cellIn,'UniformOutput',false);
        tmp{:}
        error('not all vectors')
    end
else
    error('requires vector cell in')
end