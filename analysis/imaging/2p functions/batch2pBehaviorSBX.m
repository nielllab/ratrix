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
files(n).compileData ='063016 g62bb10lt GTS behavior\g62bb10lt\063016_g62bb10lt_compile.mat';   %%% only need this one for now ...
files(n).topoXpts = '';
files(n).topoYpts = '';
files(n).behavPts = '';
files(n).passive3xPts = '';
files(n).passive2sfPts = '';
files(n).task = 'GTS';
files(n).learningDay = [];   %%% can probably ignore for GTS, more important for naive
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).ncells = [];  %%% optional - we could use this to adjust # of cells selected
