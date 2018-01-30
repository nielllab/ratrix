close all; clear all
batchPhilIntactSkull %select batch file

%select which subset of animals to use
use = find(strcmp({files.notes},'topo only') &...
    strcmp({files.inject},'doi') &...
    strcmp({files.timing},'post') &...
    strcmp({files.training},'trained'))
sprintf('%d experiments for individual analysis',length(use))

alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography

for s=1:1 %needed for doTopography
    doTopography; %%%align across animals second
end

save('DOI_Trained_Post')