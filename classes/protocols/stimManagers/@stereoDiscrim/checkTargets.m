function checkTargets(sm,leftAmplitude,rightAmplitude,targetPorts,distractorPorts,numPorts)
if ~any(leftAmplitude==rightAmplitude)
    targetIsRight=leftAmplitude<rightAmplitude;
else
    error('left and right amplitude are equal')
end
checkNafcTargets(targetIsRight,targetPorts,distractorPorts,numPorts);