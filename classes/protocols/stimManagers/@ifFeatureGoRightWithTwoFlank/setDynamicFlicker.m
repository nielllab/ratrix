function [stimDetails dynamicDetails]=setDynamicFlicker(s,stimDetails,frame,dynamicDetails);
%updates the value in stim details and recomputes, and updates relevant fields

%init
doSpatialUpdate=false;

for i=1:length(s.dynamicFlicker.flickeringParameters)
    param=s.dynamicFlicker.flickeringParameters{i};
    
    switch s.dynamicFlicker.flickerMode
        case 'random'
            value=s.dynamicFlicker.flickeringValues{i}(randi(length(s.dynamicFlicker.flickeringValues{i})));
        otherwise % 'sequence' uses frame
            error('mode not yet supported')
    end
    
    switch param
        case 'targetOrientations'
             stimDetails.targetOrientation=value;
        case 'flankerOrientations'
             stimDetails.flankerOrientation=value;
        case {'flankerOffset'} %fields with same name, update spatial params
            stimDetails.(param)=value;
            doSpatialUpdate=true;
        case 'flankerPosAngle' %set the top flanker
            stimDetails.flankerPosAngles= value + [0 pi];
            doSpatialUpdate=true;
        case {'targetContrast','flankerContrast'}  % is the same in the details is the name in the stim manager and requres no computation
            stimDetails.(param)=value;
        case {'phase'} % all phases yoked together...
            stimDetails.targetPhase=value;
            stimDetails.flankerPhase=value;
            stimDetails.distractorPhase=value;
            stimDetails.distractorFlankerPhase=value;
        otherwise
            error(sprintf('bad param: %s',param))
    end
end

if doSpatialUpdate
    stimDetails=computeSpatialDetails(s,stimDetails);
end