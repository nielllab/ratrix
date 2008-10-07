function validateStimSpecs(trialManager, stimSpecs, totalPorts)

% This function does error-checking and validation for the cell array stimSpecs (each element is a stimSpec object)
% beyond the basic validation performed in calcStim

for i=1:length(stimSpecs)
    validated = true; % start at true, and make false if anything fails
    spec = stimSpecs{i};
    
    % for each stimSpec, check each field
    
    % stimulus
    stim = getStim(spec);
    if ~isnumeric(stim)
        validated=false;
    end
    
    % criterion and framesUntilTransition
    % check that there is a way to leave this phase
    criterion = getCriterion(spec);
    timeout = getFramesUntilTransition(spec);
    if isempty(criterion) && isempty(timeout)
        validated=false;
    end
    % check that criterion has valid ports and targets (between 1 and number of ports/phases that exist)
    for j=1:2:length(criterion)-1
        portSet = criterion{j};
        targetSet = criterion{j+1};
        if any(portSet > totalPorts) || any(portSet < 1)
            validated=false;
        elseif any(targetSet > length(stimSpecs)) || any(targetSet < 1)
            validated=false;
        end
    end
    
    % stimType - must be loop, trigger, static, cache, expert, dynamic, indexedFrames, or timedFrames
    % this is already done in the constructor - SKIP FOR NOW
    
end

if ~validated
    error('failed to validate stimSpecs');
end

    
    