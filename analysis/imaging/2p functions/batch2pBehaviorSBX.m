%batch2pBehavior    JW 8/11/16

clear all

dbstop if error
pathname = '\\langevin\backup\twophoton\Newton\data\';
outpathname = '';
n=0;

%g62dd2ln
n=n+1;
files(n).subj = 'g62dd2ln'; 
files(n).expt = '033016';
files(n).dir = '033016 g62dd2ln GTS behavior\g62dd2ln';
files(n).compileData ='compiled_g62dd2ln_033016.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x4orientSessionV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sfSessionV2__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62dd2ln'; 
files(n).expt = '033116';
files(n).dir = '033116 g62dd2ln GTS behavior\g62dd2ln';
files(n).compileData ='compiled_g62dd2ln_033116.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x4orientSessionV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sfSessionV2__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected


%g62y3lt
n=n+1;
files(n).subj = 'g62y3lt'; 
files(n).expt = '050316';
files(n).dir = '050316 g62y3lt GTS behavior\g62y3lt';
files(n).compileData ='compiled_g62y3lt_050216.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x4orientSessionV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sfSessionV2__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62y3lt'; 
files(n).expt = '050916';
files(n).dir = '050916 g62y3lt GTS behavior\g62y3lt';
files(n).compileData ='compiled_g62y3lt_050916.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x4orientSessionV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sfSessionV2__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected


%g62tx15lt

n=n+1;
files(n).subj = 'g62tx15lt'; 
files(n).expt = '060616';
files(n).dir = '060616 g62tx15lt GTS behavior\g62tx15lt';
files(n).compileData ='compiled_g62tx15lt_060616.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x4orientSessionV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sfSessionV2__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62tx15lt'; 
files(n).expt = '060816';
files(n).dir = '060816 g62tx15lt GTS behavior\g62tx15lt';
files(n).compileData ='compiled_g62tx15lt_060816.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x4orientSessionV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sfSessionV2__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62tx15lt'; 
files(n).expt = '072916';
files(n).dir = '072916 g62tx15lt GTS behavior\g62tx15lt';
files(n).compileData ='compiled_g62tx15lt_072916.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected



%g62bb10lt (gts)
n=n+1;
files(n).subj = 'g62bb10lt'; 
files(n).expt = '063016';
files(n).dir = '063016 g62bb10lt GTS behavior\g62bb10lt\';
files(n).compileData ='063016_g62bb10lt_compile.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';
files(n).passive2sfPts = 'passiveBehav2sf8minSessionV2__allfiles_PTS_dF';
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62bb10lt'; 
files(n).expt = '070716';
files(n).dir = '070716 g62bb10lt GTS behavior\g62bb10lt\';
files(n).compileData ='compiled_g62bb10lt_070716.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';
files(n).passive2sfPts = 'passiveBehav2sf8minSessionV2__allfiles_PTS_dF';
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62bb10lt'; 
files(n).expt = '071316';
files(n).dir = '071316 g62bb10lt GTS behavior\g62bb10lt\';
files(n).compileData ='compiled_g62bb10lt_071316.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';
files(n).passive2sfPts = 'passiveBehav2sf8minSessionV2__allfiles_PTS_dF';
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62bb10lt'; 
files(n).expt = '072616';
files(n).dir = '072616 g62bb10lt GTS behavior\g62bb10lt\';
files(n).compileData ='compiled_g62bb10lt_072616.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';
files(n).passive2sfPts = 'passiveBehav2sf8minSessionV2__allfiles_PTS_dF';
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

%%g62ff8rt (naive)  %first naive session 071916  %%% started behav 070116
n=n+1;
files(n).subj = 'g62ff8rt'; 
files(n).expt = '072116';
files(n).dir = '072116 g62ff8rt Naive behavior\g62ff8rt';
files(n).compileData ='compiled_g62ff8rt_072116.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'Naive';
files(n).learningDay = [3];   %%% can probably ignore for GTS, more important for naive
files(n).totalDays = 20;
files(n).totalSinceGratings = 2;
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62ff8rt'; 
files(n).expt = '072216';
files(n).dir = '072216 g62ff8rt Naive behavior\g62ff8rt';
files(n).compileData ='compiled_g62ff8rt_072216.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'Naive';
files(n).learningDay = [4];   %%% can probably ignore for GTS, more important for naive
files(n).totalSinceGratings = 3;
files(n).totalDays = 21;
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62ff8rt'; 
files(n).expt = '072716';
files(n).dir = '072716 g62ff8rt Naive behavior\g62ff8rt';
files(n).compileData ='compiled_g62ff8rt_072716.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'Naive';
files(n).learningDay = [6];   %%% can probably ignore for GTS, more important for naive
files(n).totalSinceGratings = 8;
files(n).totalDays = 26;
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62ff8rt'; 
files(n).expt = '072816';
files(n).dir = '072816 g62ff8rt Naive behavior\g62ff8rt';
files(n).compileData ='072816_g62ff8rt_compiled.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'Naive';
files(n).learningDay = [7];   %%% can probably ignore for GTS, more important for naive
files(n).totalSinceGratings = 9;
files(n).totalDays = 27;
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected


%g62bb12lt (naive) %first naive session 060216 %%% started behav 051216
n=n+1;
files(n).subj = 'g62bb12lt'; 
files(n).expt = '072116';
files(n).dir = '072116 g62bb12lt Naive behavior\g62bb12lt';
files(n).compileData ='compiled_g62bb12lt_072116.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'Naive';
files(n).learningDay = [7];   %%% can probably ignore for GTS, more important for naive
files(n).totalSinceGratings = 49;
files(n).totalDays = 70;
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected

n=n+1;
files(n).subj = 'g62bb12lt'; 
files(n).expt = '072216';
files(n).dir = '072216 g62bb12lt Naive behavior\g62bb12lt';
files(n).compileData ='072216_g62bb12lt_compiled.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).topoX = 'topoXsessionV2';
files(n).topoY = 'topoYsessionV2';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
files(n).task = 'Naive';
files(n).learningDay = [8];   %%% can probably ignore for GTS, more important for naive
files(n).totalSinceGratings = 50;
files(n).totalDays = 71;
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected




% n=n+1;
% files(n).subj = ''; 
% files(n).expt = '';
% files(n).dir = '';
% files(n).compileData ='';  
% files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
% files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
% files(n).topoX = 'topoXsessionV2';
% files(n).topoY = 'topoYsessionV2';
% files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
% files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';%or passiveBehav3x4orient__allfiles_PTS_dF
% files(n).passive2sfPts = 'passiveBehav2sf8min__allfiles_PTS_dF'; %or passiveBehav2sfSessionV2__allfiles_PTS_dF
% files(n).task = '';
% files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected
