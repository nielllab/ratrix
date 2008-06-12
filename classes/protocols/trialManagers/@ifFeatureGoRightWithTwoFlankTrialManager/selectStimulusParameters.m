function  [a b c z d e f g h p pD pF] = selectStimulusParameters(t)

frameInd=t.calib.frame; % total numer of possible images with the given method
numTargetOrientations = size(t.goRightOrientations,2);
numPhases = size(t.phase,2);

%         numFlankerOrientations=size(stimulus.flankerOrientations,2);
%         numTargetContrast=size(stimulus.goRightContrast,2);      
%         numFlankerContrast=size(stimulus.flankerContrast,2);
%         numFlankerOffset=size(stimulus.flankerOffset,2);
t.calib.method
switch t.calib.method
    
    case 'sweepAllPhasesPerFlankTargetContext'
       a = ceil(frameInd/(numPhases*numTargetOrientations));
    case 'sweepAllPhasesPerTargetOrientation'
       c=1; z=1; d=1; e=1; f=1; h=1; g=1; pD=1; pF=1;
       
       if any([t.flankerContrast~=0 t.flankerContrast~=0  t.flankerContrast~=0])
           error ('flanker, distractor or flankerDistractor will be drawn on the screen, but shouldn''t')
       end

       a = ceil(frameInd/numPhases);
       b = ceil(frameInd/numPhases);
       p = mod(frameInd,numPhases);
       
       if p==0
           p = numPhases;
       end
           
       
    case 'sweepAllContrastsPerPhase'
    otherwise 
        error('unknown calibration method');
end




