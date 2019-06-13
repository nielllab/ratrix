%% analyzePassive
close all
clear all
warning off

%% choose batch file and filter experiments w/batch file fields

batch4x3y_3x2y_KC %Kris' batch file
cd(pathname)
% batchMandiEnrichment %Mandi's batch file

%%%old batch files
%batchPassive2015;
%batchTopography
%batchDOI0722
%batchTopoFrontiers


%pick animals for Kristen 
% & strcmp({files.dose},'1.0 mg/kg')
alluse = find(strcmp({files.controlvirus},'no') & strcmp({files.inject},'CLOZ') & strcmp({files.dose},'2.5 mg/kg')  ...
    & strcmp({files.monitor},'vert') & strcmp({files.timing},'post') & strcmp({files.notes},'good data'))  

%pick animals for Mandi
% alluse = find(strcmp({files.condition},'enriched') & strcmp({files.notes},'good imaging session'))
  
length(alluse)
% alluse=alluse(1:5)
%alluse=alluse(end-5:end);
allsubj = unique({files(alluse).subj})

psfilename = 'F:\Widefield_Analysis\Kristen\tempWF.ps'; 
if exist(psfilename,'file')==2;delete(psfilename);end

% psfilename = 'D:\Mandi\tempWF.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end

%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    

%% run doTopography (use this one to average all sessions that meet criteria)
for s=1:1
use = alluse;

allsubj{s}

%%% calculate gradients and regions
clear map merge

x0 =0; y0=0; sz = 128;
doTopography;

%% pick which gratings analysis to run

%%%uncomment for 3x2y
% disp('doing 3x2y')
% rep=2;
% doGratingsNew;

%%% uncomment for 4x3y
disp('doing 4x3y')
rep=4;
doGratingsNew;

%%%uncomment for natural images movie
disp('doing natural images')
doNaturalImages

%%
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
    dos(['ps2pdf ' psfilename ' "' [fullfile(p,f) '.pdf'] '"'])
catch
    display('couldnt generate pdf');
end

delete(psfilename);
