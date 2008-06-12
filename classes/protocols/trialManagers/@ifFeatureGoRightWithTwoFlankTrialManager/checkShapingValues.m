function pass=checkShapingValues(tm,shapingMethod,shapingValues)
%this function only checks the the second and third argument, not the first

pass=0;

if ~isempty(shapingMethod)
    switch shapingMethod
        case 'exponentialParameterAtConstantPerformance'
            error ('need to write an error check')

        case 'geometricRatioAtCriteria'
            error ('need to write an error check')

        case 'linearChangeAtCriteria'
            if  isinteger(shapingValues.numSteps) & shapingValues.numSteps>0
                error ('when using linearChangeAtCriteria, numSteps must be an integer greater than 0')
            end
            if  isnumeric(shapingValues.performanceLevel) & shapingValues.performanceLevel>=0 & shapingValues.performanceLevel<=1
                error ('when using linearChangeAtCriteria, performanceLevel must be a between 0 and 1')
            end
            if  isinteger(shapingValues.numTrials) & shapingValues.numTrials>0
                error ('when using linearChangeAtCriteria, numTrials must be an integer greater than 0')
            end
            if  isnumeric(shapingValues.startValue)
                error ('when using linearChangeAtCriteria, startValue must be numeric')
            end
            if  isnumeric(shapingValues.currentValue)
                error ('when using linearChangeAtCriteria, currentValue must be a numeric')
            end
            if  isnumeric(shapingValues.goalValue)
                error ('when using linearChangeAtCriteria, goalValue must be a numeric')
            end
    end
end

pass=1;
