%batchBehavNew;
batchPassive
close all

 %alluse = find(strcmp({files.monitor},'vert')&  strcmp({files.notes},'good imaging session')  &    strcmp({files.label},'camk2 gc6') &  strcmp({files.task},'HvV_center') &strcmp({files.spatialfreq},'100')) %% & ~strcmp({files.subj},'g62b7lt')) 
 alluse = 2:length(files);
 length(alluse)
 allsubj = unique({files(alluse).subj})




%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    
for s=1:1
use = alluse;

allsubj{s}

%%% calculate gradients and regions
clear map merge
x0 =10; y0=30; sz = 120;
x0 =0; y0=0; sz = 128;
doTopography;

keyboard

save('D:/referenceMap.mat','avgmap4d','files');


% %%% overlay behavior on top of topomaps
doBehavior;
alldata{s} = avgbehavCond;

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
[f p] = uiputfile('*.mat','save data?');
if f~=0
    save(fullfile(p,f),'allsubj','alldata');
end


