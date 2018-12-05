n = 0;

pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\';
datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\';  
outpathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\';
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'

%% pre
% 
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

%% pre

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
% post
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

%% pre 
% corrupt stim obj version
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

%% 
% pre
n=n+1;
files(n).subj = 'G6H119RT'; %animal name
files(n).expt = '102618'; %date of experiment
files(n).topox= '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_PRE\102618_G6H119RT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
files(n).topoxdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_PRE\102618_G6H119RT_RIG2_TOPOX_PRE'; %raw data
files(n).topoy = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_PRE\102618_G6H119RT_RIG2_TOPOY_PREmaps.mat';
files(n).topoydata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_PRE\102618_G6H119RT_RIG2_TOPOY_PRE';
files(n).patchonpatch =  '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_PRE\102618_G6H119RT_RIG2_PATCHONPATCH_PREmaps.mat';
files(n).patchonpatchdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_PRE\102618_G6H119RT_RIG2_PATCHONPATCH10';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H119RT'; %animal name
files(n).expt = '102618'; %date of experiment
files(n).topox= '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_POST\102618_G6H119RT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
files(n).topoxdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOX_POST\102618_G6H119RT_RIG2_TOPOX'; %raw data
files(n).topoy = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_POST\102618_G6H119RT_RIG2_TOPOY_POSTmaps.mat';
files(n).topoydata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_TOPOY_POST\102618_G6H119RT_RIG2_TOPOY';
files(n).patchonpatch =  '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_POST\102618_G6H119RT_RIG2_PATCHONPATCH_POSTmaps.mat';
files(n).patchonpatchdata = '102618_G6H119RT_RIG2\102618_G6H119RT_RIG2_PATCHONPATCH_POST\102618_G6H119RT_RIG2_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data'; 


%%   
% % pre
n=n+1;
files(n).subj = 'G6H118RT'; %animal name
files(n).expt = '103018'; %date of experiment
files(n).topox= '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_PRE\103018_G6H118RT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
files(n).topoxdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_PRE\103018_G6H118RT_RIG2_TOPOX_PRE'; %raw data
files(n).topoy = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_PRE\103018_G6H118RT_RIG2_TOPOY_PREmaps.mat';
files(n).topoydata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_PRE\103018_G6H118RT_RIG2_TOPOY_PRE';
files(n).patchonpatch =  '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_PRE\103018_G6H118RT_RIG2_PATCHONPATCH_PREmaps.mat';
files(n).patchonpatchdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_PRE\103018_G6H118RT_RIG2_PATCHONPATCH_PRE';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'yes'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H118RT'; %animal name
files(n).expt = '103018'; %date of experiment
files(n).topox= '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_POST\103018_G6H118RT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
files(n).topoxdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOX_POST\103018_G6H118RT_RIG2_TOPOX'; %raw data
files(n).topoy = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_POST\103018_G6H118RT_RIG2_TOPOY_POSTmaps.mat';
files(n).topoydata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_TOPOY_POST\103018_G6H118RT_RIG2_TOPOY';
files(n).patchonpatch =  '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_POST\103018_G6H118RT_RIG2_PATCHONPATCH_POSTmaps.mat';
files(n).patchonpatchdata = '103018_G6H118RT_RIG2\103018_G6H118RT_RIG2_PATCHONPATCH_POST\103018_G6H118RT_RIG2_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'yes'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data'; 

