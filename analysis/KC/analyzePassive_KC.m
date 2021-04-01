%% analyzePassive

close all
clear all
warning off

batchNEW_KC
cd(pathname)

%%%select the fields that you want to filter on

alluse = find(strcmp({files.subj},'G6H277RT')...
      & strcmp({files.expt},'031121'))
   
% alluse = find(strcmp({files.virus},'CAV2-cre_cre-hM4Di')... 
%     & strcmp({files.genotype},'camk2 gc6')...
%     & strcmp({files.inject},'CLOZ')... 
%     & strcmp({files.monitor},'land')...
%     & strcmp({files.timing},'pre')...
%     & strcmp({files.moviename4x3y},'C:\grating4x3y5sf3tf_short011315.mat'))

% alluse = find(strcmp({files.virus},'caspase3')... 
%     & strcmp({files.genotype},'calb2cre-ck2-gc6')...
%     & strcmp({files.inject},'none')... 
%     & strcmp({files.monitor},'land')...
%     & strcmp({files.timing},'post')...
%     & strcmp({files.moviename4x3y},'C:\grating4x3y5sf3tf_short011315.mat'))

% alluse = find(strcmp({files.virus},'CAV2-cre_cre-hM4Di')... 
%     & strcmp({files.inject},'CLOZ')... 
%     & strcmp({files.monitor},'land')...
%     & strcmp({files.timing},'post')...
%     & strcmp({files.area}, 'LP')...
%     & strcmp({files.genotype},'camk2 gc6')...
%     & strcmp({files.moviename4x3y},'C:\grating4x3y5sf3tf_short011315.mat'))
    

% files(n).moviename = 'C:\grating4x3y5sf3tf_short011315.mat'

%%uncomment this for individual mouse
savename = ['G6H277RT_031121_anPassive']

%%%uncomment this for group
% savename = ['203RT_cloz_post.mat']
% files(alluse(1)).subj '_' files(alluse(1)).timing '_' files(alluse(1)).virus '_' ...
%    files(alluse(1)).genotype '_' files(alluse(1)).inject 


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
% disp('doing 3x2y')
% rep=2;
% doGratingsNew;

% %%% UNCOMMENT FOR 4X3Y
% disp('doing 4x3y')
% rep=4;
% doGratingsNew;

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

% for just doTopography

disp('saving data')
try
    save(fullfile(pathname,savename),'allsubj','tuningall','sftcourse','trialcycavgRunAll','trialcycavgSitAll','-v7.3');
catch
    save(fullfile(pathname,savename),'allsubj','-v7.3');
end

% for grating analysis, which includes shift data, fit, mnfit

% disp('saving data')
% try
%     save(fullfile(pathname,savename),'allsubj','shiftData','fit','mnfit','cycavg','tuningall','sftcourse','trialcycavgRunAll','trialcycavgSitAll','-v7.3');
% catch
%     save(fullfile(pathname,savename),'allsubj','shiftData','fit','mnfit','cycavg','-v7.3');
% end

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


