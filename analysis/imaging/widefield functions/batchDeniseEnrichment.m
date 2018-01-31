%batchDeniseEnrichment

dbstop if error

% pathname = 'C:\Users\nlab\Desktop\Data\Denise\';
% datapathname = 'C:\Users\nlab\Desktop\Data\Denise\';  
% outpathname = 'C:\Users\nlab\Desktop\Data\Denise\';

pathname = '\\langevin\backup\widefield\Denise\Enrichment\';
datapathname = '\\langevin\backup\widefield\Denise\Enrichment\';  
outpathname = '\\langevin\backup\widefield\Denise\Enrichment\';

n=0; %%%start counting sessions

n=n+1;
files(n).subj = '38RT';
files(n).expt = '012418';
files(n).topox= '012418_38RT_RIG2\012418_38RT_RIG2_TOPOX\012418_38RT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '012418_38RT_RIG2\012418_38RT_RIG2_TOPOX\012418_38RT_RIG2_TOPOX';
files(n).topoy = '012418_38RT_RIG2\012418_38RT_RIG2_TOPOY\012418_38RT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012418_38RT_RIG2\012418_38RT_RIG2_TOPOY\012418_38RT_RIG2_TOPOY';
files(n).darkness =  '012418_38RT_RIG2\012418_38RT_RIG2_DARKNESS\012418_38RT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012418_38RT_RIG2\012418_38RT_RIG2_DARKNESS\012418_38RT_RIG2_DARKNESS';
files(n).patchgratings =  '012418_38RT_RIG2\012418_38RT_RIG2_PATCHGRATINGS\012418_38RT_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012418_38RT_RIG2\012418_38RT_RIG2_PATCHGRATINGS\012418_38RT_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'control'; %control or enrichment

n=n+1;
files(n).subj = '43LT';
files(n).expt = '012618';
files(n).topox= '012618_43LT_RIG2\012618_43LT_RIG2_TOPOX\012618_43LT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '012618_43LT_RIG2\012618_43LT_RIG2_TOPOX\012618_43LT_RIG2_TOPOX';
files(n).topoy = '012618_43LT_RIG2\012618_43LT_RIG2_TOPOY\012618_43LT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012618_43LT_RIG2\012618_43LT_RIG2_TOPOY\012618_43LT_RIG2_TOPOY';
files(n).darkness =  '012618_43LT_RIG2\012618_43LT_RIG2_DARKNESS\012618_43LT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012618_43LT_RIG2\012618_43LT_RIG2_DARKNESS\012618_43LT_RIG2_DARKNESS';
files(n).patchgratings =  '012618_43LT_RIG2\012618_43LT_RIG2_PATCHGRATINGS\012618_43LT_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012618_43LT_RIG2\012618_43LT_RIG2_PATCHGRATINGS\012618_43LT_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'control'; %control or enrichment

% % % n=n+1;
% % % files(n).subj = '42RT';
% % % files(n).expt = '012518';
% % % files(n).topox= '012518_42RT_RIG2\012518_42RT_RIG2_TOPOX\012518_42RT_RIG2_TOPOXmaps.mat';
% % % files(n).topoxdata = '012518_42RT_RIG2\012518_42RT_RIG2_TOPOX\012518_42RT_RIG2_TOPOX';
% % % files(n).topoy = '012518_42RT_RIG2\012518_42RT_RIG2_TOPOY\012518_42RT_RIG2_TOPOYmaps.mat';
% % % files(n).topoydata = '012518_42RT_RIG2\012518_42RT_RIG2_TOPOY\012518_42RT_RIG2_TOPOY';
% % % files(n).darkness =  '012518_42RT_RIG2\012518_42RT_RIG2_DARKNESS\012518_42RT_RIG2_DARKNESSmaps.mat';
% % % files(n).darknessdata = '012518_42RT_RIG2\012518_42RT_RIG2_DARKNESS\012518_42RT_RIG2_DARKNESS';
% % % files(n).patchgratings =  '012518_42RT_RIG2\012518_42RT_RIG2_PATCHGRATINGS\012518_42RT_RIG2_PATCHGRATINGSmaps.mat';
% % % files(n).patchgratingsdata = '012518_42RT_RIG2\012518_42RT_RIG2_PATCHGRATINGS\012518_42RT_RIG2_PATCHGRATINGS';
% % % files(n).rignum = 'rig2';
% % % files(n).monitor = 'land';
% % % files(n).label = 'camk2 gc6';
% % % files(n).notes = 'good DARKNESS session'; %NEED TO REDO GRATINGS
% % % files(n).cond = 'control'; %control or enrichment

n=n+1;
files(n).subj = 'DDD8RT';
files(n).expt = '012518';
files(n).topox= '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_TOPOX\012518_DDD8RT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_TOPOX\012518_DDD8RT_RIG2_TOPOX';
files(n).topoy = '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_TOPOY\012518_DDD8RT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_TOPOY\012518_DDD8RT_RIG2_TOPOY';
files(n).darkness =  '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_DARKNESS\012518_DDD8RT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_DARKNESS\012518_DDD8RT_RIG2_DARKNESS';
files(n).patchgratings =  '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_PATCHGRATINGS\012518_DDD8RT_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012518_DDD8RT_RIG2\012518_DDD8RT_RIG2_PATCHGRATINGS\012518_DDD8RT_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'control'; %control or enrichment

