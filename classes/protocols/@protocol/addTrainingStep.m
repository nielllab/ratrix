function p=addTrainingStep(p,ts)
if isa(ts,'trainingStep')
    p.trainingSteps{end+1}=ts;
else
    error('need a training step');
end