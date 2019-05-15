n = 0;

pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
%%  
% pre
% n=n+1;
% files(n).subj = 'G6H115RT'; %animal name
% files(n).expt = '081018'; %date of experiment
% files(n).topox= '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_PRE_TOPOX\081018_G6H115RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_PRE_TOPOX\081018_G6H115RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_PRE_TOPOY\081018_G6H115RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_PRE_TOPOY\081018_G6H115RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_PRE_PATCH\081018_G6H115RT_RIG2_PRE_PATCHmaps.mat';
% files(n).patchonpatchdata = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_PRE_PATCH\081018_G6H115RT_RIG2_PRE_PATCH';
% files(n).inject = 'CNO'; %CNO injection
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lgn';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H115RT'; %animal name
% files(n).expt = '081018'; %date of experiment
% files(n).topox= '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_POST_TOPOX\081018_G6H115RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_POST_TOPOX\081018_G6H115RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_POST_TOPOY\081018_G6H115RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_POST_TOPOY\081018_G6H115RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_POST_PATCH\081018_G6H115RT_RIG2_POST_PATCHmaps.mat';
% files(n).patchonpatchdata = '081018_G6H115RT_RIG2\081018_G6H115RT_RIG2_POST_PATCH\081018_G6H115RT_RIG2_POST_PATCH';
% files(n).inject = 'CNO'; %CNO injection
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lgn';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%% 
% % pre
% n=n+1;
% files(n).subj = 'G6H115LT'; %animal name
% files(n).expt = '081018'; %date of experiment
% files(n).topox= '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_PRE_TOPOX\081018_G6H115LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_PRE_TOPOX\081018_G6H115LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_PRE_TOPOY\081018_G6H115LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_PRE_TOPOY\081018_G6H115LT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_PRE_PATCH\081018_G6H115LT_RIG2_PRE_PATCHmaps.mat';
% files(n).patchonpatchdata = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_PRE_PATCH\081018_G6H115LT_RIG2_PRE_PATCH';
% files(n).inject = 'CNO'; %CNO injection
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lgn';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H115LT'; %animal name
% files(n).expt = '081018'; %date of experiment
% files(n).topox= '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_POST_TOPOX\081018_G6H115LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_POST_TOPOX\081018_G6H115LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_POST_TOPOY\081018_G6H115LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_POST_TOPOY\081018_G6H115LT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_POST_PATCH\081018_G6H115LT_RIG2_POST_PATCHmaps.mat';
% files(n).patchonpatchdata = '081018_G6H115LT_RIG2\081018_G6H115LT_RIG2_POST_PATCH\081018_G6H115LT_RIG2_POST_PATCH';
% files(n).inject = 'CNO'; %CNO injection
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lgn';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%% - START of FALL DATA
% CORRUPT stim obj version
% pre 
% n=n+1;
% files(n).subj = 'G6H119RT'; %animal name
% files(n).expt = '101218'; %date of experiment
% files(n).topox= '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOX_PRE\101218_G6H119RT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
% files(n).topoxdata = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOX_PRE\101218_G6H119RT_RIG2_TOPOX_PRE'; %raw data
% files(n).topoy = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOY_PRE\101218_G6H119RT_RIG2_TOPOY_PREmaps.mat';
% files(n).topoydata = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOY_PRE\101218_G6H119RT_RIG2_TOPOY_PRE';
% files(n).patchonpatch =  '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_PATCHONPATCH_PRE\101218_G6H119RT_RIG2_PATCHONPATCH_PREmaps.mat';
% files(n).patchonpatchdata = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_PATCHONPATCH_PRE\101218_G6H119RT_RIG2_PATCHONPATCH_PRE';
% files(n).inject = 'CLOZ'; 
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H119RT'; %animal name
% files(n).expt = '101218'; %date of experiment
% files(n).topox= '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOX_POST\101218_G6H119RT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
% files(n).topoxdata = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOX_POST\101218_G6H119RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOY_POST\101218_G6H119RT_RIG2_TOPOY_POSTmaps.mat';
% files(n).topoydata = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_TOPOY_POST\101218_G6H119RT_RIG2_TOPOY';
% files(n).patchonpatch =  '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_PATCHONPATCH_POST\101218_G6H119RT_RIG2_PATCHONPATCH_POSTmaps.mat';
% files(n).patchonpatchdata = '101218_G6H119RT_RIG2\101218_G6H119RT_RIG2_PATCHONPATCH_POST\101218_G6H119RT_RIG2_PATCHONPATCH';
% files(n).inject = 'CLOZ'; %CNO injection
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%%  G6H119RT      **********
% USE for GROUP analysis
% pre
% n=n+1;
% files(n).subj = 'G6H119RT'; %animal name
% files(n).expt = '102618'; %date of experiment
% files(n).topox= '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_PRE\102618_G6H119RT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
% files(n).topoxdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_PRE\102618_G6H119RT_RIG2_TOPOX_PRE'; %raw data
% files(n).topoy = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_PRE\102618_G6H119RT_RIG2_TOPOY_PREmaps.mat';
% files(n).topoydata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_PRE\102618_G6H119RT_RIG2_TOPOY_PRE';
% files(n).patchonpatch =  '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_PRE\102618_G6H119RT_RIG2_PATCHONPATCH_PREmaps.mat';
% files(n).patchonpatchdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_PRE\102618_G6H119RT_RIG2_PATCHONPATCH10';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H119RT'; %animal name
% files(n).expt = '102618'; %date of experiment
% files(n).topox= '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_POST\102618_G6H119RT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
% files(n).topoxdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_POST\102618_G6H119RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_POST\102618_G6H119RT_RIG2_TOPOY_POSTmaps.mat';
% files(n).topoydata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_POST\102618_G6H119RT_RIG2_TOPOY';
% files(n).patchonpatch =  '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_POST\102618_G6H119RT_RIG2_PATCHONPATCH_POSTmaps.mat';
% files(n).patchonpatchdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_POST\102618_G6H119RT_RIG2_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data'; 


