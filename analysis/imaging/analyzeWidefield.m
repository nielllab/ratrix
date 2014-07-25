batchBehavNew;
close all

%%% batchDfofMovie



%use = find(strcmp({files.monitor},'vert') &  strcmp({files.notes},'good imaging session') &  strcmp({files.label},'camk2 gc6')&  strcmp({files.task},'HvV_center') &strcmp({files.subj},'g62b7lt'))
%use = find(strcmp({files.monitor},'vert') &  strcmp({files.notes},'good imaging session') )
%use = find(strcmp({files.monitor},'land')&     strcmp({files.label},'camk2 gc6'))

alluse = find(strcmp({files.monitor},'vert')&  strcmp({files.notes},'good imaging session')  &    strcmp({files.label},'camk2 gc6') &  strcmp({files.task},'HvV_center') &strcmp({files.spatialfreq},'100') & strcmp({files.subj},'g62b7lt'))
allsubj = unique({files(alluse).subj})
% alluse = find(strcmp({files.monitor},'vert')&  strcmp({files.notes},'good imaging session')  &    strcmp({files.label},'camk2 gc6')  &strcmp({files.spatialfreq},'100'))
% alluse = alluse(end-38:end)

allsubj = unique({files(alluse).subj})



for s = 1:1
allsubj{s}
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    
use = alluse;

%%% calculate gradients and regions
clear map merge
x0 =10; y0=30; sz = 120;
doTopography;

% %%% overlay behavior on top of topomaps
doBehavior;

% %%% analyze looming
% for f = 1:length(use)
%     loom_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'loom');
% end
% fourPhaseAvg(loom_resp,allxshift+x0,allyshift+y0,allthetashift,zoom, sz, avgmap);


%%% analyze grating
% for f = 1:length(use)
%  f
%  grating_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'grating');
% end
% fourPhaseAvg(grating_resp,allxshift+x0,allyshift+y0, allthetashift,zoom*0.57, sz, avgmap);


end

