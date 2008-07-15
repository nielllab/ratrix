function pass=checkShapingValues(sm,shapingMethod,shapingValues)
%this function only checks the the second and third argument, not the first

pass=0;

if ~isempty(shapingMethod)
    switch shapingMethod
        case 'exponentialParameterAtConstantPerformance'
            error ('need to write an error check')

        case 'geometricRatioAtCriteria'
            error ('need to write an error check')

        case 'linearChangeAtCriteria'
            if  ~(isinteger(shapingValues.numSteps) & shapingValues.numSteps>0)
                error ('when using linearChangeAtCriteria, numSteps must be an integer greater than 0')
            end
            if  ~(isnumeric(shapingValues.performanceLevel) & all(shapingValues.performanceLevel>=0 & shapingValues.performanceLevel<=1))
                error ('when using linearChangeAtCriteria, performanceLevel must be a between 0 and 1')
            end
            if ~(length(shapingValues.numTrials) == length(shapingValues.performanceLevel))
                error ('numTrials vector and performanceLevel vector must be the same length')
            end   
            if  ~(isinteger(shapingValues.numTrials) & all(shapingValues.numTrials>0))
                error ('when using linearChangeAtCriteria, numTrials must be an integer greater than 0')
            end
            if  ~isnumeric(shapingValues.startValue)
                error ('when using linearChangeAtCriteria, startValue must be numeric')
            end

            if  ~isnumeric(shapingValues.goalValue)
                error ('when using linearChangeAtCriteria, goalValue must be a numeric')
            end
    end
    
             if  ~isnumeric(shapingValues.currentValue)
                error ('all methods must have a currentValue and it must be numeric')
            end
end

pass=1;
