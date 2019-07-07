%% batchMandiEnrichment
n = 0;

pathname = 'F:\Mandi\EnrichmentWidefield\';
datapathname = 'F:\Mandi\EnrichmentWidefield\';
outpathname = 'F:\Mandi\EnrichmentWidefield\';

% pathname = '\\langevin\backup\widefield\Mandi\EnrichmentWidefield\';
% datapathname = '\\langevin\backup\widefield\Mandi\EnrichmentWidefield\';
% outpathname = '\\langevin\backup\widefield\Mandi\EnrichmentWidefield\';

%%
% 
% % n=n+1;
% % files(n).subj = 'G6H11p13LT';
% % files(n).expt = '052419';
% % files(n).topox= '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOX\052419_G6H11p13LT_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOX\052419_G6H11p13LT_RIG2_TOPOX';
% % files(n).topoy = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOY\052419_G6H11p13LT_RIG2_TOPOYmaps.mat';
% % files(n).topoydata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_TOPOY\052419_G6H11p13LT_RIG2_TOPOY';
% % files(n).grating4x3y6sf3tf =  '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS4X3Y\052419_G6H11p13LT_RIG2_GRATINGS4X3Ymaps.mat';
% % files(n).grating4x3y6sf3tfdata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS4X3Y\052419_G6H11p13LT_RIG2_GRATINGS4X3Y';
% % %  files(n).grating3x2y6sf4tf =  '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS3X2Y\052419_G6H11p13LT_RIG2_GRATINGS3X2Ymaps.mat';
% % %  files(n).grating3x2y6sf4tfdata = '052419_G6H11p13LT_RIG2\052419_G6H11p13LT_RIG2_GRATINGS3X2Y\052419_G6H11p13LT_RIG2_GRATINGS3X2Y';
% % files(n).condition = 'control'; %control or enriched
% % files(n).rignum = 'rig2'; %rig1 or rig2
% % files(n).monitor = 'vert'; %land or vert
% % files(n).label = 'camk2 gc6';
% % files(n).notes = 'ran in portrait mode accidentally';
% 
% %%
% % n=n+1;
% % files(n).subj = 'G6H11p13LT';
% % files(n).expt = '052819';
% % files(n).topox= '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_TOPOX\052819_G6H11p13LT_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_TOPOX\052819_G6H11p13LT_RIG2_TOPOX';
% % % files(n).topoy = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_TOPOY\052819_G6H11p13LT_RIG2_TOPOYmaps.mat';
% % % files(n).topoydata = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_TOPOY\052819_G6H11p13LT_RIG2_TOPOY';
% % files(n).topoy = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_TOPOYNEW\052819_G6H11p13LT_RIG2_TOPOYNEWmaps.mat';
% % files(n).topoydata = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_TOPOYNEW\052819_G6H11p13LT_RIG2_TOPOYNEW';
% % files(n).grating4x3y6sf3tf =  '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_GRATINGS4X3Y\052819_G6H11p13LT_RIG2_GRATINGS4X3Ymaps.mat';
% % files(n).grating4x3y6sf3tfdata = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_GRATINGS4X3Y\052819_G6H11p13LT_RIG2_GRATINGS4X3Y';
% % %  files(n).grating3x2y6sf4tf =  '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_GRATINGS3X2Y\052819_G6H11p13LT_RIG2_GRATINGS3X2Ymaps.mat';
% % %  files(n).grating3x2y6sf4tfdata = '052819_G6H11p13LT_RIG2\052819_G6H11p13LT_RIG2_GRATINGS3X2Y\052819_G6H11p13LT_RIG2_GRATINGS3X2Y';
% % files(n).condition = 'control'; %control or enriched
% % files(n).rignum = 'rig2'; %rig1 or rig2
% % files(n).monitor = 'land'; %land or vert. All after this trial should be land.
% % files(n).label = 'camk2 gc6';
% % files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.
% 
% 
% %%
% % n=n+1;
% % files(n).subj = 'G6H21p2RT';
% % files(n).expt = '053019';
% % files(n).topox= '053019_G6H21p2RT_RIG2\053019_G6H21p2RT_RIG2_TOPOX\053019_G6H21p2RT_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '053019_G6H21p2RT_RIG2\053019_G6H21p2RT_RIG2_TOPOX\053019_G6H21p2RT_RIG2_TOPOX';
% % files(n).topoy = '053019_G6H21p2RT_RIG2\053019_G6H21p2RT_RIG2_TOPOY\053019_G6H21p2RT_RIG2_TOPOYmaps.mat';
% % files(n).topoydata = '053019_G6H21p2RT_RIG2\053019_G6H21p2RT_RIG2_TOPOY\053019_G6H21p2RT_RIG2_TOPOY';
% % files(n).grating3x2y6sf4tf =  '053019_G6H21p2RT_RIG2\053019_G6H21p2RT_RIG2_GRATINGS3X2YNEW\053019_G6H21p2RT_RIG2_GRATINGS3X2YNEWmaps.mat';
% % files(n).grating3x2y6sf4tfdata = '053019_G6H21p2RT_RIG2\053019_G6H21p2RT_RIG2_GRATINGS3X2YNEW\053019_G6H21p2RT_RIG2_GRATINGS3X2YNEW';
% % files(n).condition = 'enriched'; %control or enriched
% % files(n).rignum = 'rig2'; %rig1 or rig2
% % files(n).monitor = 'land'; %land or vert. All should be land.
% % files(n).label = 'camk2 gc6';
% % files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% % files(n).imagerate = 10; %imaging rate in Hz (usually 10)
% % files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.
% 
% %%
% % n=n+1;
% % files(n).subj = 'G6H21p1LT';
% % files(n).expt = '060319';
% % files(n).topox= '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_TOPOX\060319_G6H21p1LT_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_TOPOX\060319_G6H21p1LT_RIG2_TOPOX';
% % files(n).topoy = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_TOPOY\060319_G6H21p1LT_RIG2_TOPOYmaps.mat';
% % files(n).topoydata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_TOPOY\060319_G6H21p1LT_RIG2_TOPOY';
% % files(n).grating3x2y6sf4tf =  '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Ymaps.mat';
% % files(n).grating3x2y6sf4tfdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Y';
% % files(n).grating4x3y6sf3tf =  '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS4X3Y\060319_G6H21p1LT_RIG2_GRATINGS4X3Ymaps.mat';
% % files(n).grating4x3y6sf3tfdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS4X3Y\060319_G6H21p1LT_RIG2_GRATINGS4X3Y';
% % files(n).condition = 'enriched'; %control or enriched
% % files(n).rignum = 'rig2'; %rig1 or rig2
% % files(n).monitor = 'land'; %land or vert. All should be land.
% % files(n).label = 'camk2 gc6';
% % files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% % files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% % files(n).imagerate = 10; %imaging rate in Hz (usually 10)
% % files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.
% 
% %% not GCaMP?
% % n=n+1;
% % files(n).subj = 'G6H21p1RN';
% % files(n).expt = '060319';
% % files(n).topox= '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_TOPOX\060319_G6H21p1RN_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_TOPOX\060319_G6H21p1RN_RIG2_TOPOX';
% % files(n).topoy = '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_TOPOY\060319_G6H21p1RN_RIG2_TOPOYmaps.mat';
% % files(n).topoydata = '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_TOPOY\060319_G6H21p1RN_RIG2_TOPOY';
% % files(n).grating3x2y6sf4tf =  '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_GRATINGS3X2Y\060319_G6H21p1RN_RIG2_GRATINGS3X2Ymaps.mat';
% % files(n).grating3x2y6sf4tfdata = '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_GRATINGS3X2Y\060319_G6H21p1RN_RIG2_GRATINGS3X2Y';
% % files(n).grating4x3y6sf3tf =  '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_GRATINGS4X3Y\060319_G6H21p1RN_RIG2_GRATINGS4X3Ymaps.mat';
% % files(n).grating4x3y6sf3tfdata = '060319_G6H21p1RN_RIG2\060319_G6H21p1RN_RIG2_GRATINGS4X3Y\060319_G6H21p1RN_RIG2_GRATINGS4X3Y';
% % files(n).condition = 'enriched'; %control or enriched
% % files(n).rignum = 'rig2'; %rig1 or rig2
% % files(n).monitor = 'land'; %land or vert. All should be land.
% % files(n).label = 'camk2 gc6';
% % files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% % files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% % files(n).imagerate = 10; %imaging rate in Hz (usually 10)
% % files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%
% n=n+1;
% files(n).subj = 'G6H11p13LT';
% files(n).expt = '060619';
% files(n).topox= '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOX\060619_G6H11p13LT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOX\060619_G6H11p13LT_RIG2_TOPOX';
% files(n).topoy = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOY\060619_G6H11p13LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOY\060619_G6H11p13LT_RIG2_TOPOY';
% files(n).grating3x2y6sf4tf =  '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_GRATINGS3X2Y\060619_G6H11p13LT_RIG2_GRATINGS3X2Ymaps.mat';
% files(n).grating3x2y6sf4tfdata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_GRATINGS3X2Y\060619_G6H11p13LT_RIG2_GRATINGS3X2Y';
% files(n).naturalimages =  '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_NATIM\060619_G6H11p13LT_RIG2_NATIMmaps.mat';
% files(n).naturalimagesdata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_NATIM\060619_G6H11p13LT_RIG2_NATIM';
% files(n).condition = 'control'; %control or enriched
% files(n).rignum = 'rig2'; %rig1 or rig2
% files(n).monitor = 'land'; %land or vert. All should be land.
% files(n).label = 'camk2 gc6';
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
% files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';
% files(n).imagerate = 10; %imaging rate in Hz (usually 10)
% files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.
% 
% %%
% n=n+1;
% files(n).subj = 'G6H11p13LT';
% files(n).expt = '060619';
% files(n).topox= '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOX\060619_G6H11p13LT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOX\060619_G6H11p13LT_RIG2_TOPOX';
% files(n).topoy = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOY\060619_G6H11p13LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_TOPOY\060619_G6H11p13LT_RIG2_TOPOY';
% files(n).grating3x2y6sf4tf =  '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_GRATINGS3X2Y_MAG10\060619_G6H11p13LT_RIG2_GRATINGS3X2Y_MAG10maps.mat';
% files(n).grating3x2y6sf4tfdata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_GRATINGS3X2Y_MAG10\060619_G6H11p13LT_RIG2_GRATINGS3X2Y_MAG10';
% files(n).naturalimages =  '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_NATIM\060619_G6H11p13LT_RIG2_NATIMmaps.mat';
% files(n).naturalimagesdata = '060619_G6H11p13LT_RIG2\060619_G6H11p13LT_RIG2_NATIM\060619_G6H11p13LT_RIG2_NATIM';
% files(n).condition = 'control'; %control or enriched
% files(n).rignum = 'rig2'; %rig1 or rig2
% files(n).monitor = 'land'; %land or vert. All should be land.
% files(n).label = 'camk2 gc6';
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
% files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';
% files(n).imagerate = 10; %imaging rate in Hz (usually 10)
% files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%
n=n+1;
files(n).subj = 'G6H21p2RT';
files(n).expt = '061419';
files(n).topox= '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_TOPOX\061419_G6H21p2RT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_TOPOX\061419_G6H21p2RT_RIG2_TOPOX';
files(n).topoy = '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_TOPOY\061419_G6H21p2RT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_TOPOY\061419_G6H21p2RT_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_GRATINGS3X2Y\061419_G6H21p2RT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_GRATINGS3X2Y\061419_G6H21p2RT_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_NATIM\061419_G6H21p2RT_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_NATIM\061419_G6H21p2RT_RIG2_NATIM';
files(n).darkness=  '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_DARKNESS\061419_G6H21p2RT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '061419_G6H21p2RT_RIG2\061419_G6H21p2RT_RIG2_DARKNESS\061419_G6H21p2RT_RIG2_DARKNESS';
files(n).condition = 'enriched'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%
n=n+1;
files(n).subj = 'G6H21p2RN';
files(n).expt = '061419';
files(n).topox= '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_TOPOX\061419_G6H21p2RN_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_TOPOX\061419_G6H21p2RN_RIG2_TOPOX';
files(n).topoy = '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_TOPOY\061419_G6H21p2RN_RIG2_TOPOYmaps.mat';
files(n).topoydata = '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_TOPOY\061419_G6H21p2RN_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_GRATINGS3X2Y\061419_G6H21p2RN_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_GRATINGS3X2Y\061419_G6H21p2RN_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_NATIM\061419_G6H21p2RN_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_NATIM\061419_G6H21p2RN_RIG2_NATIM';
files(n).darkness=  '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_DARKNESS\061419_G6H21p2RN_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '061419_G6H21p2RN_RIG2\061419_G6H21p2RN_RIG2_DARKNESS\061419_G6H21p2RN_RIG2_DARKNESS';
files(n).condition = 'enriched'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%

n=n+1;
files(n).subj = 'G6H21p2LT';
files(n).expt = '062019';
files(n).topox= '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_TOPOX\062019_G6H21p2LT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_TOPOX\062019_G6H21p2LT_RIG2_TOPOX';
files(n).topoy = '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_TOPOY\062019_G6H21p2LT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_TOPOY\062019_G6H21p2LT_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_GRATINGS3X2Y\062019_G6H21p2LT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_GRATINGS3X2Y\062019_G6H21p2LT_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_NATIM\062019_G6H21p2LT_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_NATIM\062019_G6H21p2LT_RIG2_NATIM';
files(n).darkness=  '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_DARKNESS\062019_G6H21p2LT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '062019_G6H21p2LT_RIG2\062019_G6H21p2LT_RIG2_DARKNESS\062019_G6H21p2LT_RIG2_DARKNESS';
files(n).condition = 'enriched'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%

n=n+1;
files(n).subj = 'G6H21p2NN';
files(n).expt = '062019';
files(n).topox= '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_TOPOX\062019_G6H21p2NN_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_TOPOX\062019_G6H21p2NN_RIG2_TOPOX';
files(n).topoy = '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_TOPOY\062019_G6H21p2NN_RIG2_TOPOYmaps.mat';
files(n).topoydata = '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_TOPOY\062019_G6H21p2NN_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_GRATINGS3X2Y\062019_G6H21p2NN_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_GRATINGS3X2Y\062019_G6H21p2NN_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_NATIM\062019_G6H21p2NN_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_NATIM\062019_G6H21p2NN_RIG2_NATIM';
files(n).darkness=  '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_DARKNESS\062019_G6H21p2NN_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '062019_G6H21p2NN_RIG2\062019_G6H21p2NN_RIG2_DARKNESS\062019_G6H21p2NN_RIG2_DARKNESS';
files(n).condition = 'enriched'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'not Gcamp'; %If something happens during the experiment that could affect data, write here.

