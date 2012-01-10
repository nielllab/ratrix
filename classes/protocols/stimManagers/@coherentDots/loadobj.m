function a = loadobj(a)
if isa(a,'coherentDots')
    % do nothing
else % a is an old version
    if ~isfield(a,'sideDisplay')
        a.sideDisplay=1;
    end
    
    if ~isfield(a,'position')
        a.position=.5;
    end
    
    if ~isfield(a,'shapeMethod')
        a.shapeMethod=[];
    end
        
    a=orderfields(a,struct(coherentDots));
    
    % a = class(a,'coherentDots');%,stimManager);  %according to doc (page 1-66 of http://www.mathworks.com/help/pdf_doc/matlab/pre-version_7.6_oop.pdf),
    % this should work,
    % but gives warning saying that call to 'clear classes' is necessary because we're changing number of fields (not true)
    % and we are left with structs
    
    % so we have to rebuild from scratch (really lame!)
    dots=coherentDots(a.screen_width,a.screen_height,a.num_dots,a.coherence,a.speed,a.contrast,a.dot_size,a.movie_duration, ...
        struct(a.stimManager).scaleFactor,struct(a.stimManager).maxWidth,struct(a.stimManager).maxHeight, ...
        a.pctCorrectionTrials,a.replayMode,double(struct(a.stimManager).interTrialLuminance)/double(intmax('uint8')));
    
    check(struct(dots),a);
    a=dots;
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
        elseif ~all(a==b)
            keyboard
            error('bad conversion')
        end
    else
        check(struct(a),struct(b));
    end
end
end