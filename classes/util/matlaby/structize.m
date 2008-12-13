function s=structize(s)
if iscell(s)
    s=cellfun(@structize,s,'UniformOutput',false);
elseif isobject(s) || isstruct(s)
    if isscalar(s) || all(size(s)==0) %size(object with no data members) is [0 0]
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
        if ~all(size(s)==0) %structfun can't handle s=struct([]) which is [0 0] 
            s=structfun(@structize,s,'UniformOutput',false); %requires scalar s
        end
    else
        s=arrayfun(@structize,s,'UniformOutput',true);
    end
else
    %pass through non-object/struct/cell
end