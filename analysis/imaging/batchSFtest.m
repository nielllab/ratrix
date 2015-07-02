%batchLearningBehav    JW 3/4/15

clear all
close all
dbstop if error
pathname = '\\lorentz\backup\widefield\passive\'; %for Maxwell
datapathname = 'N:backup/data to analyze/';  %for Maxwell
outpathname = 'N:\widefield\compiled behavior\behavior topos\';

n=0;

n=n+1;
files(n).subj = 'g62a4tt'; 
files(n).expt = '063015';
files(n).topox =  '063015 g62a4tt passive SF test behaveStim\g62a4tt_run1_portrait_topoX\g62a4tt_run1_portrait_topoX_maps.mat';
files(n).topoxdata = '';
files(n).topoy = '063015 g62a4tt passive SF test behaveStim\g62a4tt_run2_portrait_topoY\g62a4tt_run2_portrait_topoY_maps.mat';
files(n).topoydata = '';
files(n).behavstim2sf = '063015 g62a4tt passive SF test behaveStim\g62a4tt_run3_portrait_behavStim2sf\g62a4tt_run3_portrait_behavStim2sf_maps.mat';
files(n).behavstim3x4orient = '063015 g62a4tt passive SF test behaveStim\g62a4tt_run4_portrait_behavStim3x4orient\g62a4tt_run4_portrait_behavStim3x4orient_maps.mat';
files(n).behavstim2sfLOW = '063015 g62a4tt passive SF test behaveStim\g62a4tt_run5_portrait_behavStim2sf_LOW\g62a4tt_run5_portrait_behavStim2sf_LOW_maps.mat';
files(n).behavstim3x4orientLOW = '063015 g62a4tt passive SF test behaveStim\g62a4tt_run6_portrait_behavStim3x4Orient_LOW\g62a4tt_run6_portrait_behavStim3x4Orient_LOW_maps.mat';
files(n).monitor = 'vert';
files(n).task = 'GTS';
files(n).learningDay = '5';
files(n).spatialfreq = '200';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

