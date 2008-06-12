function t=errorCheck(t,optionalStructure)
%checks the values of the trialMangager if one arg supplied:
%else confirms the values of the parameter structure: but must have the
%correct class as the first arguement because it's a method


%% setup

tm=t; %so that that trialManager specific methods can be called...
if exist('optionalStructure','var')
    t=optionalStructure; %you will be returned with the structure you checked
end

%% confirm that every field is an allowed field
allowedFields = {...
    ...%may migrate
    'maxWidth',...
    'maxHeight',...
    'scaleFactor',...
    'interTrialLuminance',...
    ... %normals
    'goRightOrientations', ...
    'goLeftOrientations', ...
    'flankerOrientations', ...
    'distractorOrientations', ...
    'distractorFlankerOrientations', ...
    'topYokedToBottomFlankerOrientation', ...
    'goRightContrast', ...
    'goLeftContrast', ...
    'flankerContrast', ...
    'distractorContrast', ...
    'distractorFlankerContrast', ...
    'topYokedToBottomFlankerContrast', ...
    'phase', ...
    'flankerYokedToTargetPhase', ...
    'pixPerCycs', ...
    'stdGaussMask', ...
    'stdsPerPatch', ...
    'thresh', ...
    'gratingType', ...
    'gaborNormalizeMethod', ...
    'xPositionPercent', ...
    'targetYPosPct', ...
    'flankerOffset', ...
    'positionalHint', ...
    'xPosNoise', ...
    'yPosNoise', ...
    'cuePercentTargetEcc', ...
    'framesTargetOnOff', ...
    'framesFlankerOnOff', ...
    'typeOfLUT', ...
    'rangeOfMonitorLinearized', ...
    'mean', ...
    'cueLum', ...
    'cueSize', ...
    'displayTargetAndDistractor', ...
    'distractorYokedToTarget', ...
    'distractorFlankerYokedToTargetFlanker', ...
    'fractionNoFlanks', ...
    'toggleStim', ...
    'persistFlankersDuringToggle', ...
    'msPenaltyFlashDuration', ...
    'numPenaltyFlashes', ...
    'maxDiscriminandumSecs', ...
    'advancedOnRequestEnd', ...
    'interTrialDimmingFraction', ...
    'renderMode', ...
    'shapedParameter', ...
    'shapingMethod', ...
    ... %specials
    'shapingValues', ...
    'LUT', ...
    'cache', ...
    'calib', ...
    'stimDetails', ...
    'rm'};

paramFields=fields(t);


if strcmp(class(t),'ifFeatureGoRightWithTwoFlankTrialManager')
    %don't check for the rm which is only a field in the created parameterStructure
    allowedFields(find(strcmp('rm',allowedFields)))=[];

    %do check for the trialManager which is the last field of the blessed object
    allowedFields{end+1}='trialManager';
end

if ~hasAllFieldsInThatOrder(paramFields,allowedFields)
    error ('problem with fields in parameterStructure')
end

%% confirm that all allowed fields have the right values


if ~(isnumeric(t.goRightOrientations))
    error('goRightOrientations must be numeric')
end

if ~(isnumeric(t.goLeftOrientations))
    error('goLeftOrientations must be numeric')
end

if ~(isnumeric(t.flankerOrientations))
    error('flankerOrientations must be numeric')
end

if ~(isnumeric(t.distractorOrientations))
    error('distractorOrientations must be numeric')
end

if ~(isnumeric(t.distractorFlankerOrientations))
    error('distractorFlankerOrientations must be numeric')
end

if ~(isnumeric(t.topYokedToBottomFlankerOrientation))
    error('topYokedToBottomFlankerOrientation must be numeric')
end

if ~(all(t.goRightContrast >= 0 & t.goRightContrast <=1))
    error('goRightContrast must be between 0 and 1')
end

if ~(all(t.goLeftContrast >= 0 & t.goLeftContrast <=1))
    error('goLeftContrast must be between 0 and 1')
end

if ~(all(t.flankerContrast >= 0 & t.flankerContrast <=1))
    error('flankerContrast must be between 0 and 1')
end

if ~(all(t.distractorFlankerContrast >= 0 & t.distractorFlankerContrast <=1))
    error('distractorFlankerContrast must be between 0 and 1')
end

