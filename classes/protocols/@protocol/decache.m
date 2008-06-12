function p=decache(p)
    for i=1:length(p.trainingSteps)
        p.trainingSteps{i}=decache(p.trainingSteps{i});
    end