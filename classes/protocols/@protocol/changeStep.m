function protocol = changeStep(protocol, ts, stepNumToChange)

if stepNumToChange<=length(protocol.trainingSteps) && isa(ts,'trainingStep')
    protocol.trainingSteps{stepNumToChange} = ts;
else
    error('stepNumToChange exceeds number of defined trainingSteps, or ts is not a valid trainingStep');
end

end % end function