%%  CONTROL virus
% pre
% n=n+1;
% files(n).subj = 'G6H118RT'; %animal name
% files(n).expt = '103018'; %date of experiment
% files(n).topox= '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_PRE\103018_G6H118RT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
% files(n).topoxdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_PRE\103018_G6H118RT_RIG2_TOPOX_PRE'; %raw data
% files(n).topoy = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_PRE\103018_G6H118RT_RIG2_TOPOY_PREmaps.mat';
% files(n).topoydata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_PRE\103018_G6H118RT_RIG2_TOPOY_PRE';
% files(n).patchonpatch =  '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_PRE\103018_G6H118RT_RIG2_PATCHONPATCH_PREmaps.mat';
% files(n).patchonpatchdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_PRE\103018_G6H118RT_RIG2_PATCHONPATCH_PRE';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'yes'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H118RT'; %animal name
% files(n).expt = '103018'; %date of experiment
% files(n).topox= '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_POST\103018_G6H118RT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
% files(n).topoxdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_POST\103018_G6H118RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_POST\103018_G6H118RT_RIG2_TOPOY_POSTmaps.mat';
% files(n).topoydata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_POST\103018_G6H118RT_RIG2_TOPOY';
% files(n).patchonpatch =  '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_POST\103018_G6H118RT_RIG2_PATCHONPATCH_POSTmaps.mat';
% files(n).patchonpatchdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_POST\103018_G6H118RT_RIG2_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'yes'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data'; 

%%
% BOTCHED EXTRACTION - no sectioning data
% pre
% n=n+1;
% files(n).subj = 'G6H122LT'; %animal name
% files(n).expt = '103018'; %date of experiment -WRONG date
% files(n).topox= '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_PRE\103018_G6H122LT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
% files(n).topoxdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_PRE\103018_G6H122LT_RIG2_TOPOX_PRE'; %raw data
% files(n).topoy = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_PRE\103018_G6H122LT_RIG2_TOPOY_PREmaps.mat';
% files(n).topoydata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_PRE\103018_G6H122LT_RIG2_TOPOY_PRE';
% files(n).patchonpatch =  '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_PRE\103018_G6H122LT_RIG2_PATCHONPATCH10_PREmaps.mat';
% files(n).patchonpatchdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_PRE\103018_G6H122LT_RIG2_PATCHONPATCH10_PRE';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% post
% 
% n=n+1;
% files(n).subj = 'G6H122LT'; %animal name
% files(n).expt = '103018'; %date of experiment
% files(n).topox= '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_POST\103018_G6H122LT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
% files(n).topoxdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_POST\103018_G6H122LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_POST\103018_G6H122LT_RIG2_TOPOY_POSTmaps.mat';
% files(n).topoydata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_POST\103018_G6H122LT_RIG2_TOPOY';
% files(n).patchonpatch =  '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_POST\103018_G6H122LT_RIG2_PATCHONPATCH10_POSTmaps.mat';
% files(n).patchonpatchdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_POST\103018_G6H122LT_RIG2_PATCHONPATCH10';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data'; 

