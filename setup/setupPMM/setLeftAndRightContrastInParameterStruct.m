function parameters=setLeftAndRightContrastInParameterStruct(parameters, protocolType, targetContrast)
switch protocolType
    case 'goToSide'
        parameters.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [targetContrast];
    case {'goToRightDetection','goNoGo','cuedGoNoGo'}
        parameters.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [0];
    case 'goToLeftDetection'
        parameters.goRightContrast = [0];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [targetContrast];
    case 'tiltDiscrim'
        parameters.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [targetContrast];
    otherwise
        protocolType=protocolType
        error('unknown type of protocol requested')
end