%%
% % pre
n=n+1;
files(n).subj = 'G6H122LT'; %animal name
files(n).expt = '103018'; %date of experiment -WRONG date
files(n).topox= '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_PRE\103018_G6H122LT_RIG2_TOPOX_PREmaps.mat'; %where to put dfof
files(n).topoxdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_PRE\103018_G6H122LT_RIG2_TOPOX_PRE'; %raw data
files(n).topoy = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_PRE\103018_G6H122LT_RIG2_TOPOY_PREmaps.mat';
files(n).topoydata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_PRE\103018_G6H122LT_RIG2_TOPOY_PRE';
files(n).patchonpatch =  '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_PRE\103018_G6H122LT_RIG2_PATCHONPATCH10_PREmaps.mat';
files(n).patchonpatchdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_PRE\103018_G6H122LT_RIG2_PATCHONPATCH10_PRE';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H122LT'; %animal name
files(n).expt = '103018'; %date of experiment
files(n).topox= '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_POST\103018_G6H122LT_RIG2_TOPOX_POSTmaps.mat'; %where to put dfof
files(n).topoxdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOX_POST\103018_G6H122LT_RIG2_TOPOX'; %raw data
files(n).topoy = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_POST\103018_G6H122LT_RIG2_TOPOY_POSTmaps.mat';
files(n).topoydata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_TOPOY_POST\103018_G6H122LT_RIG2_TOPOY';
files(n).patchonpatch =  '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_POST\103018_G6H122LT_RIG2_PATCHONPATCH10_POSTmaps.mat';
files(n).patchonpatchdata = '103018_G6H122LT_RIG2\103018_G6H122LT_RIG2_PATCHONPATCH10_POST\103018_G6H122LT_RIG2_PATCHONPATCH10';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data'; 
% n = 0;
%%
% pre
n=n+1;
files(n).subj = 'G6H107LN'; %animal name
files(n).expt = '110518'; %date of experiment
files(n).topox= '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOX\110518__G6H107LN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOX\110518__G6H107LN_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOY\110518__G6H107LN_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_TOPOY\110518__G6H107LN_RIG2_PRE_TOPOY';
files(n).patchonpatch =  '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_PATCHONPATCH\110518__G6H107LN_RIG2_PRE_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_PRE_PATCHONPATCH\110518__G6H107LN_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H107LN'; %animal name
files(n).expt = '110518'; %date of experiment
files(n).topox= '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOX\110518__G6H107LN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOX\110518__G6H107LN_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOY\110518__G6H107LN_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_TOPOY\110518__G6H107LN_RIG2_POST_TOPOY';
files(n).patchonpatch =  '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_PATCHONPATCH\110518__G6H107LN_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '110518__G6H107LN_RIG2\110518__G6H107LN_RIG2_POST_PATCHONPATCH\110518__G6H107LN_RIG2_POST_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

%% 
% pre
n=n+1;
files(n).subj = 'G6H119RT'; %animal name
files(n).expt = '110618'; %date of experiment
files(n).topox= '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_PRE_TOPOX\110618_G6H119RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_PRE_TOPOX\110618_G6H119RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_PRE_TOPOY\110618_G6H119RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_PRE_TOPOY\110618_G6H119RT_RIG2_PRE_TOPOY';
files(n).occlusion =  '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_PRE_OCCLUSION\110618_G6H119RT_RIG2_PRE_OCCLUSIONmaps.mat';
files(n).occlusiondata = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_PRE_OCCLUSION\110618_G6H119RT_RIG2_PRE_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H119RT'; %animal name
files(n).expt = '110618'; %date of experiment
files(n).topox= '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_POST_TOPOX\110618_G6H119RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_POST_TOPOX\110618_G6H119RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_POST_TOPOY\110618_G6H119RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_POST_TOPOY\110618_G6H119RT_RIG2_POST_TOPOY';
files(n).occlusion =  '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_POST_OCCLUSION\110618_G6H119RT_RIG2_POST_OCCLUSIONmaps.mat';
files(n).occlusiondata = '110618_G6H119RT_RIG2\110618_G6H119RT_RIG2_POST_OCCLUSION\110618_G6H119RT_RIG2_POST_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% 
%% 
% pre
% stimObj for pre topox is missing!
n=n+1;
files(n).subj = 'G6H122LT'; %animal name
files(n).expt = '110818'; %date of experiment
files(n).topox= '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOX\110818_G6H122LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOX\110818_G6H122LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOY\110818_G6H122LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOY\110818_G6H122LT_RIG2_PRE_TOPOY';
files(n).occlusion =  '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_OCCLUSION\110818_G6H122LT_RIG2_PRE_OCCLUSIONmaps.mat';
files(n).occlusiondata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_OCCLUSION\110818_G6H122LT_RIG2_PRE_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H122LT'; %animal name
files(n).expt = '110818'; %date of experiment
files(n).topox= '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOX\110818_G6H122LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOX\110818_G6H122LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOY\110818_G6H122LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOY\110818_G6H122LT_RIG2_POST_TOPOY';
files(n).occlusion =  '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_OCCLUSION\110818_G6H122LT_RIG2_POST_OCCLUSIONmaps.mat';
files(n).occlusiondata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_TWO_POST_OCCLUSION\110818_G6H122LT_RIG2_TWO_POST_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

