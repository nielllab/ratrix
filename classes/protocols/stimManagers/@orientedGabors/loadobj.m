function a = loadobj(a)
if isa(a,'orientedGabors')
    % do nothing
else % a is an old version    
    fields = {'mask'};
    
    for i=1:length(fields)
        if ~isfield(a,fields{i})
            a.(fields{i}) = nan;
        end
    end
      
    parent = a.stimManager;
    a = rmfield(a,'stimManager');
    a = class(a,'orientedGabors',parent);
end