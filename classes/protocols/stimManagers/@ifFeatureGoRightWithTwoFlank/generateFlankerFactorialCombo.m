function combinations=generateFlankerFactorialCombo(sm,sweptParameters,mode,parameters)
%this helper function is a wrapper for factorial combo and handles the
%logic of the mapping between stimulus manager fields and
%this function only uses the values in parameters and ignores 

if exist('parameters','var')
    %use parameters to generate values
else
    parameters=struct(sm);
    error('never used before');
    %make sure to compare and validate with respect to default parameters
end

% include all contrasts and orientations whether or not they're from goLeft
% or goRight, this reasoning makes sense for all protocolTypes
% 'goToRightDetection', 'goToLeftDetection','tiltDiscrim','goToSide'

for i=1:length(sweptParameters)
    switch sweptParameters{i}
        case 'targetContrast'
            parameters.targetContrast=unique([parameters.goRightContrast parameters.goLeftContrast]);
            %only includes zero contrast if exist in both sides
            if ~(any(parameters.goRightContrast==0) & any(parameters.goLeftContrast==0))
                parameters.targetContrast(parameters.targetContrast==0)=[];
            end
        case 'targetOrientations'
            parameters.targetOrientations=unique([parameters.goRightOrientations parameters.goLeftOrientations]);
        otherwise
            %add nothing
    end
end

combinations= generateFactorialCombo(parameters, sweptParameters,[],mode);