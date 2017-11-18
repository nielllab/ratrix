%batchPhilIntactSkull
% close all
clear 

dbstop if error

% pathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';
% datapathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';  
% outpathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';

% pathname = 'C:\Users\nlab\Desktop\widefield\'
% datapathname = 'C:\Users\nlab\Desktop\widefield\'
% outpathname = 'C:\Users\nlab\Desktop\widefielcycMapd\'
% 
% pathname = 'D:\Elliott\DOIwidefield\';
% datapathname = 'D:\Elliott\DOIwidefield\';
% outpathname = 'D:\Elliott\DOIwidefield\';

pathname = 'D:\Angie\';
datapathname = 'D:\Angie\';
outpathname = 'D:\Angie\';

n = 0;

%%
n=n+1;
files(n).subj = 'G62QQ10LN';
files(n).expt = '110717';
files(n).topox= '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOX\110717_G62QQ10LN_SALINE_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOX\110717_G62QQ10LN_SALINE_RIG2_TOPOX';
files(n).topoy = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOY\110717_G62QQ10LN_SALINE_RIG2_TOPOYmaps.mat';
files(n).topoydata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOY\110717_G62QQ10LN_SALINE_RIG2_TOPOY';
files(n).darkness =  '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_PRE_DARKNESS\110717_G62QQ10LN_SALINE_RIG2_PRE_DARKNESSmaps.mat';
files(n).darknessdata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_PRE_DARKNESS\110717_G62QQ10LN_SALINE_RIG2_PRE_DARKNESS';
files(n).patchonpatch =  '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_PRE_PATCHONPATCH\110717_G62QQ10LN_SALINE_RIG2_PRE_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_PRE_PATCHONPATCH\110717_G62QQ10LN_SALINE_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'saline';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness';
files(n).timing = 'pre';
files(n).patchpts = '110717_G62QQ10LN_SALINE_RIG2\G62QQ10LNpatchpts.mat';
files(n).circpts = '110717_G62QQ10LN_SALINE_RIG2\G62QQ10LNcircpts.mat';

n=n+1;
files(n).subj = 'G62QQ10LN';
files(n).expt = '110717';
files(n).topox= '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOX\110717_G62QQ10LN_SALINE_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOX\110717_G62QQ10LN_SALINE_RIG2_TOPOX';
files(n).topoy = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOY\110717_G62QQ10LN_SALINE_RIG2_TOPOYmaps.mat';
files(n).topoydata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_TOPOY\110717_G62QQ10LN_SALINE_RIG2_TOPOY';
files(n).darkness =  '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_POST_DARKNESS\110717_G62QQ10LN_SALINE_RIG2_POST_DARKNESSmaps.mat';
files(n).darknessdata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_POST_DARKNESS\110717_G62QQ10LN_SALINE_RIG2_POST_DARKNESS';
files(n).patchonpatch =  '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_POST_PATCHONPATCH\110717_G62QQ10LN_SALINE_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '110717_G62QQ10LN_SALINE_RIG2\110717_G62QQ10LN_SALINE_RIG2_POST_PATCHONPATCH\110717_G62QQ10LN_SALINE_RIG2_POST_PATCHONPATCH';
files(n).inject = 'saline';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness';
files(n).timing = 'post';
files(n).patchpts = '110717_G62QQ10LN_SALINE_RIG2\G62QQ10LNpatchpts.mat';
files(n).circpts = '110717_G62QQ10LN_SALINE_RIG2\G62QQ10LNcircpts.mat';


