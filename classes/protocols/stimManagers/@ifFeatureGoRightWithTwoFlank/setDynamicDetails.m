function stimDetails=setDynamicDetails(s,stimDetails,sweptID);
%updates the value in stim details and recomputes, and updates relevant fields

%init
doSpatialUpdate=false;

for i=1:length(s.dynamicSweep.sweptParameters)
    param=s.dynamicSweep.sweptParameters{i};
    value=s.dynamicSweep.sweptValues(i,sweptID);
    switch s.dynamicSweep.sweptParameters{i}
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
        otherwise
            error(sprintf('bad param: %s',param))
    end

end

if doSpatialUpdate
    stimDetails=computeSpatialDetails(s,stimDetails);
end