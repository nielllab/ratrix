%batchPhilIntactSkull
dbstop if error
% pathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';
% datapathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';  
% outpathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';

pathname = 'C:\Users\nlab\Desktop\widefield\'
datapathname = 'C:\Users\nlab\Desktop\widefield\'
outpathname = 'C:\Users\nlab\Desktop\widefield\'
n = 0;

% n=n+1;
% files(n).subj = 'G62FFF7TT';
% files(n).expt = '101817';
% files(n).topox= '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_TOPOX\101817_G62FFF7TT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_TOPOX\101817_G62FFF7TT_RIG2_TOPOX';
% files(n).topoy = '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_TOPOY\101817_G62FFF7TT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_TOPOY\101817_G62FFF7TT_RIG2_TOPOY';
% files(n).darkness =  '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_DARKNESS\101817_G62FFF7TT_RIG2_DARKNESSmaps.mat';
% files(n).darknessdata = '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_DARKNESS\101817_G62FFF7TT_RIG2_DARKNESS';
% files(n).patchonpatch =  '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_PATCHONPATCH\101817_G62FFF7TT_RIG2_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '101817_G62FFF7TT_RIG2\101817_G62FFF7TT_RIG2_PATCHONPATCH\101817_G62FFF7TT_RIG2_PATCHONPATCH';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'none'; 

n=n+1;
files(n).subj = 'G62QQ10LT';
files(n).expt = '102517';
files(n).topox= '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOX\102517_G62QQ10LT_SALINE_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOX\102517_G62QQ10LT_SALINE_RIG2_TOPOX';
files(n).topoy = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOY\102517_G62QQ10LT_SALINE_RIG2_TOPOYmaps.mat';
files(n).topoydata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOY\102517_G62QQ10LT_SALINE_RIG2_TOPOY';
files(n).darkness =  '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_DARKNESS\102517_G62QQ10LT_SALINE_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_DARKNESS\102517_G62QQ10LT_SALINE_RIG2_DARKNESS';
files(n).patchonpatch =  '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH';
files(n).inject = 'saline';
files(n).rignum = 'rig2';
files(n).monitor = 'portrait';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).timing = 'pre'; 

n=n+1;
files(n).subj = 'G62QQ10LT';
files(n).expt = '102517';
files(n).topox= '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOX\102517_G62QQ10LT_SALINE_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOX\102517_G62QQ10LT_SALINE_RIG2_TOPOX';
files(n).topoy = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOY\102517_G62QQ10LT_SALINE_RIG2_TOPOYmaps.mat';
files(n).topoydata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_TOPOY\102517_G62QQ10LT_SALINE_RIG2_TOPOY';
files(n).darkness =  '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_DARKNESS_POST\102517_G62QQ10LT_SALINE_RIG2_DARKNESS_POSTmaps.mat';
files(n).darknessdata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_DARKNESS_POST\102517_G62QQ10LT_SALINE_RIG2_DARKNESS_POST';
files(n).patchonpatch =  '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH_POST\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH_POSTmaps.mat';
files(n).patchonpatchdata = '102517_G62QQ10LT_SALINE_RIG2\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH_POST\102517_G62QQ10LT_SALINE_RIG2_PATCHONPATCH_POST';
files(n).inject = 'saline';
files(n).rignum = 'rig2';
files(n).monitor = 'portrait';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).timing = 'post';
