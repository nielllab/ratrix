function d=display(p)
    d=['protocol ' p.id ': ' num2str(length(p.trainingSteps)) ' steps'];
    for i=1:length(p.trainingSteps)
        d=[d '\n\ttraining step ' num2str(i) ':\n' display(p.trainingSteps{i})];
    end
    d=sprintf(d);