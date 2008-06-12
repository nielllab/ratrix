function ok=boxOKForProtocol(p,b,r)
if isa(b,'box') && isa(r,'ratrix')
    ok=1;
    for i=1:length(p.trainingSteps)
        ok=ok && boxOKForTrainingStep(p.trainingSteps{i},b,r);

    end
else
    error('need a box and a ratrix')
end