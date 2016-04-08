close all

sbxaligndir

makeSbxMoviesBatch

tic
behav2pSession('g62dd2ln_001_000.sbx','behavSessionNEW.mat','trialRecords_2985-3332_20160331T131012-20160331T135216.mat');
topo2pSession('g62dd2ln_001_001.sbx','topoXsessionNEW.mat');
topo2pSession('g62dd2ln_001_002.sbx','topoYsessionNEW.mat');
grating2pSession('g62dd2ln_001_003.sbx','gratingSessionNEW.mat');
passiveBehav2pSession('g62dd2ln_001_004.sbx','passiveBehav3x4orientSessionNEW.mat ','C:\behavStim3sf4orient.mat');
passiveBehav2pSession('g62dd2ln_001_005.sbx','passiveBehav2sfSessionNEW.mat','C:\behavStim2sfSmall3366.mat');
toc

%getCellsBatch;
