%batch2pBehavior    JW 6/5/15

clear all
close all
dbstop if error
pathname = '\\langevin\backup\twophoton\Newton\data\'
outpathname = '';
n=0;

n=n+1;
files(n).subj = 'g62bb10lt'; 
files(n).expt = '063016';
files(n).dir = '063016 g62bb10lt GTS behavior\g62bb10lt\'
files(n).compileData ='063016_g62bb10lt_compile.mat';  
files(n).topoXpts = 'topoXsessionV2__allfiles_PTS_dF';
files(n).topoYpts = 'topoYsessionV2__allfiles_PTS_dF';
files(n).behavPts = 'behavSessionV2__allfiles_PTS_dF.mat';
files(n).passive3xPts = 'passiveBehav3x8minV2__allfiles_PTS_dF';
files(n).passive2sfPts = 'passiveBehav2sf8minSessionV2__allfiles_PTS_dF';
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected
