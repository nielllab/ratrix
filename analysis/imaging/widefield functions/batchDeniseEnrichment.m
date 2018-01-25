%batchDeniseEnrichment

dbstop if error

pathname = 'C:\Users\nlab\Desktop\Data\Denise\';
datapathname = 'C:\Users\nlab\Desktop\Data\Denise\';  
outpathname = 'C:\Users\nlab\Desktop\Data\Denise\';

% pathname = '\\langevin\backup\widefield\Denise\Enrichment\';
% datapathname = '\\langevin\backup\widefield\Denise\Enrichment\';  
% outpathname = '\\langevin\backup\widefield\Denise\Enrichment\';

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

