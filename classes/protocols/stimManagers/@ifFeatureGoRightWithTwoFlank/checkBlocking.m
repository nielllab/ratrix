function pass=checkBlocking(sm,blocking)
%this function only checks the the second, not the first

pass=0;

if ~isempty(blocking)
    switch blocking.blockingMethod
        case 'nTrials'
            if  ~(iswholenumber(blocking.nTrials) & blocking.nTrials>0)
                error ('nTrials must be number > 0')
            end

            if ~(all(ismember(blocking.sweptParameters,[fields(sm);{'targetOrientations','targetContrast','flankerOn', 'flankerOff'}'])))
                error('sweptParameters must be a cell array of fields on the sm OR special approved list: targetOrientations, targetContrast,flankerOn, flankerOff')
            end

            if ~(size(blocking.sweptValues, 1)==size(blocking.sweptParameters,2) & isnumeric(blocking.sweptValues))
                error ('sweptValues must be a matrix m=numParameters x n=numValues')
            end
            
            if ~ismember(blocking.shuffleOrderEachBlock,[0 1])
                error ('shuffleOrderEachBlock must be 0 or 1')
            end

        case 'daily'
            if  ~(isnumeric(blocking.anchorDay) & blocking.anchorDay>=0)
                error ('anchorDay must be number >= 0')
            end

            if ~ismember(blocking.shuffleOrderEachBlock,[0 1])
                error ('shuffleOrderEachBlock must be 0 or 1')
            end
            
        otherwise
            blocking.blockingMethod
            error('bad blocking method');
    end
end

pass=1;
