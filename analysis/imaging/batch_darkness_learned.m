clear all
close all
dbstop if error
pathname = '\\langevin\backup\widefield\passive\';
datapathname = '';  
outpathname = 'C:\Users\nlab\Desktop\data test\';

n=1;
files(n).subj = 'g62r4lt';
files(n).expt = '082914';
files(n).topox =  '082915 G62R4LT Darkness\g62r4lt_run1_topoX\g62r4lt_run1_topoX_maps.mat';
files(n).topoy = '082915 G62R4LT Darkness\g62r4lt_run2_topoY\g62r4lt_run2_topoY_maps.mat';
files(n).darkness = '082915 G62R4LT Darkness\g62r4lt_run3_Darkness_16minute\g62r4lt_run3_Darkness_16minute_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx2.6lt';
files(n).expt = '122315';
files(n).topox =  '122315 G62Tx2.6LT passive mapping and darkness learned\g62tx2.6lt_run1_portrait_topoX.mat';
files(n).topoy = '122315 G62Tx2.6LT passive mapping and darkness learned\g62tx2.6lt_run2_portrait_topoY\g62tx2.6lt_run2_portrait_topoY_maps.mat';
files(n).darkness = '122315 G62Tx2.6LT passive mapping and darkness learned\g62tx2.6lt_run3_landscape_darkness_5min\g62tx2.6lt_run3_landscape_darkness_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx2.6rt';
files(n).expt = '122315';
files(n).topox =  '122315 G62Tx2.6RT passive mapping and darkness learned\g62tx2.6rt_run1_portrait_topoX\g62tx2.6rt_run1_portrait_topoX_maps.mat';
files(n).topoy = '122315 G62Tx2.6RT passive mapping and darkness learned\g62tx2.6rt_run2_portrait_topoY\g62tx2.6rt_run2_portrait_topoY_maps.mat';
files(n).darkness = '122315 G62Tx2.6RT passive mapping and darkness learned\g62tx2.6rt_run3_landscape_darkness_5min\g62tx2.6rt_run3_landscape_darkness_maps.mat';
files(n).task = 'HvV';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62r9tt';
files(n).expt = '122315';
files(n).topox =  '122315 G62R9TT passive mapping and darkness learned\g62r9tt_run1_portrait_topoX\g62r9tt_run1_portrait_topoX_maps.mat';
files(n).topoy = '122315 G62R9TT passive mapping and darkness learned\g62r9tt_run2_portrait_topoY\g62r9tt_run2_portrait_topoY_maps.mat';
files(n).darkness = '122315 G62R9TT passive mapping and darkness learned\g62r9tt_run3_landscape_darkness_5min\g62r9tt_run3_landscape_darkness_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62t6lt';
files(n).expt = '122315';
files(n).topox =  '122315 G62T6LT passive mapping and darkness learned\g62t6lt_run1_portrait_topoX\g62t6lt_run1_portrait_topoX_maps.mat';
files(n).topoy = '122315 G62T6LT passive mapping and darkness learned\g62t6lt_run2_portrait_topoY\g62t6lt_run2_portrait_topoY_maps.mat';
files(n).darkness = '122315 G62T6LT passive mapping and darkness learned\g62t6lt_run3_landscape_darkness_5min\g62t6lt_run3_landscape_darkness_maps.mat';
files(n).task = 'HvV';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 





% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).darkness = '';
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).monitor = 'vert'; 