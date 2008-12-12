function s=structize(s)
if iscell(s)
    s=cellfun(@structize,s,'UniformOutput',false);
% elseif any(size(s)>1)
%     if ischar(s) && isvector(s)
%     else
%         s=arrayfun(@structize,s,'UniformOutput',false);
%     end
elseif isobject(s) || isstruct(s)
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

    s=structfun(@structize,s,'UniformOutput',false);
else
    %Everything else just pass through
end