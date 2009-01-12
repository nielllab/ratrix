function pass=checkBlocking(sm,blocking)
%this function only checks the the second, not the first

pass=0;

if ~isempty(blocking)
    switch blocking.blockingMethod
        case 'nTrials'
            if  ~(iswholenumber(blocking.nTrials) & blocking.nTrials>0)
                error ('nTrials must be number > 0')
            end

            if ~(all(ismember(blocking.sweptParameters,[fields(sm);{'targetOrientations','targetContrast'}'])))
                error('sweptParameters must be a cell array of fields on the sm OR special approved list: targetOrientations, targetContrast')
            end

            if ~(size(blocking.sweptValues, 1)==size(blocking.sweptParameters,2) & isnumeric(blocking.sweptValues))
                error ('sweptValues must be a matrix m=numParameters x n=numValues')
            end

        case 'daily'
            if  ~(isnumeric(blocking.anchorDay) & blocking.anchorDay>=0)
                error ('anchorDay must be number >= 0')
            end

        otherwise
            blocking.blockingMethod
            error('bad blocking method');
    end
end

pass=1;
