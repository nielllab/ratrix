%batchMandiEnrichment
n = 0;

pathname = 'D:\Mandi\Enrichment Widefield\';
datapathname = 'D:\Mandi\Enrichment Widefield\';
outpathname = 'D:\Mandi\Enrichment Widefield\';

%%
n=n+1;
files(n).subj = 'G6H11p13LT';
files(n).expt = '052419';
files(n).topox= '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOX\052419_G6H11p13LT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOX\052419_G6H11p13LT_RIG2_TOPOX';
files(n).topoy = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOY\052419_G6H11p13LT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOY\052419_G6H11p13LT_RIG2_TOPOY';
files(n).grating4x3y6sf3tf =  '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS4X3Y\052419_G6H11p13LT_RIG2_GRATINGS4X3Ymaps.mat';
files(n).grating4x3y6sf3tfdata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS4X3Y\052419_G6H11p13LT_RIG2_GRATINGS4X3Y';
files(n).grating3x2y6sf4tf =  '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS3X2Y\052419_G6H11p13LT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS3X2Y\052419_G6H11p13LT_RIG2_GRATINGS3X2Y';
files(n).condition = 'control'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'vert'; %land or vert
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

%%