%%

n=n+1;
files(n).subj = 'G6H21p2TT';
files(n).expt = '062119';
files(n).topox= '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_TOPOX\062119_G6H21p2TT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_TOPOX\062119_G6H21p2TT_RIG2_TOPOX';
files(n).topoy = '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_TOPOY\062119_G6H21p2TT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_TOPOY\062119_G6H21p2TT_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_GRATINGS3X2Y\062119_G6H21p2TT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_GRATINGS3X2Y\062119_G6H21p2TT_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_NATIM\062119_G6H21p2TT_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_NATIM\062119_G6H21p2TT_RIG2_NATIM';
files(n).darkness=  '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_DARKNESS\062119_G6H21p2TT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '062119_G6H21p2TT_RIG2\062119_G6H21p2TT_RIG2_DARKNESS\062119_G6H21p2TT_RIG2_DARKNESS';
files(n).condition = 'enriched'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%

n=n+1;
files(n).subj = 'G6H21p2LTRN';
files(n).expt = '062119';
files(n).topox= '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_TOPOX\062119_G6H21p2LTRN_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_TOPOX\062119_G6H21p2LTRN_RIG2_TOPOX';
files(n).topoy = '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_TOPOY\062119_G6H21p2LTRN_RIG2_TOPOYmaps.mat';
files(n).topoydata = '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_TOPOY\062119_G6H21p2LTRN_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_GRATINGS3X2Y\062119_G6H21p2LTRN_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_GRATINGS3X2Y\062119_G6H21p2LTRN_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_NATIM\062119_G6H21p2LTRN_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_NATIM\062119_G6H21p2LTRN_RIG2_NATIM';
files(n).darkness=  '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_DARKNESS\062119_G6H21p2LTRN_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '062119_G6H21p2LTRN_RIG2\062119_G6H21p2LTRN_RIG2_DARKNESS\062119_G6H21p2LTRN_RIG2_DARKNESS';
files(n).condition = 'enriched'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'not Gcamp'; %If something happens during the experiment that could affect data, write here.

