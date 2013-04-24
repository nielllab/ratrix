function a = loadobj(a)
if isa(a,'orientedGabors')
    % do nothing
else % a is an old version
    if ~isfield(a,'pos') && isfield(a,'yPosPct') && ~isfield(a,'axis')
        warning('old version found')
        a.pos = a.yPosPct
        a = rmfield(a,'yPosPct');
        a.axis = 0;
    else
        error('huh?')
    end
    
    try
        a = class(orderfields(a,struct(orientedGabors)),'orientedGabors'); %love you mw (mathworks, not mike wehr ;)
    catch ex
        % getReport(ex)
        % keyboard
        
        % we have to rebuild from scratch (really lame!), even though it shouldn't know about the old class definition...
        
        % double(struct(a.stimManager).interTrialLuminance)/double(intmax('uint8')));
        
        try
            og = orientedGabors(a.pixPerCycs,a.targetOrientations,a.distractorOrientations,a.mean,a.radius,a.contrasts,a.thresh,a.pos,struct(a.stimManager).maxWidth,struct(a.stimManager).maxHeight,struct(a.stimManager).scaleFactor,struct(a.stimManager).interTrialLuminance,a.waveform,a.normalizedSizeMethod,a.axis);
            check(struct(og),a);
            a = og;
        catch ex
            getReport(ex)
            keyboard
        end
    end
end
end

function check(f1,f2)
f=fields(f1);
for i=1:length(f)
    a=f1.(f{i});
    b=f2.(f{i});
    if isstruct(a)
        check(a,b);
    elseif ~isobject(a)
        if ismember(f{i},{'lut','lutbits'}) %why are these special?  why is case wrong (shouldn't be LUT/LUTbits?)?
            if ~isempty(a) && ~(isscalar(a) && a==0)
                keyboard
                error('bad conversion')
            end
        elseif ~all(a==b)
            keyboard
            error('bad conversion')
        end
    else
        check(struct(a),struct(b));
    end
end
end