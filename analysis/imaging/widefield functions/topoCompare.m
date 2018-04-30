close all; clear all; dbstop if error;

batchKristenBehavior %select batch file
% batchPhilIntactSkull %select batch file

% grpname = 'LGN_hM4D_pre' %name your group

%%select which subset of animals to use

% use = find(strcmp({files.notes},'topo only') &...
%     strcmp({files.cond},'CNO') &...
%     strcmp({files.dose},'10') &...
%     strcmp({files.dreadds},'lgn') &...
%     strcmp({files.timing},'pre')); 
% sprintf('%d experiments for individual analysis',length(use))

%%select which subset of animals to use

use = find(strcmp({files.notes},'topo only') &...
    strcmp({files.cond},'CNO') &...
    strcmp({files.dose},'10') &...
    strcmp({files.dreadds},'lgn') &...
    strcmp({files.timing},'post')); 
sprintf('%d experiments for individual analysis',length(use))

%%for phil?:

% use = find(strcmp({files.notes},'topo only') &...
%     strcmp({files.inject},'doi') &...
%     strcmp({files.timing},'post') &...
%     strcmp({files.training},'trained'))
% sprintf('%d experiments for individual analysis',length(use))

alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography

for s=1:1 %needed for doTopography
    doTopography; %%%align across animals
end



% save(grpname)