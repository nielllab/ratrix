function    [parameterChanged, t]  = shapeParameter(t, trialRecords)

parameterChanged = 0;

%% doShape

switch  t.shapingMethod
    case 'exponentialParameterAtConstantPerformance'
        error('code not written yet, will be completed when Yuan returns next year after the 2nd of January');
    case 'geometricRatioAtCriteria'
        error('code not written yet, will be completed when Yuan returns');
    case 'linearChangeAtCriteria'

        if ~isempty(trialRecords)
            %select appropriate trials for shaping
            stimDetails=[trialRecords.stimDetails];
            thisParameter=strcmp({stimDetails.shapedParameter},stimDetails(end).shapedParameter);
            thisValue=([stimDetails.currentShapedValue]==stimDetails(end).currentShapedValue);
            uncorrelated=~[stimDetails.correctionTrial] & ~[stimDetails.maxCorrectForceSwitch];
            whichTrials=thisParameter&thisValue&uncorrelated;
            trialRecords=trialRecords(whichTrials);
        end

        [aboveThresh ]=aboveThresholdPerformance(t.shapingValues.numTrials, t.shapingValues.performanceLevel, trialRecords);
        
        if aboveThresh
            delta = (t.shapingValues.goalValue-t.shapingValues.startValue)/double(t.shapingValues.numSteps);
            t.shapingValues.currentValue = t.shapingValues.currentValue + delta;
            parameterChanged = 1;
            % if parameter has reached its goal or has exceeded it
            % ...depends on currentValue never moving away from the goalValue
            % current == start | sign(current - goal) == sign(current - start)
            %if  t.shapingValues.currentValue == t.shapingValues.goalValue |sign(t.shapingValues.currentValue - t.shapingValues.goalValue) == sign(t.shapingValues.currentValue - t.shapingValues.goalValue)
            % force graduation to the next step
            % how should we do this? need to influence graduation in the
            % trainingStep ...
            %end
            %instead use a criteria that checks the parameter in question:
            %parameterThresholdCriterion('.stimDetails.targetContrast','<',0.1)
        end
    otherwise
        error('not an acceptable shaping method');
end

%% set value

if parameterChanged
    switch t.shapedParameter
        case 'positionalHint'
            t.positinalHint = t.shapingValues.currentValue;
        case 'stdGaussianMask'
            t.stdGaussMask = t.shapingValues.currentValue;
        case 'targetContrast'
            t.targetContrast = t.shapingValues.currentValue;
        case 'flankerContrast'
            t.flankerContrast = t.shapingValues.currentValue;
        otherwise
            error('that parameter cannot be shaped');
    end
else
    newTM=0;
end

%move to quickloop, error check it
if 0



    parameters.shapedParameter='flankerContrast';
    parameters.shapingMethod='linearChangeAtCriteria';
    parameters.shapingValues.numSteps=int8(9);
    parameters.shapingValues.performanceLevel=[0.9];
    parameters.shapingValues.numTrials=int8([2]);
    parameters.shapingValues.startValue=0.1;
    parameters.shapingValues.currentValue=0.1;
    parameters.shapingValues.goalValue=1;


    %     params.numSteps = 6;
    %     params.performanceLevel = 0.75;
    %     params.numTrials = [100];
    %     params.startValue = 0.2;
    %     params.currentValue = params.startValue;
    %     params.goalValue = 0.1;
    %     t.shapingValues = params;
    %     shapedParameter=
    %     shapingMethod=
    %     shapingValues=


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
