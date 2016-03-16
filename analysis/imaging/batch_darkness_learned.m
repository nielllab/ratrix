clear all
close all
dbstop if error
pathname = '\\langevin\backup\widefield\';
datapathname = '';  
outpathname = 'C:\Users\nlab\Desktop\data test\';

n=1;
files(n).subj = 'g62r4lt';
files(n).expt = '082914';
files(n).topox =  'passive\082915 G62R4LT Darkness\g62r4lt_run1_topoX\g62r4lt_run1_topoX_maps.mat';
files(n).topoy = 'passive\082915 G62R4LT Darkness\g62r4lt_run2_topoY\g62r4lt_run2_topoY_maps.mat';
files(n).darkness = 'passive\082915 G62R4LT Darkness\g62r4lt_run3_Darkness_16minute\g62r4lt_run3_Darkness_16minute_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

altpathname = '\\langevin\backup\widefield\behavior\';
n=n+1;
files(n).subj = 'g62w4tt'; 
files(n).expt = '091315';
files(n).topox =  'behavior\091315 g62w4tt prebehavior passive1\g62w4tt_run1_portrait_topoX\g62w4tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\091315 g62w4tt prebehavior passive1\g62w4tt_run2_portrait_topoY\g62w4tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\091315 g62w4tt prebehavior passive1\g62w4tt_run6_landscape_Darkness5min\g62w4tt_run6_landscape_Darkness5min_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62w4tt'; 
files(n).expt = '091415';
files(n).topox =  'behavior\091415 g62w4tt prebehavior passive2\g62w4tt_run1_portrait_topoX\g62w4tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\091415 g62w4tt prebehavior passive2\g62w4tt_run2_portrait_topoY\g62w4tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\091415 g62w4tt prebehavior passive2\g62w4tt_run6_landscape_Darkness5min\g62w4tt_run6_landscape_Darkness5min_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62t6lt'; 
files(n).expt = '091615';
files(n).topox =  'behavior\091615 g62t6lt pre-behavior passive1\g62t6lt_run1_portrait_topoX\g62t6lt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\091615 g62t6lt pre-behavior passive1\g62t6lt_run2_portrait_topoY\g62t6lt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\091615 g62t6lt pre-behavior passive1\g62t6lt_run6_landscape_Darkness5min\g62t6lt_run6_landscape_Darkness5min_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62t6lt'; 
files(n).expt = '091715';
files(n).topox =  'behavior\091715 g62t6lt pre-behavior passive2\g62t6lt_run1_portrait_topoX\g62t6lt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\091715 g62t6lt pre-behavior passive2\g62t6lt_run2_portrait_topoY\g62t6lt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\091715 g62t6lt pre-behavior passive2\g62t6lt_run6_landscape_Darknes5min\g62t6lt_run6_landscape_Darknes5min_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62r9tt'; 
files(n).expt = '101015';
files(n).topox =  'behavior\101015 G62R9tt pre-behavior passive 1\g62r9tt_run1_portrait_topoX\g62r9tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\101015 G62R9tt pre-behavior passive 1\g62r9tt_run2_portrait_topoY\g62r9tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101015 G62R9tt pre-behavior passive 1\g62r9tt_run6_landscape_Darkness_5min\g62r9tt_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62r9tt'; 
files(n).expt = '101115';
files(n).topox =  'behavior\101115 G62R9tt pre-behavior passive 2\g62r9tt_run1_portrait_topoX\g62r9tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\101115 G62R9tt pre-behavior passive 2\g62r9tt_run2_portrait_topoY\g62r9tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101115 G62R9tt pre-behavior passive 2\g62r9tt_run6_landscape_Darkness_5min\g62r9tt_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.1tt'; 
files(n).expt = '101115';
files(n).topox =  'behavior\101115 G62Tx1.1tt pre-behavior passive 1\g62Tx1.1tt_run1_portrait_topoX\g62Tx1.1tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\101115 G62Tx1.1tt pre-behavior passive 1\g62Tx1.1tt_run2_portrait_topoY\g62Tx1.1tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101115 G62Tx1.1tt pre-behavior passive 1\g62Tx1.1tt_run6_landscape_Darkness_5min\g62Tx1.1tt_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.1ln'; 
files(n).expt = '101215';
files(n).topox =  'behavior\101215 G62Tx1.1ln pre-behavior passive 1\G62Tx1.1ln_run1_portrait_topoX\G62Tx1.1ln_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\101215 G62Tx1.1ln pre-behavior passive 1\G62Tx1.1ln_run2_portrait_topoY\G62Tx1.1ln_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101215 G62Tx1.1ln pre-behavior passive 1\G62Tx1.1ln_run6_landscape_Darkness_5min\G62Tx1.1ln_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.1tt'; 
files(n).expt = '101215';
files(n).topox =  'behavior\101215 G62Tx1.1tt pre-behavior passive 2\g62Tx1.1tt_run1_portrait_topoX\g62Tx1.1tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\101215 G62Tx1.1tt pre-behavior passive 2\g62Tx1.1tt_run2_portrait_topoY\g62Tx1.1tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101215 G62Tx1.1tt pre-behavior passive 2\g62Tx1.1tt_run6_Darkness_5min\g62Tx1.1tt_run6_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.1ln'; 
files(n).expt = '101315';
files(n).topox =  'behavior\101315 G62Tx1.1ln pre-behavior passive 2\g62Tx1.1ln_run1_topoX\g62Tx1.1ln_run1_topoX_maps.mat';
files(n).topoy = 'behavior\101315 G62Tx1.1ln pre-behavior passive 2\g62Tx1.1ln_run2_portrait_topoY\g62Tx1.1ln_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101315 G62Tx1.1ln pre-behavior passive 2\g62Tx1.1ln_run6_landscape_Darkness_5min\g62Tx1.1ln_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.1tt'; 
files(n).expt = '101315';
files(n).topox =  'behavior\101315 G62Tx1.1tt pre-behavior passive 3\g62Tx1.1tt_run1_portrait_topoX\g62Tx1.1tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\101315 G62Tx1.1tt pre-behavior passive 3\g62Tx1.1tt_run2_portrait_topoY\g62Tx1.1tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\101315 G62Tx1.1tt pre-behavior passive 3\g62Tx1.1tt_run6_landscape_Darkness_5min\g62Tx1.1tt_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.2lt'; 
files(n).expt = '102315';
files(n).topox =  'behavior\102315 G62Tx1.2LT pre-behavior passive 1\g62Tx1.2lt_run1_portrait_topoX\g62Tx1.2lt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'behavior\102315 G62Tx1.2LT pre-behavior passive 1\g62Tx1.2lt_run2_portrait_topoY\g62Tx1.2lt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'behavior\102315 G62Tx1.2LT pre-behavior passive 1\g62Tx1.2lt_run6_landscape_Darkness_5min\g62Tx1.2lt_run6_landscape_Darkness_maps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 



