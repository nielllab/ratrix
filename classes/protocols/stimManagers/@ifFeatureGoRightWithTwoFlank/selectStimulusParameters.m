function  [details a b c z d e f g h p pD pF m x fpa frto frfo] = selectStimulusParameters(stimulus,trialRecords,details)

%set variables for random selections
a=Randi(size(stimulus.goRightOrientations,2));
b=Randi(size(stimulus.goLeftOrientations,2));
c=Randi(size(stimulus.flankerOrientations,2));
z=Randi(size(stimulus.distractorOrientations,2));
d=Randi(size(stimulus.goRightContrast,2));
e=Randi(size(stimulus.goLeftContrast,2));
f=Randi(size(stimulus.flankerContrast,2));
g=Randi(size(stimulus.distractorContrast,2));
h=Randi(size(stimulus.flankerOffset,2));
p=Randi(size(stimulus.phase,2));
pD=Randi(size(stimulus.phase,2));
pF=Randi(size(stimulus.phase,2));
m=Randi(size(stimulus.stdGaussMask,2));
x=Randi(size(stimulus.pixPerCycs,2));
fpa=Randi(size(stimulus.flankerPosAngle,2));
frto=Randi(size(stimulus.fpaRelativeTargetOrientation,2));
frfo=Randi(size(stimulus.fpaRelativeFlankerOrientation,2));

if ~isempty(stimulus.blocking)
    [details setValues]=setBlockedDetails(stimulus,trialRecords,details);

    for i=1:length(setValues)
        switch stimulus.blocking.sweptParameters{i}
            case 'targetOrientations';
                switch stimulus.protocolType
                    case {'goToRightDetection'}
                        a=find(stimulus.goRightOrientations==setValues(i));
                        b=find(stimulus.goLeftOrientations==setValues(i));
                        %USED TO b=allow random it's 0 contrast
                    case 'goToLeftDetection'
                        %a=allow random it's 0 contrast
                        a=find(stimulus.goRightOrientations==setValues(i));
                        b=find(stimulus.goLeftOrientations==setValues(i));
                    case {'goToSide'}
                        a=find(stimulus.goRightOrientations==setValues(i));
                        b=find(stimulus.goLeftOrientations==setValues(i));
                    case {'tiltDiscrim'}
                        error('don''t block orientations in tilt discrim')
                    otherwise
                        error('unvalidated blocking with this type')
                end
            case 'targetContrast';
                switch stimulus.protocolType
                    case {'goToRightDetection'}
                        d=find(stimulus.goRightContrast==setValues(i));
                        %e=allow random it's 0 contrast
                    case 'goToLeftDetection'
                        %d=allow random it's 0 contrast
                        e=find(stimulus.goLeftContrast==setValues(i));
                    case {'goToSide','tiltDiscrim'}
                        d=find(stimulus.goRightContrast==setValues(i));
                        e=find(stimulus.goLeftContrast==setValues(i));
                    otherwise
                        error('unvalidated blocking with this type')
                end
            case 'flankerOn'
                details.flankerOnOff(1)=setValues(i);
            case 'flankerOff'
                details.flankerOnOff(2)=setValues(i);
            case 'flankerOrientations';             c=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'distractorOrientations';          z=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'flankerContrast';                 f=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'distractorContrast';              g=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'flankerOffset';                   h=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'targetPhase';                     p =find(stimulus.phase==setValues(i));
            case 'flankerPhase';                    pF=find(stimulus.phase==setValues(i));
            case 'distractorPhase';                 pD=find(stimulus.phase==setValues(i));
            case 'stdGaussMask';                    m=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'pixPerCycs';                      x=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'flankerPosAngle';                 fpa=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'fpaRelativeTargetOrientation';    frto=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            case 'fpaRelativeFlankerOrientation';   frfo=find(stimulus.(stimulus.blocking.sweptParameters{i})==setValues(i));
            otherwise
                stimulus.blocking.sweptParameters{i}
                error('not handled yet')
        end
    end
