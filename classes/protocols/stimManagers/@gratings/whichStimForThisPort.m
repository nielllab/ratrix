function stimStruct=whichStimForThisPort(s,stimStruct,targetPorts,responsePorts)

if ~all(ismember(targetPorts,[1 3]))
    error('currently hard codded to support left and right with 2 possible ports : [1 or 3]')
end

switch targetPorts
    case 1
        %do nothing
    case 3
        %rotate the orientation by 180 deg
        stimStruct.orientations=stimStruct.orientations+pi;
    otherwise
        error('unsupported port')
end

%CONSIDERED MORE GENERAL CODE TO US THE FIRST N ORIENTS FOR LEFT
%AND N+1:2N for RIGHT, HOWEVER, this fights with the currnt error checking
%for doCombos=false, which requires the same # orients as all other params
%future coding could consider special casing orientations somehow... seems
%ugly
%
%numPorts=2;
%numOrients=length(s.orientations);
%numOrientsPerPort=numOrients/numPorts;%

%HERE IS WHERE A SINGLE PARAM WOULD BE SELECTED FROM EACH OF THE OPTIONS
%featuresActive={'contrasts','pixPerCycs','driftfrequencies','radii'}
%for i=1:length(featuresActive)
% choose one from the available ones
% stimStruct.(featuresActive{i})=s.(featuresActive{i})(randi(length(xxx)))
%end
end