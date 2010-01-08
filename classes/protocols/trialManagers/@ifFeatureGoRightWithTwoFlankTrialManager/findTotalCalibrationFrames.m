function [totalFrames] = findTotalCalibrationFrames(t)

numTargetOrientations = size(t.goRightOrientations,2);
numTargetPhases = size(t.phase,2);
numFlankerOrientations=size(t.flankerOrientations,2);
numFlankerPhases = size(t.phase,2);

%         numTargetContrast=size(t.goRightContrast,2);
%         numFlankerContrast=size(t.flankerContrast,2);
%         numFlankerOffset=size(t.flankerOffset,2);
switch t.calib.method
    case 'sweepAllPhasesPerFlankTargetContext'
        %totalFrames=numPhases*numFlankerOrientations*numTargetOrientations; %totalFrames=numf*numT*numP;
        totalFrames = numTargetOrientations*numTargetPhases*numFlankerOrientations*numFlankerPhases;
        trialManager.calib.orientations= numTargetOrientations; %was: unique([goRight goLeft flank]); what is suppose to be placed here?
    case 'sweepAllPhasesPerTargetOrientation'
        totalFrames=numTargetPhases*numTargetOrientations;
        trialManager.calib.orientations=t.goRightOrientations;
    case 'sweepAllPhasesPerPossibleOrientation'
        % toDo:
        %numTargetOrientations=length(trialManager.calib.orientations!)
        %unique([goRight goLeft flank distr])
    case 'sweepAllContrastsPerPhase'
    otherwise
        err('Not a valid method.');
end
