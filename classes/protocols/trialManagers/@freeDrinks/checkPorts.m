function out = checkPorts(tm,targetPorts,distractorPorts)

if isempty(trialRecords(trialInd).targetPorts) && ~isempty(trialRecords(trialInd).distractorPorts)
    error('cannot have distractor ports without target ports in freeDrinks');
end

out=true;

end % end function