if ~(all(t.topYokedToBottomFlankerContrast >= 0 & t.topYokedToBottomFlankerContrast <=1))
    error('topYokedToBottomFlankerContrast must be between 0 and 1')
end

if ~(all(0<=t.phase) & all(2*pi>=t.phase))
    error('phase must be numeric')
end

if ~((0==t.flankerYokedToTargetPhase) | (1==t.flankerYokedToTargetPhase))
    error('flankerYokedToTargetPhase must be 0 or 1')
end

if ~(all(t.pixPerCycs>0))
    error('pixPerCycs must be greater than 0')
end

if ~(t.stdGaussMask >= 0)
    error('stdGaussMask must be >= 0')
end

if ~(t.stdsPerPatch==4)
    error ('std for patch must be 4')
    %this is an even number that is very reasonable fill of square--has
    %been hardcoded until 8/21/07. Before that, it was always 4. After that
    %always 4.
end

if ~(t.thresh >= 0)
    error('thresh must be >= 0')
end

if ~(t.xPositionPercent >= 0 && t.xPositionPercent<=1)
    error('xPositionPercent must be >= 0 or <=1')
end

if ~(isnumeric(t.targetYPosPct) && t.targetYPosPct >= 0 && t.targetYPosPct<=1)
    error('targetYPosPct must be between 0 and 1 inclusive')
end

if ~(t.flankerOffset >= 0)
    error('flankerOffset must be >=0')
else
    if (t.stdGaussMask == 1/16 && t.flankerOffset> 6)
        error ('flanker may be off screen...remove this error and test it')
    end
end

if ~( 0<=t.positionalHint & t.positionalHint<=1 )
    error('positionalHint must be between 0 and 1 inclusive')
end

if ~(0<=t.xPosNoise)
    error('xPosNoise must be >=0')
end

if ~(0<=t.yPosNoise)
    error('yPosNoise must be >=0')
end

if ~(t.cuePercentTargetEcc >= 0 && t.cuePercentTargetEcc<=1)
    error('cuePercentTargetEcc must be between 0 and 1 inclusive')
end

if ~(strcmp(t.typeOfLUT,'linearizedDefault') || strcmp(t.typeOfLUT,'useThisMonitorsUncorrectedGamma') || strcmp(t.typeOfLUT,'mostRecentLinearized'))
    error('typeOfLUT must be linearizedDefault or useThisMonitorsUncorrectedGamma or mostRecentLinearized')
end

if ~(all(0<=t.rangeOfMonitorLinearized) & all(t.rangeOfMonitorLinearized<=1) & t.rangeOfMonitorLinearized(1)<t.rangeOfMonitorLinearized(2) & size(t.rangeOfMonitorLinearized,1)==1 & size(t.rangeOfMonitorLinearized,2)==2)
    error('rangeOfMonitorLinearized must be greater than or =0 and less than or =1')
end

if ~(t.mean >= 0 && t.mean<=1)
    error('0 <= mean <= 1')
end

if ~(t.cueLum >= 0 && t.cueLum<=1)
    error('0 <= cueLum <= 1')
end

if ~(t.cueSize >= 0 && t.cueSize<=10)
    error('0 <= cueSize <= 10')
end

if ~((0==t.displayTargetAndDistractor|1==t.displayTargetAndDistractor))
    error('displayTargetAndDistractor must be 0 or 1')
end

if ~((0==t.distractorYokedToTarget) | (1==t.distractorYokedToTarget))
    error('distractorYokedToTarget must be 0 or 1')
end

if ~((0==t.distractorFlankerYokedToTargetFlanker) | (1==t.distractorFlankerYokedToTargetFlanker))
    error('distractorFlankerYokedToTargetFlanker must be 0 or 1')
end

if ~(all(t.fractionNoFlanks >= 0 & t.fractionNoFlanks<=1))
    error('0 <= all fractionNoFlanks <= 1')
end

if ~(isnumeric(t.toggleStim))
    error('toggleStim must be logical')
end


if ~((0==t.persistFlankersDuringToggle) | (1==t.persistFlankersDuringToggle));
    error('persistFlankersDuringToggle must be 0 or 1')
end

if ~(any(strcmp(t.gratingType,{'square', 'sine'})))
    error ('gratingType must be square or sine')
