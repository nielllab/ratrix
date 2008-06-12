function isCached=stimIsCached(t)
%method to determine if it is cached



if isempty(t.cache)
    isCached=0;
else
    switch t.renderMode
        case 'ratrixGeneral'
            if size(t.cache.goRightStim,1)>0
                isCached=1;
                %confirm all there
                if size(t.cache.goRightStim,1)>0 & size(t.cache.goLeftStim,1)>0 & size(t.cache.flankerStim,1)>0
                    %okay
                else
                    error('partially inflated stim')
                end
            else
                isCached=0;
            end
        case 'directPTB'
            if isempty(t.cache.orientationPhaseTextures)
                isCached=0;
            else
                isCached=1;
            end
    end
end