function pass=checkDynamicFlicker(sm,dynamicFlicker)
%this function only checks the the second, not the first
%
%
%example setup
%dynamicFlicker.flickerMode='random';
%dynamicFlicker.sweptParameters={'flankerContrast','phase'};
%dynamicFlicker.flickeringValues{1}=[0 0.5 1];
%dynamicFlicker.flickeringValues{2}=sm.phase;
%dynamicFlicker.framesSavedBeforeAfter=[300 100]

pass=0;

if ~isempty(dynamicFlicker)
        switch dynamicFlicker.flickerMode
        case 'random'
            % nothing to check
        case {'manual','sequence'}
            error('not yet');
            if ~(size(dynamicSweep.sweptValues, 1)==size(dynamicSweep.sweptParameters,2) & isnumeric(dynamicSweep.sweptValues))
                error ('sweptValues must be a matrix m=numParameters x n=numValues')
            end
        otherwise
            dynamicSweep.sweepMode{1}
            error('bad sweep mode');
        end
    
        
    if ~(all(ismember(dynamicFlicker.flickeringParameters,[fields(sm); {'targetOrientations', 'targetContrast'}'])))
        dynamicFlicker.flickeringParameters
        
        error('flickeringParameters must be a cell array of fields on the sm or belong to an acceptable list')
    end
    
    %check flicker values
    for i=1:length(dynamicFlicker.flickeringParameters)
        param=dynamicFlicker.flickeringParameters{i};
        values=dynamicFlicker.flickeringValues{i};
  
        if any(isnan(values) | isinf(values))
            error('nan or inf!'); %there is no reason why any of these values shjould be nan or inf, it would just be a mistake
        end
        
        switch param
            case {'targetOrientations','flankerOrientations','flankerPosAngle','phase'}
                if ~(isnumeric(values) && isvector(values))
                    values
                    error('bad orientations')
                end
            case {'flankerOffset'} %fields with same name, update spatial params
                if any(~ismember(values,[2.5 3 3.5 4 5]))
                    values
                    error('unexpected values')
                end    
            case {'targetContrast','flankerContrast'}  % is the same in the details is the name in the stim manager and requres no computation
                if ~all(values>=0 & values<=1)
                    values
                    error('bad contrasts')
                end
            otherwise
                error(sprintf('bad param: %s',param))
        end
    end
    
    if ~(length(dynamicFlicker.framesSavedBeforeAfter)==2 && all(iswholenumber(dynamicFlicker.framesSavedBeforeAfter) & (dynamicFlicker.framesSavedBeforeAfter>=0)))%%|| isinf(dynamicSweep.framesSavedBeforeAfter))
        error('framesSavedBeforeAfter must a whole number greater than 0, or Inf')
    end
end

pass=1;