%%

n=n+1;
files(n).subj = 'G6H17p7RT';
files(n).expt = '062619';
files(n).topox= '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_TOPOX\062619_G6H17p7RT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_TOPOX\062619_G6H17p7RT_RIG2_TOPOX';
files(n).topoy = '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_TOPOY\062619_G6H17p7RT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_TOPOY\062619_G6H17p7RT_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_GRATINGS3X2Y\062619_G6H17p7RT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_GRATINGS3X2Y\062619_G6H17p7RT_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_NATIM\062619_G6H17p7RT_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_NATIM\062619_G6H17p7RT_RIG2_NATIM';
files(n).darkness=  '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_DARKNESS\062619_G6H17p7RT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '062619_G6H17p7RT_RIG2\062619_G6H17p7RT_RIG2_DARKNESS\062619_G6H17p7RT_RIG2_DARKNESS';
files(n).condition = 'control'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.

%%

n=n+1;
files(n).subj = 'G6H17p8TT';
files(n).expt = '062619';
files(n).topox= '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_TOPOX\062619_G6H17p8TT_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_TOPOX\062619_G6H17p8TT_RIG2_TOPOX';
files(n).topoy = '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_TOPOY\062619_G6H17p8TT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_TOPOY\062619_G6H17p8TT_RIG2_TOPOY';
files(n).grating3x2y6sf4tf =  '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_GRATINGS3X2Y\062619_G6H17p8TT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_GRATINGS3X2Y\062619_G6H17p8TT_RIG2_GRATINGS3X2Y';
files(n).naturalimages =  '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_NATIM\062619_G6H17p8TT_RIG2_NATIMmaps.mat';
files(n).naturalimagesdata = '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_NATIM\062619_G6H17p8TT_RIG2_NATIM';
files(n).darkness=  '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_DARKNESS\062619_G6H17p8TT_RIG2_DARKNESSmaps.mat';
files(n).darknessdata = '062619_G6H17p8TT_RIG2\062619_G6H17p8TT_RIG2_DARKNESS\062619_G6H17p8TT_RIG2_DARKNESS';
files(n).condition = 'control'; %control or enriched
files(n).rignum = 'rig2'; %rig1 or rig2
files(n).monitor = 'land'; %land or vert. All should be land.
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).movienameNaturalImages = 'C:\src\Movies\naturalImagesEnrichment8mag648s.mat';
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\NewPts070119.mat';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).notes = 'good imaging session'; %If something happens during the experiment that could affect data, write here.