function out = checkPorts(tm,targetPorts,distractorPorts)

if isempty(targetPorts) && isempty(distractorPorts)
    error('targetPorts and distractorPorts cannot both be empty in cuedGoNoGo');
end

out=true;

end % end function