% n=n+1;
% files(n).subj = ''; 
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).darkness = '';
% files(n).task = 'naive';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx2.6lt';
files(n).expt = '122315';
files(n).topox =  'passive\122315 G62Tx2.6LT passive mapping and darkness learned\g62tx2.6lt_run1_portrait_topoX.mat';
files(n).topoy = 'passive\122315 G62Tx2.6LT passive mapping and darkness learned\g62tx2.6lt_run2_portrait_topoY\g62tx2.6lt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'passive\122315 G62Tx2.6LT passive mapping and darkness learned\g62tx2.6lt_run3_landscape_darkness_5min\g62tx2.6lt_run3_landscape_darkness_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx2.6rt';
files(n).expt = '122315';
files(n).topox =  'passive\122315 G62Tx2.6RT passive mapping and darkness learned\g62tx2.6rt_run1_portrait_topoX\g62tx2.6rt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'passive\122315 G62Tx2.6RT passive mapping and darkness learned\g62tx2.6rt_run2_portrait_topoY\g62tx2.6rt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'passive\122315 G62Tx2.6RT passive mapping and darkness learned\g62tx2.6rt_run3_landscape_darkness_5min\g62tx2.6rt_run3_landscape_darkness_maps.mat';
files(n).task = 'HvV';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62r9tt';
files(n).expt = '122315';
files(n).topox =  'passive\122315 G62R9TT passive mapping and darkness learned\g62r9tt_run1_portrait_topoX\g62r9tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'passive\122315 G62R9TT passive mapping and darkness learned\g62r9tt_run2_portrait_topoY\g62r9tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'passive\122315 G62R9TT passive mapping and darkness learned\g62r9tt_run3_landscape_darkness_5min\g62r9tt_run3_landscape_darkness_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62t6lt';
files(n).expt = '122315';
files(n).topox =  'passive\122315 G62T6LT passive mapping and darkness learned\g62t6lt_run1_portrait_topoX\g62t6lt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'passive\122315 G62T6LT passive mapping and darkness learned\g62t6lt_run2_portrait_topoY\g62t6lt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'passive\122315 G62T6LT passive mapping and darkness learned\g62t6lt_run3_landscape_darkness_5min\g62t6lt_run3_landscape_darkness_maps.mat';
files(n).task = 'HvV';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx2.7tt'; 
files(n).expt = '122315';
files(n).topox =  'passive\122315 G62Tx2.7TT passive mapping and darkness naive\g62tx2.7tt_run1_portrait_topoX\g62tx2.7tt_run1_portrait_topoX_maps.mat';
files(n).topoy = 'passive\122315 G62Tx2.7TT passive mapping and darkness naive\g62tx2.7tt_run2_portrait_topoY\g62tx2.7tt_run2_portrait_topoY_maps.mat';
files(n).darkness = 'passive\122315 G62Tx2.7TT passive mapping and darkness naive\g62tx2.7tt_run3_landscape_darkness_5min\g62tx2.7tt_run3_landscape_darkness_maps.mat';
files(n).task = 'naive';
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