%%
n=n+1;
files(n).subj = 'G62FFF_TT';
files(n).expt = '111017';
files(n).topox= '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOX\111017_G62FFF7TT_DOI_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOX\111017_G62FFF7TT_DOI_RIG2_TOPOX';
files(n).topoy = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOY\111017_G62FFF7TT_DOI_RIG2_TOPOYmaps.mat';
files(n).topoydata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOY\111017_G62FFF7TT_DOI_RIG2_TOPOY';
files(n).darkness =  '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_DARKNESS\111017_G62FFF7TT_DOI_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_DARKNESS\111017_G62FFF7TT_DOI_RIG2_DARKNESS';
files(n).patchonpatch =  '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_PATCHONPATCH\111017_G62FFF7TT_DOI_RIG2_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_PATCHONPATCH\111017_G62FFF7TT_DOI_RIG2_PATCHONPATCH';
files(n).inject = 'doi';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness and stimulus';
files(n).timing = 'pre';
files(n).patchpts = '111017_G62FFF_TT_DOI_RIG2\G62FFF_TTpatchpts.mat';
files(n).circpts = '111017_G62FFF_TT_DOI_RIG2\G62FFF_TTcircpts.mat';

n=n+1;
files(n).subj = 'G62FFF_TT';
files(n).expt = '111017';
files(n).topox= '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOX\111017_G62FFF7TT_DOI_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOX\111017_G62FFF7TT_DOI_RIG2_TOPOX';
files(n).topoy = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOY\111017_G62FFF7TT_DOI_RIG2_TOPOYmaps.mat';
files(n).topoydata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_TOPOY\111017_G62FFF7TT_DOI_RIG2_TOPOY';
files(n).darkness =  '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_POST_DARKNESS\111017_G62FFF7TT_DOI_RIG2_POST_DARKNESSmaps.mat';
files(n).darknessdata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_POST_DARKNESS\111017_G62FFF7TT_DOI_RIG2_POST_DARKNESS';
files(n).patchonpatch =  '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_POST_PATCHONPATCH\111017_G62FFF7TT_DOI_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '111017_G62FFF_TT_DOI_RIG2\111017_G62FFF_TT_DOI_RIG2_POST_PATCHONPATCH\111017_G62FFF7TT_DOI_RIG2_POST_PATCHONPATCH';
files(n).inject = 'doi';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness and stimulus';
files(n).timing = 'post';
files(n).patchpts = '111017_G62FFF_TT_DOI_RIG2\G62FFF7TTpatchpts.mat';
files(n).circpts = '111017_G62FFF_TT_DOI_RIG2\G62FFF7TTcircpts.mat';


%%
n=n+1;
files(n).subj = 'G6H3.1_LT';
files(n).expt = '111017';
files(n).topox= '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOX\111017_G6H3.1_LT_SALINE_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOX\111017_G6H3.1_LT_SALINE_RIG2_TOPOX';
files(n).topoy = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOY\111017_G6H3.1_LT_SALINE_RIG2_TOPOYmaps.mat';
files(n).topoydata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOY\111017_G6H3.1_LT_SALINE_RIG2_TOPOY';
files(n).darkness =  '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_DARKNESS\111017_G6H3.1_LT_SALINE_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_DARKNESS\111017_G6H3.1_LT_SALINE_RIG2_DARKNESS';
files(n).patchonpatch =  '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_PATCHONPATCH\111017_G6H3.1_LT_SALINE_RIG2_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_PATCHONPATCH\111017_G6H3.1_LT_SALINE_RIG2_PATCHONPATCH';
files(n).inject = 'saline';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness and stimulus';
files(n).timing = 'pre';
files(n).patchpts = '111017_G6H3.1_LT_SALINE_RIG2\G6H3.1_LTpatchpts.mat';
files(n).circpts = '111017_G6H3.1_LT_SALINE_RIG2\G6H3.1_LTcircpts.mat';

