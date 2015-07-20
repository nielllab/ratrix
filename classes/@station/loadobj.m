function a = loadobj(a)
    function checkField(f)
        if ~isfield(a,f)
            a.(f) = [];
        end
    end

if isa(a,'station')
    % do nothing
elseif isstruct(a) % a is an old version
    fields = {
        'laserPins'
        'ptbVersion'
        'screenVersion'
        'skipSyncTests'
        'matlabVersion'
        'matlab64'
        'win64'
        'computer'
        'diary'
        };
    
    cellfun(@checkField,fields);
    
    if false
        if ~isfield(a,'laserPins')
            a.laserPins = [];
        end
    end

    try
        a = class(orderfields(a,struct(station)),'station'); %love you mw (mathworks, not mike wehr ;)
        %a = class(a,'station');
    catch ex
        getReport(ex)
        keyboard
    end
else
    class(a)
    a
    keyboard
    error('station loadobj fail')
end
end