%%  
% HOLES in brain
% pre
% n=n+1;
% files(n).subj = 'G6H107LN'; %animal name
% files(n).expt = '110518'; %date of experiment
% files(n).topox= '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOX\110518__G6H107LN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOX\110518__G6H107LN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOY\110518__G6H107LN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOY\110518__G6H107LN_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_PATCHONPATCH\110518__G6H107LN_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_PATCHONPATCH\110518__G6H107LN_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H107LN'; %animal name
% files(n).expt = '110518'; %date of experiment
% files(n).topox= '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOX\110518__G6H107LN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOX\110518__G6H107LN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOY\110518__G6H107LN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOY\110518__G6H107LN_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_PATCHONPATCH\110518__G6H107LN_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_PATCHONPATCH\110518__G6H107LN_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%% 
% % USE for GROUP analysis (good injection on side contralateral to viewing
% eye)
% pre
% n=n+1;
% files(n).subj = 'G6H121TT'; %animal name
% files(n).expt = '110918'; %date of experiment
% files(n).topox= '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOX\110918_G6H121TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOX\110918_G6H121TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOY\110918_G6H121TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOY\110918_G6H121TT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_PATCHONPATCH\110918_G6H121TT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_PATCHONPATCH\110918_G6H121TT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H121TT'; %animal name
% files(n).expt = '110918'; %date of experiment
% files(n).topox= '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOX\110918_G6H121TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOX\110918_G6H121TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOY\110918_G6H121TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOY\110918_G6H121TT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_PATCHONPATCH\110918_G6H121TT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_PATCHONPATCH\110918_G6H121TT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%% 
% UNKNOWN injection site (not sectioned yet)
% pre
% n=n+1;
% files(n).subj = 'G6H1110RT'; %animal name
% files(n).expt = '121318'; %date of experiment
% files(n).topox= '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_PRE_TOPOX\121318_G6H1110RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_PRE_TOPOX\121318_G6H1110RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_PRE_TOPOY\121318_G6H1110RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_PRE_TOPOY\121318_G6H1110RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_PRE_PATCHONPATCH\121318_G6H1110RT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_PRE_PATCHONPATCH\121318_G6H1110RT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% post
% 
% n=n+1;
% files(n).subj = 'G6H1110RT'; %animal name
% files(n).expt = '121318'; %date of experiment
% files(n).topox= '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_POST_TOPOX\121318_G6H1110RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_POST_TOPOX\121318_G6H1110RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_POST_TOPOY\121318_G6H1110RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_POST_TOPOY\121318_G6H1110RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_POST_PATCHONPATCH\121318_G6H1110RT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '121318_G6H1110RT_RIG2\121318_G6H1110RT_RIG2_POST_PATCHONPATCH\121318_G6H1110RT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%%
% AFTER x-MAS
% pre
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '020519'; %date of experiment
% files(n).topox= '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOX\020519_G6H127RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOX\020519_G6H127RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOY\020519_G6H127RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOY\020519_G6H127RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_PATCHONPATCH\020519_G6H127RT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_PATCHONPATCH\020519_G6H127RT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '020519'; %date of experiment
% files(n).topox= '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOX\020519_G6H127RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOX\020519_G6H127RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOY\020519_G6H127RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOY\020519_G6H127RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_PATCHONPATCH\020519_G6H127RT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_PATCHONPATCH\020519_G6H127RT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';


% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%% G6H127RT       ************
% % pre
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '021319'; %date of experiment
% files(n).topox= '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOX\021319_G6H127RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOX\021319_G6H127RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOY\021319_G6H127RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOY\021319_G6H127RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_PATCHONPATCH\021319_G6H127RT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_PATCHONPATCH\021319_G6H127RT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '021319'; %date of experiment
% files(n).topox= '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOX\021319_G6H127RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOX\021319_G6H127RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOY\021319_G6H127RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOY\021319_G6H127RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_PATCHONPATCH\021319_G6H127RT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_PATCHONPATCH\021319_G6H127RT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%%
% not sure this analyzePatchOnPatch analsyis ran correctly - never picked center point
% this was the really low gain session anyways
% n=n+1;
% files(n).subj = 'G6H127LT'; %animal name
% files(n).expt = '021419'; %date of experiment
% files(n).topox= '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_PRE_TOPOX\021419_G6H127LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_PRE_TOPOX\021419_G6H127LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_PRE_TOPOY\021419_G6H127LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_PRE_TOPOY\021419_G6H127LT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_PRE_PATCHONPATCH\021419_G6H127LT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_PRE_PATCHONPATCH\021419_G6H127LT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H127LT'; %animal name
% files(n).expt = '021419'; %date of experiment
% files(n).topox= '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_POST_TOPOX\021419_G6H127LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_POST_TOPOX\021419_G6H127LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_POST_TOPOY\021419_G6H127LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_POST_TOPOY\021419_G6H127LT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_POST_PATCHONPATCH\021419_G6H127LT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021419_G6H127LT_RIG2\021419_G6H127LT_RIG2_POST_PATCHONPATCH\021419_G6H127LT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%%
% error during dfofMovie for post patch session
% n=n+1;
% files(n).subj = 'G6H132RT'; %animal name
% files(n).expt = '011719'; %date of experiment
% files(n).topox= '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOX\011719_G6H132RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOX\011719_G6H132RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOY\011719_G6H132RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOY\011719_G6H132RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_PATCHONPATCH\011719_G6H132RT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_PATCHONPATCH\011719_G6H132RT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H132RT'; %animal name
% files(n).expt = '011719'; %date of experiment
% files(n).topox= '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOX\011719_G6H132RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOX\011719_G6H132RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOY\011719_G6H132RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOY\011719_G6H132RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_PATCHONPATCH\011719_G6H132RT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_PATCHONPATCH\011719_G6H132RT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%%
% n=n+1;
% files(n).subj = 'G6H125LT'; %animal name
% files(n).expt = '021419'; %date of experiment
% files(n).topox= '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_PRE_TOPOX\021419_G6H125LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_PRE_TOPOX\021419_G6H125LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_PRE_TOPOY\021419_G6H125LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_PRE_TOPOY\021419_G6H125LT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_PRE_PATCHONPATCH\021419_G6H125LT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_PRE_PATCHONPATCH\021419_G6H125LT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H125LT'; %animal name
% files(n).expt = '021419'; %date of experiment
% files(n).topox= '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_POST_TOPOX\021419_G6H125LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_POST_TOPOX\021419_G6H125LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_POST_TOPOY\021419_G6H125LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_POST_TOPOY\021419_G6H125LT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_POST_PATCHONPATCH\021419_G6H125LT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021419_G6H125LT_RIG2\021419_G6H125LT_RIG2_POST_PATCHONPATCH\021419_G6H125LT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%%
% large dose
% patch analysis not complete - ran pout of memory during dfofMovie 
% n=n+1;
% files(n).subj = 'G6H121TT'; %animal name
% files(n).expt = '120718'; %date of experiment
% files(n).topox= '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_PRE_TOPOX\120718_G6H121  TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_PRE_TOPOX\120718_G6H121TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_PRE_TOPOY\120718_G6H121TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_PRE_TOPOY\120718_G6H121TT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_PRE_PATCHONPATCH\120718_G6H121TT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_PRE_PATCHONPATCH\120718_G6H121TT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H121TT'; %animal name
% files(n).expt = '120718'; %date of experiment
% files(n).topox= '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_POST_TOPOX\120718_G6H121TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_POST_TOPOX\120718_G6H121TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_POST_TOPOY\120718_G6H121TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_POST_TOPOY\120718_G6H121TT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_POST_PATCHONPATCH\120718_G6H121TT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '120718_G6H121TT_RIG2\120718_G6H121TT_RIG2_POST_PATCHONPATCH\120718_G6H121TT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%% G6H127LT     **************
% Green light not centered very well
% n=n+1;
% files(n).subj = 'G6H127LT'; %animal name
% files(n).expt = '021519'; %date of experiment
% files(n).topox= '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_PRE_TOPOX\021519_G6H127LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_PRE_TOPOX\021519_G6H127LT_RIG2_PRE_TOPOY'; %raw data
% files(n).topoy = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_PRE_TOPOY\021519_G6H127LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_PRE_TOPOY\021519_G6H127LT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_PRE_PATCHONPATCH\021519_G6H127LT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_PRE_PATCHONPATCH\021519_G6H127LT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H127LT'; %animal name
% files(n).expt = '021519'; %date of experiment
% files(n).topox= '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_POST_TOPOX\021519_G6H127LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_POST_TOPOX\021519_G6H127LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_POST_TOPOY\021519_G6H127LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_POST_TOPOY\021519_G6H127LT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_POST_PATCHONPATCH\021519_G6H127LT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021519_G6H127LT_RIG2\021519_G6H127LT_RIG2_POST_PATCHONPATCH\021519_G6H127LT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%% G6H811TT @ 0.5 mg/kg cloz       ********
% % 
% n=n+1;
% files(n).subj = 'G6H811TT'; %animal name
% files(n).expt = '030519'; %date of experiment
% files(n).topox= '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_PRE_TOPOX\030519_G6H811TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_PRE_TOPOX\030519_G6H811TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_PRE_TOPOY\030519_G6H811TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_PRE_TOPOY\030519_G6H811TT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_PRE_PATCHONPATCH\030519_G6H811TT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_PRE_PATCHONPATCH\030519_G6H811TT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'yes' %note not a control virus, no virus
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H811TT'; %animal name
% files(n).expt = '030519'; %date of experiment
% files(n).topox= '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_POST_TOPOX\030519_G6H811TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_POST_TOPOX\030519_G6H811TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_POST_TOPOY\030519_G6H811TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_POST_TOPOY\030519_G6H811TT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_POST_PATCHONPATCH\030519_G6H811TT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '030519_G6H811TT_RIG2\030519_G6H811TT_RIG2_POST_PATCHONPATCH\030519_G6H811TT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'yes'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';

