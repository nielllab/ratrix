n = 0;

pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\';
datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\';  
outpathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\';
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'

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

% %%
% % pre
% % stimObj for pre topox is missing!
% n=n+1;
% files(n).subj = 'G6H122LT'; %animal name
% files(n).expt = '110818'; %date of experiment
% files(n).topox= '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOX\110818_G6H122LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOX\110818_G6H122LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOY\110818_G6H122LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_TOPOY\110818_G6H122LT_RIG2_PRE_TOPOY';
% files(n).occlusion =  '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_OCCLUSION\110818_G6H122LT_RIG2_PRE_OCCLUSIONmaps.mat';
% files(n).occlusiondata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_PRE_OCCLUSION\110818_G6H122LT_RIG2_PRE_OCCLUSION';
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
% % post
% n=n+1;
% files(n).subj = 'G6H122LT'; %animal name
% files(n).expt = '110818'; %date of experiment
% files(n).topox= '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOX\110818_G6H122LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOX\110818_G6H122LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOY\110818_G6H122LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_TOPOY\110818_G6H122LT_RIG2_POST_TOPOY';
% files(n).occlusion =  '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_POST_OCCLUSION\110818_G6H122LT_RIG2_POST_OCCLUSIONmaps.mat';
% files(n).occlusiondata = '110818_G6H122LT_RIG2\110818_G6H122LT_RIG2_TWO_POST_OCCLUSION\110818_G6H122LT_RIG2_TWO_POST_OCCLUSION';
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
% 
% %%
% % pre
% n=n+1;
% files(n).subj = 'G6H121TT'; %animal name
% files(n).expt = '111218'; %date of experiment
% files(n).topox= '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOX\111218_G6H121TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOX\111218_G6H121TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOY\111218_G6H121TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_TOPOY\111218_G6H121TT_RIG2_PRE_TOPOY';
% files(n).occlusion =  '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_OCCLUSION\111218_G6H121TT_RIG2_PRE_OCCLUSIONmaps.mat';
% files(n).occlusiondata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_PRE_OCCLUSION\111218_G6H121TT_RIG2_PRE_OCCLUSION';
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
% %post
% n=n+1;
% files(n).subj = 'G6H121TT'; %animal name
% files(n).expt = '111218'; %date of experiment
% files(n).topox= '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOX\111218_G6H121TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOX\111218_G6H121TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOY\111218_G6H121TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_TOPOY\111218_G6H121TT_RIG2_POST_TOPOY';
% files(n).occlusion =  '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_OCCLUSION\111218_G6H121TT_RIG2_POST_OCCLUSIONmaps.mat';
% files(n).occlusiondata = '111218_G6H121TT_RIG2\111218_G6H121TT_RIG2_POST_OCCLUSION\111218_G6H121TT_RIG2_POST_OCCLUSION';
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
% 
% %%
% % pre
% n=n+1;
% files(n).subj = 'G6H118RT'; %animal name
% files(n).expt = '111318'; %date of experiment
% files(n).topox= '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOX\111318_G6H118RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOX\111318_G6H118RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOY\111318_G6H118RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_TOPOY\111318_G6H118RT_RIG2_PRE_TOPOY';
% files(n).occlusion =  '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_OCCLUSION\111318_G6H118RT_RIG2_PRE_OCCLUSIONmaps.mat';
% files(n).occlusiondata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_PRE_OCCLUSION\111318_G6H118RT_RIG2_PRE_OCCLUSION';
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
% %post
% n=n+1;
% files(n).subj = 'G6H118RT'; %animal name
% files(n).expt = '111318'; %date of experiment
% files(n).topox= '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOX\111318_G6H118RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOX\111318_G6H118RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOY\111318_G6H118RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_TOPOY\111318_G6H118RT_RIG2_POST_TOPOY';
% files(n).occlusion =  '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_OCCLUSION\111318_G6H118RT_RIG2_POST_OCCLUSIONmaps.mat';
% files(n).occlusiondata = '111318_G6H118RT_RIG2\111318_G6H118RT_RIG2_POST_OCCLUSION\111318_G6H118RT_RIG2_POST_OCCLUSION';
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
