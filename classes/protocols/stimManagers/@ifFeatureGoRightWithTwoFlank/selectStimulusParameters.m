function  [a b c z d e f g h p pD pF m x] = selectStimulusParameters(s)

%frameInd=t.calib.frame; % total numer of possible images with the given method
frameInd=3;
method='sweepAllPhasesPerTargetOrientation'

numTargetOrientations = size(s.goRightOrientations,2);
numTargetPhases = size(s.phase,2);
numFlankerOrientations=size(s.flankerOrientations,2);
numFlankerPhases = size(s.phase,2);

%         numFlankerOrientations=size(stimulus.flankerOrientations,2);
%         numTargetContrast=size(stimulus.goRightContrast,2);      
%         numFlankerContrast=size(stimulus.flankerContrast,2);
%         numFlankerOffset=size(stimulus.flankerOffset,2);

%             a=Randi(size(t.goRightOrientations,2));
%             b=Randi(size(t.goLeftOrientations,2));
%             c=Randi(size(t.flankerOrientations,2));
%             z=Randi(size(t.distractorOrientations,2));
%             d=Randi(size(t.goRightContrast,2));      %
%             e=Randi(size(t.goLeftContrast,2));
%             f=Randi(size(t.flankerContrast,2));
%             g=Randi(size(t.distractorContrast,2));
%             h=Randi(size(t.flankerOffset,2));
%             p=Randi(size(t.phase,2));
%             pD=Randi(size(t.phase,2));
%             pF=Randi(size(t.phase,2));


switch method %t.calib.method
    
    case 'sweepAllPhasesPerFlankTargetContext'
       %a = ceil(frameInd/(numPhases*numTargetOrientations));
       
       p = mod(frameInd-1, numTargetPhases)+1; % outputs [1:16 1:16 1:16 ...] TargetPhase index
       a = ceil((mod(frameInd-1, numTargetOrientations*numTargetPhases)+1)/numTargetPhases); % TargetOrientation index
       c = ceil((mod(frameInd-1, numTargetOrientations*numTargetPhases*numFlankerOrientations)+1)/(numTargetPhases*numTargetOrientations)); % FlankerOrientation index
       d = 1;
       f = 1;    
       h = 1;
       pF = ceil((mod(frameInd-1, numTargetOrientations*numTargetPhases*numFlankerOrientations*numFlankerPhases)+1)/(numTargetPhases*numTargetOrientations*numFlankerOrientations)); %FlankerPhase index
       x = 1; %pixPerCycs (ADD TO TM)
       
       z = 1;	g = 1;	pD = 1;  % Distractor Terms
       b = a;	e = d;   % GoLeft Terms
       m = 1; %mask sizes (ADD TO TM)
    case 'sweepAllPhasesPerTargetOrientation'
       c=1; z=1; d=1; e=1; f=1; h=1; g=1; pD=1; pF=1; m=1; x=1;
       
%        if any([t.flankerContrast~=0 t.flankerContrast~=0  t.flankerContrast~=0])
%            error ('flanker, distractor or flankerDistractor will be drawn on the screen, but shouldn''t')
%        end

       a = ceil(frameInd/numTargetPhases);
       b = ceil(frameInd/numTargetPhases);
       p = mod(frameInd,numTargetPhases);
       
       if p==0
           p = numTargetPhases;
       end
           
       
    case 'sweepAllContrastsPerPhase'
    otherwise 
        error('unknown calibration method');
end