%% G6H811TT @ 0.2 mg/kg cloz
% n=n+1;
% files(n).subj = 'G6H811TT'; %animal name
% files(n).expt = '031219'; %date of experiment
% files(n).topox= '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_PRE_TOPOX\031219_G6H811TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_PRE_TOPOX\031219_G6H811TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_PRE_TOPOY\031219_G6H811TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_PRE_TOPOY\031219_G6H811TT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_PRE_PATCHONPATCH\031219_G6H811TT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_PRE_PATCHONPATCH\031219_G6H811TT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.2 mg/kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H811TT'; %animal name
% files(n).expt = '031219'; %date of experiment
% files(n).topox= '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_POST_TOPOX\031219_G6H811TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_POST_TOPOX\031219_G6H811TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_POST_TOPOY\031219_G6H811TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_POST_TOPOY\031219_G6H811TT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_POST_PATCHONPATCH\031219_G6H811TT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '031219_G6H811TT_RIG2\031219_G6H811TT_RIG2_POST_PATCHONPATCH\031219_G6H811TT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.2 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
%% G6HWW3RT on FLANKER task
% n=n+1;
% files(n).subj = 'G62WW3RT'; %animal name
% files(n).expt = '102717'; %date of experiment
% files(n).topox= '102717_WW3RT_RIG1\102717_WW3RT_RIG1_PRE_TOPOX\102717_WW3RT_RIG1_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_PRE_TOPOX\102717_WW3RT_RIG1_PRE_TOPOX'; %raw data
% files(n).topoy = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_PRE_TOPOY\102717_WW3RT_RIG1_PRE_TOPOYmaps.mat';
% files(n).topoydata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_PRE_TOPOY\102717_WW3RT_RIG1_PRE_TOPOY';
% files(n).patchonpatch =  '102717_WW3RT_RIG1\102717_WW3RT_RIG1_PRE_PATCHONPATCH\102717_WW3RT_RIG1_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_PRE_PATCHONPATCH\102717_WW3RT_RIG1_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.2 mg/kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'RIG1';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'WW3RT'; %animal name
% files(n).expt = '102717'; %date of experiment
% files(n).topox= '102717_WW3RT_RIG1\102717_WW3RT_RIG1_POST_TOPOX\102717_WW3RT_RIG1_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_POST_TOPOX\102717_WW3RT_RIG1_POST_TOPOX'; %raw data
% files(n).topoy = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_POST_TOPOY\102717_WW3RT_RIG1_POST_TOPOYmaps.mat';
% files(n).topoydata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_POST_TOPOY\102717_WW3RT_RIG1_POST_TOPOY';
% files(n).patchonpatch =  '102717_WW3RT_RIG1\102717_WW3RT_RIG1_POST_PATCHONPATCH\102717_WW3RT_RIG1_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_POST_PATCHONPATCH\102717_WW3RT_RIG1_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.2 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'RIG1';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good data';