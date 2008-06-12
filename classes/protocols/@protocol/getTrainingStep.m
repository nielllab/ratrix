function out=getTrainingStep(p,i)
    if i<=length(p.trainingSteps)
        out=p.trainingSteps{i};
    else
        error('request for training step with larger index than total number');
    end