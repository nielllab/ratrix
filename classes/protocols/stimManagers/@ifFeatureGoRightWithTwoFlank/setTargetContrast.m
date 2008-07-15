function t=setTargetContrast(t, targetContrast)
switch t.protocolType
    case 'goToSide'
        t.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        t.goLeftContrast =  [targetContrast];
    case 'goToRightDetection'
        t.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        t.goLeftContrast =  [0];
    case 'goToLeftDetection'
        t.goRightContrast = [0];    %choose a random contrast from this list each trial
        t.goLeftContrast =  [targetContrast];
    case 'tiltDiscrim'
        t.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        t.goLeftContrast =  [targetContrast];
    otherwise
        protocolType=t.protocolType
        error('unknown type of protocol requested')
end
