%% analyzePassive: choose batch file and filter experiments w/batch file fields, comment/uncomment stimulus-specific analyses below
close all
clear all
warning off

%% pick animals for Kristen

batch4x3y_3x2y_KC %Kris' batch file
cd(pathname)

alluse = find(strcmp({files.controlvirus},'no') & strcmp({files.inject},'CLOZ') & strcmp({files.dose},'1.0 mg_kg')  ...
    & strcmp({files.monitor},'land') & strcmp({files.timing},'post') & strcmp({files.notes},'good data'))  

savename = ['Group_G6H197LT_G6H1511RN_4X3Y_' files(alluse(1)).inject '_' files(alluse(1)).dose '_' files(alluse(1)).timing '.mat']; 

%% pick animals for Mandi

% batchMandiEnrichment %Mandi's batch file
% cd(pathname)
% 
% alluse = find(strcmp({files.condition},'control') & strcmp({files.notes},'good imaging session'))
% 
% savename = ['MS_' files(alluse(1)).condition '.mat'];

%% run doTopography (use this one to average all sessions that meet criteria)
length(alluse)
allsubj = unique({files(alluse).subj})

psfilename = fullfile(pathname,'tempWF.ps'); 
if exist(psfilename,'file')==2;delete(psfilename);end

%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    

for s=1:1
use = alluse;
allsubj{s}

%%% calculate gradients and regions
clear map merge

x0=0; y0=0; sz=128;
doTopography;

%% pick which gratings analysis to run

%%%UNCOMMENT FOR 3X2Y
% disp('doing 4x3y')
% rep=2;
% doGratingsNew;

% %%% UNCOMMENT FOR 4X3Y
disp('doing 4x3y')
rep=4;
doGratingsNew;

%%%UNCOMMENT FOR NATURAL IMAGES
% disp('doing natural images')
% doNaturalImages


% % %%
% % % %%% analyze looming
% % % for f = 1:length(use)
% % %     loom_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'loom');
% % % end
% % % fourPhaseAvg(loom_resp,allxshift+x0,allyshift+y0,allthetashift,zoom, sz, avgmap);
% % 
% % 
% % %%% analyze grating
% % % for f = 1:length(use)
% % %  f
% % %  grating_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'grating');
% % % end
% % % fourPhaseAvg(grating_resp,allxshift+x0,allyshift+y0, allthetashift,zoom*0.57, sz, avgmap);

end

disp('saving data')
try
    save(fullfile(pathname,savename),'allsubj','shiftData','fit','mnfit','cycavg','natimcyc','natimcycavg','allfam','allims','allfiles','-v7.3');
catch
    save(fullfile(pathname,savename),'allsubj','shiftData','fit','mnfit','cycavg','-v7.3');
end
%%%phil note to self- where did sessiondata go/come from and why was it originally
%%%being saved out? removed from save 6/13/19 after error said it didn't
%%%exist

try
    dos(['ps2pdf ' psfilename ' "' [fullfile(pathname,savename(1:end-4)) '.pdf'] '"'])
    delete(psfilename);
catch
    disp('couldnt generate pdf');
    keyboard
end


