function a = loadobj(a)
if isa(a,'station')
    % do nothing
elseif isstruct(a) % a is an old version
    if ~isfield(a,'laserPins')
        a.laserPins = [];
    end    
    
    try
        a = class(orderfields(a,struct(station)),'station'); %love you mw (mathworks, not mike wehr ;)
        %a = class(a,'station');
    catch ex
        keyboard
    end
else
    class(a)
    a
    keyboard
    error('station loadobj fail')
end
end