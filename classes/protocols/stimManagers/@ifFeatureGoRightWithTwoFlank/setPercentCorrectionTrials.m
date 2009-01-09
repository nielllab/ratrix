function t=setPercentCorrectionTrials(t, value)

if all(size(value)==[1 1]) && value>=0 && value<=1
    t.percentCorrectionTrials=value;
else
    value=value
    error('percent correction trial must a single number be between 0 and 1')
end
    