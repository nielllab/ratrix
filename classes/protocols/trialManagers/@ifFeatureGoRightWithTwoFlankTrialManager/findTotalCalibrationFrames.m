function [totalFrames] = findTotalCalibrationFrames(t)

numTargetOrientations = size(t.goRightOrientations,2);  
numPhases = size(t.phase,2);

numFlankerOrientations=size(t.flankerOrientations,2);
%         numTargetContrast=size(t.goRightContrast,2);      
%         numFlankerContrast=size(t.flankerContrast,2);
%         numFlankerOffset=size(t.flankerOffset,2);
switch t.calib.method
    case 'sweepAllPhasesPerFlankTargetContext'
        totalFrames=numPhases*numFlankerOrientations*numTargetOrientations; %totalFrames=numf*numT*numP; 
        trialManager.calib.orientations=unique([goRight goLeft flank])
    case 'sweepAllPhasesPerTargetOrientation'
        totalFrames=numPhases*numTargetOrientations;
        trialManager.calib.orientations=t.goRightOrientations
    case 'sweepAllPhasesPerPossibleOrientation'
        % toDo: 
        %numTargetOrientations=length(trialManager.calib.orientations!)
        %unique([goRight goLeft flank distr])
    case 'sweepAllContrastsPerPhase'
    otherwise
        err('Not a valid method.')
end