end

if ~(strcmp(t.gaborNormalizeMethod,'normalizeVertical'))
    error ('gaborNormalizeMethod must be normalizeVertical')
end

if ~(all(t.framesTargetOnOff > 0) & isinteger(t.framesTargetOnOff) & t.framesTargetOnOff(1)<t.framesTargetOnOff(2) & size(t.framesTargetOnOff,1)==1 & size(t.framesTargetOnOff,2)==2)
    error ('framesTargetOnOff must be positive integers and on before off')
end

if ~(all(t.framesFlankerOnOff > 0) & isinteger(t.framesFlankerOnOff) & t.framesFlankerOnOff(1)<t.framesFlankerOnOff(2) & size(t.framesFlankerOnOff,1)==1 & size(t.framesFlankerOnOff,2)==2)
    error ('framesFlankerOnOff must be positive integers and on before off')
end

if ~(t.msPenaltyFlashDuration > 0)
    error ('msPenaltyFlashDuration must be greater than 0')
end

if ~(t.numPenaltyFlashes>0 & isinteger(t.numPenaltyFlashes))
    error ('numPenaltyFlashes must be an integer greater than 0');
end
   
if ~(t.maxDiscriminandumSecs >= 0)
    error ('maxDiscriminandumSecs must be greater or equal to 0')
end
   
if ~(t.advancedOnRequestEnd == 0 | t.advancedOnRequestEnd ==1)
    error ('advancedOnRequestEnd must be 0 or 1')
end

if ~(all(t.interTrialDimmingFraction >= 0 & t.interTrialDimmingFraction<=1))
    error('0 <= all interTrialDimmingFraction <= 1')
end

if ~(any(strcmp(t.renderMode,{'ratrixGeneral', 'directPTB'})))
    error ('renderMode must be ratrixGeneral or directPTB')
end

if ~(isempty(t.shapedParameter) | any(strcmp(t.shapedParameter,{'positionalHint', 'stdGaussianMask','targetContrast'})))
    error ('shapedParameter must be positionalHint or stdGaussianMask or targetContrast')
end

if ~(isempty(t.shapingMethod) | any(strcmp(t.shapingMethod,{'exponentialParameterAtConstantPerformance', 'geometricRatioAtCriteria','linearChangeAtCriteria'})))
    error ('shapingMethod must be exponentialParameterAtConstantPerformance or geometricRatioAtCriteria or linearChangeAtCriteria')
end


    

%% special fields

if strcmp(class(t),'ifFeatureGoRightWithTwoFlankTrialManager')
    %don't check for the rm which is only a field in the created parameterStructure
    %it's okay stimDetails, calib, LUT or chache are no longer empty postuse

else
    if ~(checkReinforcementManager(tm,t.rm))
        error ('wrong fields in reinforcementManager')
    end

    if ~(isempty(t.stimDetails))
        error ('stimDetails must be empty')
    end

    if ~(isempty(t.calib))
        error ('calib must be empty')
    end

    if ~(isempty(t.LUT))
        error ('LUT must be empty')
    end

    if ~(isempty(t.cache))
        error ('cache must be empty')
    end
    
    if ~isempty(shapingValues) %only check values if a method is selected
     if ~(checkShapingValues(tm,t.shapingMethod,t.shapingValues))
        error ('wrong fields in shapingValues')
     end
    end
     
     
end
%% May Migrate

if ~(all(t.interTrialLuminance >= 0 & t.interTrialLuminance<=1))
    error('0 <= all interTrialLuminance <= 1')
end

if ~(all(t.maxHeight >= 1 & t.maxHeight<=2048) & (double(int16(t.maxHeight))-double(t.maxHeight)==0))
    isint=(double(int16(t.maxHeight))-double(t.maxHeight)==0)
    t.maxHeight
    error('1 <= all maxHeight <= 2048')
end

if ~(all(t.maxWidth >= 1 & t.maxWidth<=2048) & (double(int16(t.maxWidth))-double(t.maxWidth)==0))
    error('1 <= all maxWidth <= 2048')
end

if ~(all(t.scaleFactor >= 1 & t.scaleFactor<=999) & (double(int16(t.scaleFactor))-double(t.scaleFactor)==0))
    error('1 <= all scaleFactor <= 999')
end
