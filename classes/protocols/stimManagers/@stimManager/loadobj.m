function a = loadobj(a)
if isa(a,'stimManager')
    % do nothing
elseif isstruct(a) % a is an old version
    if ~isfield(a,'correctStim')
        a.correctStim=[];
    end
    
    try
        a = class(orderfields(a,struct(stimManager)),'stimManager'); %love you mw
        % a = class(a,'stimManager');
    catch ex
        keyboard
    end
else
    class(a)
    a
    keyboard
    error('stimManager loadobj fail')
end
end