n=n+1;
files(n).subj = 'G6H3.1_LT';
files(n).expt = '111017';
files(n).topox= '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOX\111017_G6H3.1_LT_SALINE_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOX\111017_G6H3.1_LT_SALINE_RIG2_TOPOX';
files(n).topoy = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOY\111017_G6H3.1_LT_SALINE_RIG2_TOPOYmaps.mat';
files(n).topoydata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_TOPOY\111017_G6H3.1_LT_SALINE_RIG2_TOPOX';
files(n).darkness =  '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_POST_DARKNESS\111017_G6H3.1_LT_SALINE_RIG2_POST_DARKNESSmaps.mat';
files(n).darknessdata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_POST_DARKNESS\111017_G6H3.1_LT_SALINE_RIG2_POST_DARKNESS';
files(n).patchonpatch =  '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_POST_PATCHONPATCH\111017_G6H3.1_LT_SALINE_RIG2_Post_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '111017_G6H3.1_LT_SALINE_RIG2\111017_G6H3.1_LT_SALINE_RIG2_POST_PATCHONPATCH\111017_G6H3.1_LT_SALINE_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'saline';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness and stimulus';
files(n).timing = 'post';
files(n).patchpts = '111017_G6H3.1_LT_SALINE_RIG2\G6H3.1_LTpatchpts.mat';
files(n).circpts = '111017_G6H3.1_LT_SALINE_RIG2\G6H3.1_LTcircpts.mat';


%%
n=n+1;
files(n).subj = 'G62QQ10LT';
files(n).expt = '111617';
files(n).topox= '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOX\111617_G62FFF7TT_DOI_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOX\111617_G62FFF7TT_DOI_RIG2_TOPOX';
files(n).topoy = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOY\111617_G62FFF7TT_DOI_RIG2_TOPOYmaps.mat';
files(n).topoydata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOY\111617_G62QQ10LT_DOI_RIG2_TOPOY';
files(n).darkness =  '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_DARKNESS\111617_G62QQ10LT_DOI_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_DARKNESS\111617_G62QQ10LT_DOI_RIG2_DARKNESS';
files(n).patchonpatch =  '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_PATCHONPATCH\111617_G62QQ10LT_DOI_RIG2_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_PATCHONPATCH\111617_G62QQ10LT_DOI_RIG2_PATCHONPATCH';
files(n).inject = 'doi';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness and stimulus';
files(n).timing = 'pre';
files(n).patchpts = '111617_G62QQ10LT_DOI_RIG2\G62QQ10LTpatchpts.mat';
files(n).circpts = '111617_G62QQ10LT_DOI_RIG2\G62QQ10LTcircpts.mat';


n=n+1;
files(n).subj = 'G62QQ10LT';
files(n).expt = '111617';
files(n).topox= '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOX\111617_G62FFF7TT_DOI_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOX\111617_G62FFF7TT_DOI_RIG2_TOPOX';
files(n).topoy = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOY\111617_G62FFF7TT_DOI_RIG2_TOPOYmaps.mat';
files(n).topoydata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_RIG2_TOPOY\111617_G62QQ10LT_DOI_RIG2_TOPOY';
files(n).darkness =  '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_POST_RIG2_DARKNESS\111617_G62QQ10LT_DOI_POST_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_POST_RIG2_DARKNESS\111617_G62QQ10LT_DOI_POST_RIG2_DARKNESS';
files(n).patchonpatch =  '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_POST_RIG2_PATCHONPATCH\111617_G62QQ10LT_DOI_POST_RIG2_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '111617_G62QQ10LT_DOI_RIG2\111617_G62QQ10LT_DOI_POST_RIG2_PATCHONPATCH\111617_G62QQ10LT_DOI_RIG2_PATCHONPATCH';
files(n).inject = 'doi';
files(n).training = 'naive';
files(n).rignum = 'rig2';
files(n).monitor = 'landscape';
files(n).label = 'camk2 gc6';
files(n).notes = 'good darkness and stimulus';
files(n).timing = 'post';
files(n).patchpts = '111617_G62QQ10LT_DOI_RIG2\G62QQ10LTpatchpts.mat';
files(n).circpts = '111617_G62QQ10LT_DOI_RIG2\G62QQ10LTcircpts.mat';


%%

