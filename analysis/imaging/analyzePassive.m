close all
clear all
warning off
%batchPassive2015;
%batchTopography
% batchDOI0722
%batchTopoFrontiers
batchMandiEnrichment

psfilename = 'D:\Mandi\tempWF.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

   alluse = find(strcmp({files.rignum},'rig2') & strcmp({files.notes},'good imaging session')) 
  
length(alluse)
% alluse=alluse(1:5)
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

x0 =0; y0=0; sz = 128;
doTopography;

disp('doing 3x2y')
rep=2;
doGratingsNew;
disp('doing 4x3y')
rep=4;
doGratingsNew;

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
sessiondata = files(alluse);

if f~=0
    save(fullfile(p,f),'allsubj','sessiondata','shiftData','fit','mnfit','cycavg');
end

try
    dos(['ps2pdf ' psfilename ' "' [f '.pdf'] '"'])
catch
    display('couldnt generate pdf');
end

delete(psfilename);
