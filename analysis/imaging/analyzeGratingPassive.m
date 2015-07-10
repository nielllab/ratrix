

clear all
%batchPassive2015;
%batchTopography
%batchSpont
batchSFtest

close all

for f = 1:length(files);
    if ~isempty(files(f).behavstim3x4orient)  
        hasgratings(f)=1;
    else
        hasgratings(f)=0;
    end
end

 %alluse = find(strcmp({files.monitor},'vert') &  strcmp({files.notes},'good imaging session') & hasgratings ) 
 %alluse = 1:length(files) & ~strcmp({files.subj},'g62b7lt');
  %alluse = find( strcmp({files.notes},'good imaging session') & hasgratings & strcmp({files.doi},'post')) 
  %alluse = find( strcmp({files.notes},'good imaging session') & hasgratings & strcmp({files.subj},'g62l8rn')) 

  alluse = find(  strcmp({files.notes},'good imaging session')  )  
  % alluse = find(  strcmp({files.notes},'good imaging session') &strcmp({files.subj},'g62l10rt') ) 
   % alluse = find(  strcmp({files.notes},'good imaging session') &strcmp({files.subj},'g62n1ln') )
  %    alluse = find(  strcmp({files.notes},'good imaging session') &strcmp({files.subj},'g62l8rn') )
      
  length(alluse)
%alluse=alluse(end-5:end);
allsubj = unique({files(alluse).subj})



%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    

%%% use this one to average all sessions that meet criteria
for s=1:1
use = alluse;

allsubj{s}

%%% calculate gradients and regions
clear map merge
x0 =10; y0=30; sz = 120;
x0 =0; y0=0; sz = 128;
doTopography;
%doCorrelationMap
doGratingsBehav;
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


