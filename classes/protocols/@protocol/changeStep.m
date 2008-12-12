function protocol = changeStep(protocol, ts, stepNumToChange)

if isscalar(stepNumToChange) && isinteger(stepNumToChange) && stepNumToChange>0 && stepNumToChange<=length(protocol.trainingSteps) && isa(ts,'trainingStep')
    protocol.trainingSteps{stepNumToChange} = ts;
else
    error('stepNumToChange must be scalar integer >0 and <= number of defined trainingSteps, or ts is not a valid trainingStep');
end

end % end function
