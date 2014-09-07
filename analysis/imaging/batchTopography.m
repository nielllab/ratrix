clear all
close all
dbstop if error
%pathname = 'I:\compiled behavior\';
pathname = 'D:\Widefield (12-10-12+)\data 62713+\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'I:\compiled behavior\behavior topos\';



n=1;

files(n).subj = 'g62j5rt';
files(n).expt = '070714';
files(n).topox =  '070714 G62J5-RT passive viewing\G62J5-RT_run1_topoX_50ms_exp_Fstop11\G62J5-RT_run1_topoX_50ms_exp_Fstop11maps.mat';
files(n).topoxdata = '070714 G62J5-RT passive viewing\G62J5-RT_run1_topoX_50ms_exp_Fstop11\G62J5-RT_run1_topoX_50ms_exp_Fstop11';
files(n).topoy = '070714 G62J5-RT passive viewing\G62J5-RT_run2_topoY_50ms_exp_Fstop11\G62J5-RT_run2_topoY_50ms_exp_Fstop11maps.mat';
files(n).topoydata = '070714 G62J5-RT passive viewing\G62J5-RT_run2_topoY_50ms_exp_Fstop11\G62J5-RT_run2_topoY_50ms_exp_Fstop11';
files(n).behav = '';
files(n).behavdata = '';
files(n).grating = '';
files(n).gratingdata = '';
files(n).stepbinary = '';
files(n).stepbinarydata = '';
files(n).auditory = '';
files(n).auditorydata = '';
files(n).darkness = '';
files(n).darknessdata = '';
files(n).loom = '';
files(n).loomdata = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).spatialfreq = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %no behavior

n=n+1;
files(n).subj = 'g62j4tt';
files(n).expt = '070714';
files(n).topox =  '070714 G62J4-TT passive viewing\G62J4-TT_run1_topoX_50msexp_Fstop11\G62J4-TT_run1_topoX_50msexp_Fstop11maps.mat';
files(n).topoxdata = '070714 G62J4-TT passive viewing\G62J4-TT_run1_topoX_50msexp_Fstop11\G62J4-TT_run1_topoX_50msexp_Fstop11';
files(n).topoy = '070714 G62J4-TT passive viewing\G62J4-TT_run2_topoY_50msexp_Fstop11\G62J4-TT_run2_topoY_50msexp_Fstop11maps.mat';
files(n).topoydata = '070714 G62J4-TT passive viewing\G62J4-TT_run2_topoY_50msexp_Fstop11\G62J4-TT_run2_topoY_50msexp_Fstop11';
files(n).behav = '';
files(n).behavdata = '';
files(n).grating = '';
files(n).gratingdata = '';
files(n).stepbinary = '';
files(n).stepbinarydata = '';
files(n).auditory = '';
files(n).auditorydata = '';
files(n).darkness = '';
files(n).darknessdata = '';
files(n).loom = '';
files(n).loomdata = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).spatialfreq = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %no behavior

n=n+1;
files(n).subj = 'g62e12rt';
files(n).expt = '070314';
files(n).topox =  '070314 G62E12-RT passive viewing\G62E12-RT_run1_topoX_50ms_Fstop11\G62E12-RT_run1_topoX_50ms_Fstop11maps.mat';
files(n).topoxdata = '070314 G62E12-RT passive viewing\G62E12-RT_run1_topoX_50ms_Fstop11\G62E12-RT_run1_topoX_50ms_Fstop11';
files(n).topoy = '070314 G62E12-RT passive viewing\G62E12-RT_run2_topoY_50ms_Fstop11\G62E12-RT_run2_topoY_50ms_Fstop11maps.mat';
files(n).topoydata = '070314 G62E12-RT passive viewing\G62E12-RT_run2_topoY_50ms_Fstop11\G62E12-RT_run2_topoY_50ms_Fstop11';
files(n).behav = '';
files(n).behavdata = '';
files(n).grating = '';
files(n).gratingdata = '';
files(n).stepbinary = '070314 G62E12-RT passive viewing\G62E12-RT_run3_step_binary_50ms_Fstop11\G62E12-RT_run3_step_binary_50ms_Fstop11maps.mat';
files(n).stepbinarydata = '070314 G62E12-RT passive viewing\G62E12-RT_run3_step_binary_50ms_Fstop11\G62E12-RT_run3_step_binary_50ms_Fstop11';
files(n).auditory = '070314 G62E12-RT passive viewing\G62E12-RT_run5_auditory_50ms_Fstop11\G62E12-RT_run5_auditory_50ms_Fstop11maps.mat';
files(n).auditorydata = '070314 G62E12-RT passive viewing\G62E12-RT_run5_auditory_50ms_Fstop11\G62E12-RT_run5_auditory_50ms_Fstop11';
files(n).darkness = '070314 G62E12-RT passive viewing\G62E12-RT_run4_darkness_50ms_Fstop11\G62E12-RT_run4_auditory_50ms_Fstop11maps.mat';
files(n).darknessdata = '070314 G62E12-RT passive viewing\G62E12-RT_run4_darkness_50ms_Fstop11\G62E12-RT_run4_auditory_50ms_Fstop11';
files(n).loom = '';
files(n).loomdata = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).spatialfreq = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

