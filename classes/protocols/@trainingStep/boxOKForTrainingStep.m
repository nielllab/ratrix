function ok=boxOKForTrainingStep(t,b,r)
if isa(b,'box') && isa(r,'ratrix')
    ok=boxOKForTrialManager(t.trialManager,b,r);
else
    error('need a box and a ratrix')
end