% % % 

n=n+1;
files(n).subj = 'H111LT';
files(n).expt = '012618';
files(n).topox= '012618_H111LT_RIG2\012618_H111LT_RIG2_TOPOX\012618_H111LT_RIG2maps.mat';%NO TOPOX ON NAME
files(n).topoxdata = '012618_H111LT_RIG2\012618_H111LT_RIG2_TOPOX\012618_H111LT_RIG2';%NO TOPOX ON NAME
files(n).topoy = '012618_H111LT_RIG2\012618_H111LT_RIG2_TOPOY\012618_H111LT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012618_H111LT_RIG2\012618_H111LT_RIG2_TOPOY\012618_H111LT_RIG2_TOPOY';
files(n).darkness =  '012618_H111LT_RIG2\012618_H111LT_RIG2_DARKNESS\012618_H111LT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012618_H111LT_RIG2\012618_H111LT_RIG2_DARKNESS\012618_H111LT_RIG2_DARKNESS';
files(n).patchgratings =  '012618_H111LT_RIG2\012618_H111LT_RIG2_PATCHGRATINGS\012618_H111LT_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012618_H111LT_RIG2\012618_H111LT_RIG2_PATCHGRATINGS\012618_H111LT_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'enrichment'; %control or enrichment

n=n+1;
files(n).subj = 'H111RN';
files(n).expt = '012618';
files(n).topox= '012618_H111RN_RIG2\012618_H111RN_RIG2_TOPOX\012618_H111RN_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '012618_H111RN_RIG2\012618_H111RN_RIG2_TOPOX\012618_H111RN_RIG2_TOPOX';
files(n).topoy = '012618_H111RN_RIG2\012618_H111RN_RIG2_TOPOY\012618_H111RN_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012618_H111RN_RIG2\012618_H111RN_RIG2_TOPOY\012618_H111RN_RIG2_TOPOY';
files(n).darkness =  '012618_H111RN_RIG2\012618_H111RN_RIG2_DARKNESS\012618_H111RN_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012618_H111RN_RIG2\012618_H111RN_RIG2_DARKNESS\012618_H111RN_RIG2_DARKNESS';
files(n).patchgratings =  '012618_H111RN_RIG2\012618_H111RN_RIG2_PATCHGRATINGS\012618_H111RN_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012618_H111RN_RIG2\012618_H111RN_RIG2_PATCHGRATINGS\012618_H111RN_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'enrichment'; %control or enrichment

n=n+1;
files(n).subj = 'H111RT';
files(n).expt = '012618';
files(n).topox= '012618_H111RT_RIG2\012618_H111RT_RIG2_TOPOX\012618_H111RT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '012618_H111RT_RIG2\012618_H111RT_RIG2_TOPOX\012618_H111RT_RIG2_TOPOX';
files(n).topoy = '012618_H111RT_RIG2\012618_H111RT_RIG2_TOPOY\012618_H111RT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012618_H111RT_RIG2\012618_H111RT_RIG2_TOPOY\012618_H111RT_RIG2_TOPOY';
files(n).darkness =  '012618_H111RT_RIG2\012618_H111RT_RIG2_DARKNESS\012618_H111RT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012618_H111RT_RIG2\012618_H111RT_RIG2_DARKNESS\012618_H111RT_RIG2_DARKNESS';
files(n).patchgratings =  '012618_H111RT_RIG2\012618_H111RT_RIG2_PATCHGRATINGS\012618_H111RT_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012618_H111RT_RIG2\012618_H111RT_RIG2_PATCHGRATINGS\012618_H111RT_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'enrichment'; %control or enrichment

n=n+1;
files(n).subj = 'H111TT';
files(n).expt = '012618';
files(n).topox= '012618_H111TT_RIG2\012618_H111TT_RIG2_TOPOX\012618_H111TT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '012618_H111TT_RIG2\012618_H111TT_RIG2_TOPOX\012618_H111TT_RIG2_TOPOX';
files(n).topoy = '012618_H111TT_RIG2\012618_H111TT_RIG2_TOPOY\012618_H111TT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '012618_H111TT_RIG2\012618_H111TT_RIG2_TOPOY\012618_H111TT_RIG2_TOPOY';
files(n).darkness =  '012618_H111TT_RIG2\012618_H111TT_RIG2_DARKNESS\012618_H111TT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '012618_H111TT_RIG2\012618_H111TT_RIG2_DARKNESS\012618_H111TT_RIG2_DARKNESS';
files(n).patchgratings =  '012618_H111TT_RIG2\012618_H111TT_RIG2_PATCHGRATINGS\012618_H111TT_RIG2_PATCHGRATINGSmaps.mat';
files(n).patchgratingsdata = '012618_H111TT_RIG2\012618_H111TT_RIG2_PATCHGRATINGS\012618_H111TT_RIG2_PATCHGRATINGS';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).cond = 'enrichment'; %control or enrichment