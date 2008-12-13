function s=structize(s)
if iscell(s)
    s=cellfun(@structize,s,'UniformOutput',false);
elseif isobject(s) || isstruct(s)
    if isscalar(s)
        if isobject(s)
            t=class(s);
            s=struct(s);
            f=fields(s);
            if ~ismember('originalType',f)
                if isempty(s)
                    s=struct;
                end
                s.originalType=t;
            else
                error('already a originalType field')
            end
        end

        s=structfun(@structize,s,'UniformOutput',false); %requires scalar s
    else
        s=arrayfun(@structize,s,'UniformOutput',true);
    end
else
    %pass through non-object/struct/cell
end