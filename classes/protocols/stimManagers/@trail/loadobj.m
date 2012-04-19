function a = loadobj(a)
if isa(a,'trail')
    % do nothing
else % a is an old version    
    fields = {'gain','targetDistance','timeoutSecs','slow','slowSecs','positional','stim'}; %initialPos, mouseIndices
    
    for i=1:length(fields)
        if ~isfield(a,fields{i})
            a.(fields{i}) = nan;
        end
    end
      
    a=orderfields(a,struct(trail));
    
    % a = class(a,'coherentDots');%,stimManager);  %according to doc (page 1-66 of http://www.mathworks.com/help/pdf_doc/matlab/pre-version_7.6_oop.pdf),
    % this should work,
    % but gives warning saying that call to 'clear classes' is necessary because we're changing number of fields (not true)
    % and we are left with structs
    
    % so we have to rebuild from scratch (really lame!)
    t=trail(a,struct(a.stimManager).maxWidth,struct(a.stimManager).maxHeight, ...
        struct(a.stimManager).scaleFactor,double(struct(a.stimManager).interTrialLuminance)/double(intmax('uint8')));

    
% stim.gain = .35 * ones(2,1);
% stim.targetDistance = 300;
% stim.timeoutSecs = .5;
% stim.slow = [50; 100]; % 10 * ones(2,1);
% stim.slowSecs = .5;
% 
% ballSM = trail(stim,maxWidth,maxHeight,zoom,0);
    
    check(struct(t),a);
    a=t;
end
end

function check(f1,f2)
f=fields(f1);
for i=1:length(f)
    a=f1.(f{i});
    b=f2.(f{i});
    if ~isobject(a)
        if ismember(f{i},{'LUT','LUTbits'})
            if ~isempty(a) && ~(isscalar(a) && a==0)
                keyboard
                error('bad conversion')
            end
        elseif ~all(a==b) && ~ismember(f{i},{'initialPos','mouseIndices'}) && ~all(cellfun(@isnan,{a b})) %figure out what to do aobut initialPos and mouseIndices later... 
            keyboard
            error('bad conversion')
        end
    else
        check(struct(a),struct(b));
    end
end
end