%%
% pre
n=n+1;
files(n).subj = 'G6H121TT'; %animal name
files(n).expt = '110918'; %date of experiment
files(n).topox= '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOX\110918_G6H121TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOX\110918_G6H121TT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOY\110918_G6H121TT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_TOPOY\110918_G6H121TT_RIG2_PRE_TOPOY';
files(n).patchonpatch =  '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_PATCHONPATCH\110918_G6H121TT_RIG2_PRE_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_PRE_PATCHONPATCH\110918_G6H121TT_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
% post
n=n+1;
files(n).subj = 'G6H121TT'; %animal name
files(n).expt = '110918'; %date of experiment
files(n).topox= '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOX\110918_G6H121TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOX\110918_G6H121TT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOY\110918_G6H121TT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_TOPOY\110918_G6H121TT_RIG2_POST_TOPOY';
files(n).patchonpatch =  '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_PATCHONPATCH\110918_G6H121TT_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '110918_G6H121TT_RIG2\110918_G6H121TT_RIG2_POST_PATCHONPATCH\110918_G6H121TT_RIG2_POST_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

%%
% pre
n=n+1;
files(n).subj = 'G6H121TT'; %animal name
files(n).expt = '111218'; %date of experiment
files(n).topox= '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOX\111218_G6H121TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOX\111218_G6H121TT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOY\111218_G6H121TT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOY\111218_G6H121TT_RIG2_PRE_TOPOY';
files(n).occlusion =  '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_OCCLUSION\111218_G6H121TT_RIG2_PRE_OCCLUSIONmaps.mat';
files(n).occlusiondata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_OCCLUSION\111218_G6H121TT_RIG2_PRE_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
%post
n=n+1;
files(n).subj = 'G6H121TT'; %animal name
files(n).expt = '111218'; %date of experiment
files(n).topox= '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOX\111218_G6H121TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOX\111218_G6H121TT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOY\111218_G6H121TT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOY\111218_G6H121TT_RIG2_POST_TOPOY';
files(n).occlusion =  '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_OCCLUSION\111218_G6H121TT_RIG2_POST_OCCLUSIONmaps.mat';
files(n).occlusiondata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_OCCLUSION\111218_G6H121TT_RIG2_POST_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

%%
% pre
n=n+1;
files(n).subj = 'G6H118RT'; %animal name
files(n).expt = '111318'; %date of experiment
files(n).topox= '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOX\111318_G6H118RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOX\111318_G6H118RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOY\111318_G6H118RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOY\111318_G6H118RT_RIG2_PRE_TOPOY';
files(n).occlusion =  '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_OCCLUSION\111318_G6H118RT_RIG2_PRE_OCCLUSIONmaps.mat';
files(n).occlusiondata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_OCCLUSION\111318_G6H118RT_RIG2_PRE_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'yes'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
%post
n=n+1;
files(n).subj = 'G6H118RT'; %animal name
files(n).expt = '111318'; %date of experiment
files(n).topox= '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOX\111318_G6H118RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOX\111318_G6H118RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOY\111318_G6H118RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOY\111318_G6H118RT_RIG2_POST_TOPOY';
files(n).occlusion =  '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_OCCLUSION\111318_G6H118RT_RIG2_POST_OCCLUSIONmaps.mat';
files(n).occlusiondata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_OCCLUSION\111318_G6H118RT_RIG2_POST_OCCLUSION';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'yes'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';


