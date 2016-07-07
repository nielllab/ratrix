clear all
close all
dbstop if error
pathname = '\\langevin\backup\widefield\';
datapathname = '\\langevin\backup\widefield\';  
outpathname = 'C:\Users\nlab\Desktop\data test\';
altpathname = '\\langevin\backup\widefield\behavior\';
n=0;

%%%execute the shit above here first.

%then select the sessions you need to run

%then execute batchDfofMovie  (make sure the right set of stims are
%commented/uncommented)



n=1;
files(n).subj = 'g62r4lt';
files(n).expt = '082914';
files(n).topox =  'passive\082915 G62R4LT Darkness\g62r4lt_run1_topoX\g62r4lt_run1_topoX_maps.mat';
files(n).topoy = 'passive\082915 G62R4LT Darkness\g62r4lt_run2_topoY\g62r4lt_run2_topoY_maps.mat';
files(n).darkness = 'passive\082915 G62R4LT Darkness\g62r4lt_run3_Darkness_16minute\g62r4lt_run3_Darkness_16minute_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %darkness session was 16 min
files(n).monitor = 'vert'; 


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

n=n+1;
files(n).subj = 'g62w10tt';
files(n).expt = '022216';
files(n).topox =  'passive\022216 G6W10TT passive mapping and darkness learned\g62w10tt_run1_portrait_topoX\g62w10tt_run1_portrait_topmaps.mat';
files(n).topoy = 'passive\022216 G6W10TT passive mapping and darkness learned\g62w10tt_run2_portrait_topoY\g62w10tt_run2_portrait_topmaps.mat';
files(n).darkness = 'passive\022216 G6W10TT passive mapping and darkness learned\g62w10tt_run3_portrait_darkness_5min\g62w10tt_run3_portrait_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62y3lt';
files(n).expt = '031016';
files(n).topox =  'passive\031016 G62Y3LT passive mapping and darkness learned\g62y3lt_portrait_run1_topoX\g62y3lt_portrait_run1_topmaps.mat';
files(n).topoy = 'passive\031016 G62Y3LT passive mapping and darkness learned\g62y3lt_portrait_run2_topoY\g62y3lt_portrait_run2_topmaps.mat';
files(n).darkness = 'passive\031016 G62Y3LT passive mapping and darkness learned\g62y3lt_portrait_run3_darkness\g62y3lt_portrait_run3_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62w9rt';
files(n).expt = '031016';
files(n).topox =  'passive\031016 G62W9RT passive mapping and darkness learned\g62w9rt_portrait_run1_topoX\g62w9rt_portrait_run1_topmaps.mat';
files(n).topoy = 'passive\031016 G62W9RT passive mapping and darkness learned\g62w9rt_portrait_run2_topoY\g62w9rt_portrait_run2_topmaps.mat';
files(n).darkness = 'passive\031016 G62W9RT passive mapping and darkness learned\g62w9rt_portrait_run3_darkness\g62w9rt_portrait_run3_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.5lt';
files(n).expt = '031016';
files(n).topox =  'passive\031016 G62Tx15LT passive mapping and darkness learned\g62tx15tt_portrait_run1_topoX\g62tx15tt_portrait_run1_topmaps.mat';
files(n).topoy = 'passive\031016 G62Tx15LT passive mapping and darkness learned\g62tx15tt_portrait_run3_topoY\g62tx15tt_portrait_run3_topmaps.mat';
files(n).darkness = 'passive\031016 G62Tx15LT passive mapping and darkness learned\g62tx15tt_portrait_run4_darkness_5min\g62tx15tt_portrait_run4_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd2ln';
files(n).expt = '031016';
files(n).topox =  'passive\031016 G62DD2LN passive mapping and darkness learned\g62dd2ln_portrait_run1_topoX\g62dd2ln_portrait_run1_topmaps.mat';
files(n).topoy = 'passive\031016 G62DD2LN passive mapping and darkness learned\g62dd2ln_portrait_run2_topoY\g62dd2ln_portrait_run2_topmaps.mat';
files(n).darkness = 'passive\031016 G62DD2LN passive mapping and darkness learned\g62dd2ln_portrait_run3_darkness\g62dd2ln_portrait_run3_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62bb12lt';
files(n).expt = '042716';
files(n).topox =  'passive\042716 G62BB12LT passive mapping and darkness naive\g62bb12lt_portrait_run1_topoX\g62bb12lt_portrait_run1_topmaps.mat';
files(n).topoy = 'passive\042716 G62BB12LT passive mapping and darkness naive\g62bb12lt_portrait_run2_topoY\g62bb12lt_portrait_run2_topmaps.mat';
files(n).darkness = 'passive\042716 G62BB12LT passive mapping and darkness naive\g62bb12lt_portrait_run3_darkness5min_naive\g62bb12lt_portrait_run3_darkness5min_naimaps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62bb12tt';
files(n).expt = '050216';
files(n).topox =  'passive\050216 G62BB12TT passive mapping and darkness naive\g62bb12tt_portrait_run1_topoX\g62bb12tt_portrait_run1_topmaps.mat';
files(n).topoy = 'passive\050216 G62BB12TT passive mapping and darkness naive\g62bb12tt_portrait_run2_topoY\g62bb12tt_portrait_run2_topmaps.mat';
files(n).darkness = 'passive\050216 G62BB12TT passive mapping and darkness naive\g62bb12tt_portrait_run3_darkness_5min\g62bb12tt_portrait_run3_darknemaps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx2.11lt';
files(n).expt = '051916';
files(n).topox =  'passive\051916 G62Tx2.11-LT passive mapping and darkness learned\g62Tx2.11lt_run1_portrait_topoXg62Tx2.11lt_run1_portrait_topmaps.mat';
files(n).topoy = 'passive\051916 G62Tx2.11-LT passive mapping and darkness learned\g62Tx2.11lt_run2_portrait_topoYg62Tx2.11lt_run2_portrait_topmaps.mat';
files(n).darkness = 'passive\051916 G62Tx2.11-LT passive mapping and darkness learned\g62Tx2.11lt_run3_portrait_darkness_5ming62Tx2.11lt_run3_portrait_darknemaps.mat';
files(n).task = 'HvV';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd2';
files(n).expt = '052616';
files(n).topox =  'passive\052616 G62DD5 passive mapping and darkness learned\g62dd5_run1_portrait_topoX\g62dd5_run1_portrait_topmaps.mat';
files(n).topoy = 'passive\052616 G62DD5 passive mapping and darkness learned\g62dd5_run2_portrait_topoY\g62dd5_run2_portrait_topmaps.mat';
files(n).darkness = 'passive\052616 G62DD5 passive mapping and darkness learned\g62dd5_run3_portrait_derkness_5min\g62dd5_run3_portrait_derknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62jj1lt';
files(n).expt = '060116';
files(n).topox =  'passive\060116 G62JJ1Lt passive mapping and darkness naive\g62jj1lt_run3_portrait_topoX\g62jj1lt_run3_portrait_topmaps.mat';
files(n).topoy = 'passive\060116 G62JJ1Lt passive mapping and darkness naive\g62jj1lt_run2_portrait_topoY\g62jj1lt_run2_portrait_topmaps.mat';
files(n).darkness = 'passive\060116 G62JJ1Lt passive mapping and darkness naive\g62jj1lt_run4_portrait_darkness_5min\g62jj1lt_run4_portrait_darknemaps.mat';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62tx1.5lt';
files(n).expt = '060116';
files(n).topox =  'passive\060116 G62Tx15Lt passive mapping and darkness learned GTS\g62tx15lt_run1_portrait_topoX\g62tx15lt_run1_portrait_topmaps.mat';
files(n).topoy = 'passive\060116 G62Tx15Lt passive mapping and darkness learned GTS\g62tx15lt_run2_portrait_topoY\g62tx15lt_run2_portrait_topmaps.mat';
files(n).darkness = 'passive\060116 G62Tx15Lt passive mapping and darkness learned GTS\g62tx15lt_run3_portrait_darkness_5min\g62tx15lt_run3_portrait_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd2ln';
files(n).expt = '062016';
files(n).topox =  'passive\062016 G62dd2ln passive test greg\g62dd2ln_portrait_run1_topoXtest\g62dd2ln_portrait_run1_topoXtemaps.mat';
files(n).topoxdata = 'passive\062016 G62dd2ln passive test greg\g62dd2ln_portrait_run1_topoXtest\g62dd2ln_portrait_run1_topoXtest';
files(n).topoy = 'passive\062016 G62dd2ln passive test greg\g62dd2ln_portrait_run2_topoYtest\g62dd2ln_portrait_run2_topoYtemaps.mat';
files(n).darkness = 'passive\062016 G62dd2ln passive test greg\g62dd2ln_portrait_run3_darkness_5min\g62dd2ln_portrait_run3_darknemaps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62y3lt';
files(n).expt = '062016';
files(n).topox =  'passive\062016 G62y3lt passive mapping darkness\g62y3lt_portrait_run1_topoX\g62y3lt_portrait_run1_topoXmaps.mat';
files(n).topoxdata = 'passive\062016 G62y3lt passive mapping darkness\g62y3lt_portrait_run1_topoX\g62y3lt_portrait_run1_topoX';
files(n).topoy = 'passive\062016 G62y3lt passive mapping darkness\g62y3lt_portrait_run2_topoY\g62y3lt_portrait_run2_topoYmaps.mat';
files(n).topoydata = 'passive\062016 G62y3lt passive mapping darkness\g62y3lt_portrait_run2_topoY\g62y3lt_portrait_run2_topoY';
files(n).darkness = 'passive\062016 G62y3lt passive mapping darkness\g62y3lt_portrait_run3_darkness_5min\g62y3lt_portrait_run3_darknessmaps.mat';
files(n).darknessdata = 'passive\062016 G62y3lt passive mapping darkness\g62y3lt_portrait_run3_darkness_5min\g62y3lt_portrait_run3_darkness';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62bb10lt';
files(n).expt = '062916';
files(n).topox =  'passive\062916 G62bb10lt mapping and darkness learned\g62bb10lt_portrait_run1_topoX\g62bb10lt_portrait_run1_topmaps.mat';
files(n).topoxdata = 'passive\062916 G62bb10lt mapping and darkness learned\g62bb10lt_portrait_run1_topoX\g62bb10lt_portrait_run1_topoX';
files(n).topoy = 'passive\062916 G62bb10lt mapping and darkness learned\g62bb10lt_portrait_run2_topoY\g62bb10lt_portrait_run2_topmaps.mat';
files(n).topoydata = 'passive\062916 G62bb10lt mapping and darkness learned\g62bb10lt_portrait_run2_topoY\g62bb10lt_portrait_run2_topoY';
files(n).darkness = 'passive\062916 G62bb10lt mapping and darkness learned\g62bb10lt_portrait_run3_darkness_5min\g62bb10lt_portrait_run3_darknemaps.mat';
files(n).darknessdata = 'passive\062916 G62bb10lt mapping and darkness learned\g62bb10lt_portrait_run3_darkness_5min\g62bb10lt_portrait_run3_darkness';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd6lt';
files(n).expt = '062916';
files(n).topox =  'passive\062916 g62dd6lt passive mapping\g62dd6lt_run1_portrait_topoX\g62dd6lt_run1_portrait_topmaps.mat'; %no running data
files(n).topoxdata = 'passive\062916 g62dd6lt passive mapping\g62dd6lt_run1_portrait_topoX\g62dd6lt_run1_portrait_topoX';
files(n).topoy = 'passive\062916 g62dd6lt passive mapping\g62dd6lt_run2_portrait_topoY\g62dd6lt_run2_portrait_topmaps.mat';
files(n).topoydata = 'passive\062916 g62dd6lt passive mapping\g62dd6lt_run2_portrait_topoY\g62dd6lt_run2_portrait_topoY';
files(n).darkness = 'passive\062916 g62dd6lt passive mapping\g62dd6lt_run3_portrait_darkness_5min\g62dd6lt_run3_portrait_darknemaps.mat';
files(n).darknessdata = 'passive\062916 g62dd6lt passive mapping\g62dd6lt_run3_portrait_darkness_5min\g62dd6lt_run3_portrait_darkness';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'not good imaging session.  still recovering from surgery. maps look a little funny'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62ff8rt';
files(n).expt = '062916';
files(n).topox =  'passive\062916 G62FF8RT PASSIVE MAPPING\g62ff8rt_run1_portrait_topoX\g62ff8rt_run1_portrait_topmaps.mat';
files(n).topoxdata = 'passive\062916 G62FF8RT PASSIVE MAPPING\g62ff8rt_run1_portrait_topoX\g62ff8rt_run1_portrait_topoX';
files(n).topoy = 'passive\062916 G62FF8RT PASSIVE MAPPING\g62ff8rt_run2_portrait_topoY\g62ff8rt_run2_portrait_topmaps.mat';
files(n).topoydata = 'passive\062916 G62FF8RT PASSIVE MAPPING\g62ff8rt_run2_portrait_topoY\g62ff8rt_run2_portrait_topoY';
files(n).darkness = 'passive\062916 G62FF8RT PASSIVE MAPPING\g62ff8rt_run3_portrait_darkness_5min\g62ff8rt_run3_portrait_darknemaps.mat';
files(n).darknessdata = 'passive\062916 G62FF8RT PASSIVE MAPPING\g62ff8rt_run3_portrait_darkness_5min\g62ff8rt_run3_portrait_darkness';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd2ln';
files(n).expt = '063016';
files(n).topox =  '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness = '';
files(n).darknessdata = 'behavior\063016 G62dd2ln GTS behavior\g62dd2ln_portrait_run7_darkness\g62dd2ln_portrait_run7_darkness';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd11lt';
files(n).expt = '070616';
files(n).topox =  '';
files(n).topoxdata = 'passive\070616 G62dd11lt passive mapping and darkness\g62dd11lt_portrait_run1_topoX\g62dd11lt_portrait_run1_topoX';
files(n).topoy = '';
files(n).topoydata = 'passive\070616 G62dd11lt passive mapping and darkness\g62dd11lt_portrait_run2_topoY\g62dd11lt_portrait_run2_topoY';
files(n).darkness = '';
files(n).darknessdata = 'passive\070616 G62dd11lt passive mapping and darkness\g62dd11lt_portrait_run3_darkness_5min\g62dd11lt_portrait_run3_darkness';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62cc13lt';
files(n).expt = '070616';
files(n).topox =  '';
files(n).topoxdata = 'passive\070616 G62cc13lt passive mapping and darkness\g62cc13lt_portrait_run1_topoX\g62cc13lt_portrait_run1_topoX';
files(n).topoy = '';
files(n).topoydata = 'passive\070616 G62cc13lt passive mapping and darkness\g62cc13lt_portrait_run2_topoY\g62cc13lt_portrait_run2_topoY';
files(n).darkness = '';
files(n).darknessdata = 'passive\070616 G62cc13lt passive mapping and darkness\g62cc13lt_portrait_run3_darkness_5min\g62cc13lt_portrait_run3_darkness';
files(n).task = 'naive';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

n=n+1;
files(n).subj = 'g62dd6lt';
files(n).expt = '070616';
files(n).topox =  '';
files(n).topoxdata = 'passive\070616 G62dd6lt passive mapping and darkness\g62dd6_portrait_run1_topoX\g62dd6_portrait_run1_topoX';
files(n).topoy = '';
files(n).topoydata = 'passive\070616 G62dd6lt passive mapping and darkness\g62dd6_portrait_run2_topoY\g62dd6_portrait_run2_topoY';
files(n).darkness = '';
files(n).darknessdata = 'passive\070616 G62dd6lt passive mapping and darkness\g62dd6_portrait_run3_darkness_5min\g62dd6_portrait_run3_darkness';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 





% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoxdata = '';
% files(n).topoy = '';
% files(n).topoydata = '';
% files(n).darkness = '';
% files(n).darknessdata = '';
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).monitor = 'vert'; 