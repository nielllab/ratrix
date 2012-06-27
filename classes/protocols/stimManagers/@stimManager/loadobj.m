function a = loadobj(a)
if isa(a,'stimManager')
    % do nothing
elseif isstruct(a) % a is an old version
    if ~isfield(a,'correctStim')
        a.correctStim = [];
    end
    
    if ~isfield(a,'reinfAssocSecs')
        a.reinfAssocSecs = 0; %hmm, had hardcoded it to 1 for a while...
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