n=n+1;
files(n).subj = 'g62g6lt';
files(n).expt = '070214';
files(n).topox =  '070214 G62G6-LT passive viewing\G62G6-LT_run1_topoX_50ms_exp_Fstop11\G62G6-LT_run1_topoX_50ms_exp_Fstop11maps.mat';
files(n).topoxdata = '070214 G62G6-LT passive viewing\G62G6-LT_run1_topoX_50ms_exp_Fstop11\G62G6-LT_run1_topoX_50ms_exp_Fstop11';
files(n).topoy = '070214 G62G6-LT passive viewing\G62G6-LT_run2_topoY_50ms_exp_Fstop11\G62G6-LT_run2_topoY_50ms_exp_Fstop11maps.mat';
files(n).topoydata = '070214 G62G6-LT passive viewing\G62G6-LT_run2_topoY_50ms_exp_Fstop11\G62G6-LT_run2_topoY_50ms_exp_Fstop11';
files(n).behav = '';
files(n).behavdata = '';
files(n).grating = '';
files(n).gratingdata = '';
files(n).stepbinary = '070214 G62G6-LT passive viewing\G62G6-LT_run3_stepbinary_50ms_exp_Fstop11\G62G6-LT_run3_stepbinary_50ms_exp_Fstop11maps.mat';
files(n).stepbinarydata = '070214 G62G6-LT passive viewing\G62G6-LT_run3_stepbinary_50ms_exp_Fstop11\G62G6-LT_run3_stepbinary_50ms_exp_Fstop11';
files(n).auditory = '';
files(n).auditorydata = '';
files(n).darkness = '';
files(n).darknessdata = '';
files(n).loom = '';
files(n).loomdata = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).spatialfreq = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %no behavior


n=n+1;
files(n).subj = 'g62k2rt';
files(n).expt = '070214';
files(n).topox =  '070217 G62K2-RT passive viewing\G62K2RT_run3_topox_fstop8_exp50ms\G62K2RT_run3_topox_fstop8_exp50msmaps.mat';
files(n).topoxdata = '070217 G62K2-RT passive viewing\G62K2RT_run3_topox_fstop8_exp50ms\G62K2RT_run3_topox_fstop8_exp50ms';
files(n).topoy = '070217 G62K2-RT passive viewing\G62K2RT_run4_topoy_fstop8_exp50ms\G62K2RT_run4_topoy_fstop8_exp50msmaps.mat';
files(n).topoydata = '070217 G62K2-RT passive viewing\G62K2RT_run4_topoy_fstop8_exp50ms\G62K2RT_run4_topoy_fstop8_exp50ms';
files(n).behav = '';
files(n).behavdata = '';
files(n).grating = '';
files(n).gratingdata = '';
files(n).stepbinary = '070217 G62K2-RT passive viewing\G62K2RT_run5_stepbinary_fstop8_exp50ms\G62K2RT_run5_stepbinary_fstop8_exp50msmaps.mat';
files(n).stepbinarydata = '070217 G62K2-RT passive viewing\G62K2RT_run5_stepbinary_fstop8_exp50ms\G62K2RT_run5_stepbinary_fstop8_exp50ms';
files(n).auditory = '';
files(n).auditorydata = '';
files(n).darkness = '';
files(n).darknessdata = '';
files(n).loom = '';
files(n).loomdata = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).spatialfreq = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %no behavior


n=n+1;
files(n).subj = 'g62k1rt';
files(n).expt = '070214';
files(n).topox =  '070214 G62K1-RT passive viewing\G62K1-RT run3_topox_50msexp_fstop8\G62K1-RT run3_topox_50msexp_fstop8maps.mat';
files(n).topoxdata = '070214 G62K1-RT passive viewing\G62K1-RT run3_topox_50msexp_fstop8\G62K1-RT run3_topox_50msexp_fstop8';
files(n).topoy = '070214 G62K1-RT passive viewing\G62K1-RT run4_topoy_50msexp_fstop8\G62K1-RT run4_topoy_50msexp_fstop8maps.mat';
files(n).topoydata = '070214 G62K1-RT passive viewing\G62K1-RT run4_topoy_50msexp_fstop8\G62K1-RT run4_topoy_50msexp_fstop8';
files(n).behav = '';
files(n).behavdata = '';
files(n).grating = '';
files(n).gratingdata = '';
files(n).stepbinary = '070214 G62K1-RT passive viewing\G62K1-RT run5_stepbinary_50msexp_fstop8\G62K1-RT run5_stepbinary_50msexp_fstop8maps.mat';
files(n).stepbinarydata = '070214 G62K1-RT passive viewing\G62K1-RT run5_stepbinary_50msexp_fstop8\G62K1-RT run5_stepbinary_50msexp_fstop8';
files(n).auditory = '';
files(n).auditorydata = '';
files(n).darkness = '';
files(n).darknessdata = '';
files(n).loom = '';
files(n).loomdata = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).spatialfreq = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %no behavior


