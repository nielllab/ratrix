function    [parameterChanged, newTM]  = shapeParameter(t, trialRecords)

parameterChanged = 0;

%% doShape

switch  t.shapingMethod
    case 'exponentialParameterAtConstantPerformance'
        error('code not written yet, will be completed when Yuan returns next year after the 2nd of January');
    case 'geometricRatioAtCriteria'
        error('code not written yet, will be completed when Yuan returns');
    case 'linearChangeAtCriteria'
        [aboveThresh ]=aboveThresholdPerformance(t.shapingValues.numTrials, t.shapingValues.performanceLevel, trialRecords)
        if aboveThresh
            delta = (t.shapingValues.goalValue-t.shapingValues.startValue)/(numSteps-1);
            newParameterValue = t.shapingValues.currentValue + delta;
            parameterChanged = 1;
            % if parameter has reached its goal or has exceeded it
            % ...depends on currentValue never moving away from the goalValue
            % current == start | sign(current - goal) == sign(current - start)
            if  t.shapingValues.currentValue == t.shapingValues.goalValue |sign(t.shapingValues.currentValue - t.shapingValues.goalValue) == sign(t.shapingValues.currentValue - t.shapingValues.goalValue) 
                % force graduation to the next step
                % how should we do this? need to influence graduation in the
                % trainingStep ...
            end
        end
    otherwise
        error('not an acceptable shaping method');
end

%% set value

if update
    switch t.shapedParameter
        case 'positionalHint'
            t.positinalHint = newParameterValue;
        case 'stdGaussianMask'
            t.stdGaussMask = newParameterValue;
        case 'targetContrast'
            t.targetContrast = newParameterValue;
        otherwise
            error('that parameter cannot be shaped');
    end
end

%move to quickloop, error check it
if 0
            params.numSteps = 6;
            params.performanceLevel = 0.75;
            params.numTrials = [100];
            params.startValue = 0.2;
            params.currentValue = params.startValue;
            params.goalValue = 0.1;
            t.shapingValues = params;
            
            
            shapedParameter=
            shapingMethod=
            shapingValues=
            
            
    t.shapingMethod = 'exponentialParameterAtConstantPerformance'
    params.performanceLevel = 0.75;
    params.startValue = 0.2;
    params.currentValue = params.startValue;
    params.goalValue = 0.1;
    params.tau = 1/4;
    params.fractionalSmoothingWidth = 1/10;
    params.percentCI = 0.95;
    t.shapingValues = params;
    t.positionalHint = t.shapingValues.currentValue; % set the shaped parameter to start value

    t.shapingMethod = 'geometricRatioAtCriteria'
    params.ratio = 4/5;
    params.performanceLevel = 0.75;
    params.numTrials = [100];
    params.startValue = 0.2;
    params.currentValue = params.startValue;
    params.goalValue = 0.1;
    params.fractionalParameterThreshold = 0.05;
    t.shapingValues = params;
    t.positionalHint = t.shapingValues.currentValue;

    t.shapingMethod = 'linearChangeAtCriteria'
    params.numSteps = 6;
    params.performanceLevel = 0.75;
    params.numTrials = [100];
    params.startValue = 0.2;
    params.currentValue = params.startValue;
    params.goalValue = 0.1;
    t.shapingValues = params;
    t.positionalHint = t.shapingValues.currentValue;


end