end

if isempty(a) || isempty(b) || isempty(c) || isempty(z) || isempty(d)...
        || isempty(e) || isempty(f) || isempty(g) || isempty(h) || isempty(p)...
        || isempty(pD) || isempty(pF) || isempty(m) || isempty(x)...
        || isempty(fpa) || isempty(frto) || isempty(frfo)
    keyboard
    stimulus
    stimulus.blocking
    stimulus.blocking.sweptValues
    error('empty parameter index! suggests that a requested block value is undefined in the stim')
end

details.blocking=stimulus.blocking;


% %frameInd=t.calib.frame; % total numer of possible images with the given method
% % frameInd=3;
% % method='sweepAllPhasesPerTargetOrientation'
% %
% % numTargetOrientations = size(s.goRightOrientations,2);
% % numTargetPhases = size(s.phase,2);
% % numFlankerOrientations=size(s.flankerOrientations,2);
% % numFlankerPhases = size(s.phase,2);
%
% %         numFlankerOrientations=size(stimulus.flankerOrientations,2);
% %         numTargetContrast=size(stimulus.goRightContrast,2);
% %         numFlankerContrast=size(stimulus.flankerContrast,2);
% %         numFlankerOffset=size(stimulus.flankerOffset,2);
%
% %             a=Randi(size(t.goRightOrientations,2));
% %             b=Randi(size(t.goLeftOrientations,2));
% %             c=Randi(size(t.flankerOrientations,2));
% %             z=Randi(size(t.distractorOrientations,2));
% %             d=Randi(size(t.goRightContrast,2));      %
% %             e=Randi(size(t.goLeftContrast,2));
% %             f=Randi(size(t.flankerContrast,2));
% %             g=Randi(size(t.distractorContrast,2));
% %             h=Randi(size(t.flankerOffset,2));
% %             p=Randi(size(t.phase,2));
% %             pD=Randi(size(t.phase,2));
% %             pF=Randi(size(t.phase,2));
%
%
% switch method %t.calib.method
%
%     case 'sweepAllPhasesPerFlankTargetContext'
%        %a = ceil(frameInd/(numPhases*numTargetOrientations));
%
%        p = mod(frameInd-1, numTargetPhases)+1; % outputs [1:16 1:16 1:16 ...] TargetPhase index
%        a = ceil((mod(frameInd-1, numTargetOrientations*numTargetPhases)+1)/numTargetPhases); % TargetOrientation index
%        c = ceil((mod(frameInd-1, numTargetOrientations*numTargetPhases*numFlankerOrientations)+1)/(numTargetPhases*numTargetOrientations)); % FlankerOrientation index
%        d = 1;
%        f = 1;
%        h = 1;
%        pF = ceil((mod(frameInd-1, numTargetOrientations*numTargetPhases*numFlankerOrientations*numFlankerPhases)+1)/(numTargetPhases*numTargetOrientations*numFlankerOrientations)); %FlankerPhase index
%        x = 1; %pixPerCycs (ADD TO TM)
%
%        z = 1;	g = 1;	pD = 1;  % Distractor Terms
%        b = a;	e = d;   % GoLeft Terms
%        m = 1; %mask sizes (ADD TO TM)
%     case 'sweepAllPhasesPerTargetOrientation'
%        c=1; z=1; d=1; e=1; f=1; h=1; g=1; pD=1; pF=1; m=1; x=1;
%
% %        if any([t.flankerContrast~=0 t.flankerContrast~=0  t.flankerContrast~=0])
% %            error ('flanker, distractor or flankerDistractor will be drawn on the screen, but shouldn''t')
% %        end
%
%        a = ceil(frameInd/numTargetPhases);
%        b = ceil(frameInd/numTargetPhases);
%        p = mod(frameInd,numTargetPhases);
%
%        if p==0
%            p = numTargetPhases;
%        end
%
%
%     case 'sweepAllContrastsPerPhase'
%     otherwise
%         error('unknown calibration method');
% end




