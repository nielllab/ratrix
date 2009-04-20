function checkNafcTargets(targetIsRight,targetPorts,distractorPorts,numPorts)
%assumes left port is lowest num, right is highest, and left/right are only choices.  how verify this or make it dynamic?
if numPorts<2
    error('requires at least 2 ports')
end
if iscell(targetPorts) && iscell(distractorPorts) % old-style target/distractor ports as cell arrays
    if all(cellfun(@isscalar,targetPorts)) && all(cellfun(@isscalar,distractorPorts))
        % convert to arrays as before
        targetPorts=cell2mat(targetPorts);
        distractorPorts=cell2mat(distractorPorts);
    else
        error('currently only works with scalar targets and distractors')
    end
else % new-style decimal representation
    % convert to old binary representation
    targetPorts=convertDecimalToIndPorts(targetPorts,numPorts);
    distractorPorts=convertDecimalToIndPorts(distractorPorts,numPorts);
end

if isvector(targetPorts) && isvector(distractorPorts) && length(targetPorts)==length(distractorPorts)
    targets(targetIsRight)=max(1:numPorts);
    targets(~targetIsRight)=min(1:numPorts);
    if ~all(targets==targetPorts)
        error('bad targets')
    end
    distractors(targetIsRight)=min(1:numPorts);
    distractors(~targetIsRight)=max(1:numPorts);
    if ~all(distractors==distractorPorts)
        error('bad distractors')
    end
else
    error('number of targets and distractors do not match')
end
end