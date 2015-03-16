clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'C:\data\imaging\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'C:\data\imaging\topos\';

n=1;
files(n).subj = 'g62b1lt';
files(n).expt = '012215';
files(n).topox =  '012215 g62b1lt passive viewing\g62b1lt_run8_topoX_Fstop5.6_50ms\g62b1lt_run8_topoX_Fstop5.6_maps.mat';
files(n).topoy = '012215 g62b1lt passive viewing\g62b1lt_run9_topoY_Fstop5.6_50ms\g62b1lt_run9_topoY_Fstop5.6_maps.mat';
files(n).topoxland = '012215 g62b1lt passive viewing\g62b1lt_run4_topoX_landscape_Fstop5.6_50ms\g62b1lt_run4_topoX_landscape_Fstop5.6_maps.mat';
files(n).topoyland = '012215 g62b1lt passive viewing\g62b1lt_run5_topoY_landscape_Fstop5.6_50ms\g62b1lt_run5_topoY_landscape_Fstop5.6_maps.mat';
files(n).grating4x3y6sf3tf = '012215 g62b1lt passive viewing\g62b1lt_run7_4x3ygrating_landscape_Fstop5.6_50ms\g62b1lt_run7_4x3ygrating_landscape_Fstop5.6_maps.mat';
files(n).hello = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y
% 
n=n+1;
files(n).subj = 'g62b1lt';
files(n).expt = '012815';
files(n).topox =  '012815 g62b1lt passive viewing\g62b1lt_run5_topoX_Fstop5.6_50ms\g62b1lt_run5_topoX_Fstop5.6_maps.mat';
files(n).topoy = '012815 g62b1lt passive viewing\g62b1lt_run6_topoY_Fstop5.6_50ms\g62b1lt_run6_topoY_Fstop5.6_maps.mat';
files(n).topoxland = '012815 g62b1lt passive viewing\g62b1lt_run1_topoX_landscape_Fstop5.6_50ms\g62b1lt_run1_topoX_landscape_Fstop5.6_maps.mat';
files(n).topoyland = '012815 g62b1lt passive viewing\g62b1lt_run2_topoY_landscape_Fstop5.6_50ms\g62b1lt_run2_topoY_landscape_Fstop5.6_maps.mat';
files(n).grating4x3y6sf3tf = '012815 g62b1lt passive viewing\g62b1lt_run4_4x3ygrating_landscape_Fstop5.6_50ms\g62b1lt_run4_4x3ygrating_landscape_Fstop5.6_maps.mat';
files(n).hello = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y

n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '012815';
files(n).topox =  '012815 g62b3rt passive viewing\g62b3rt_run6_topoX_Fstop5.6_50ms\g62b3rt_run6_topoX_Fstop5.6_maps.mat';
files(n).topoy = '012815 g62b3rt passive viewing\g62b3rt_run7_topoY_Fstop5.6_50ms\g62b3rt_run7_topoY_Fstop5.6_maps.mat';
files(n).topoxland = '012815 g62b3rt passive viewing\g62b3rt_run_topoX_landscape_Fstop5.6_50ms\g62b3rt_run_topoX_landscape_Fstop5.6_maps.mat';
files(n).topoyland = '012815 g62b3rt passive viewing\g62b3rt_run3_topoY_landscape_Fstop5.6_50ms\g62b3rt_run3_topoY_landscape_Fstop5.6_maps.mat';
files(n).grating4x3y6sf3tf = '012815 g62b3rt passive viewing\g62b3rt_run5_4x3ygrating_landscape_Fstop5.6_50ms\g62b3rt_run5_4x3ygrating_landscape_Fstop5.6_maps.mat';
files(n).hello = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y


n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '012915';
files(n).topox =  '012915 g62b3rt passive\g62b3rt_run5_topoxvertical_fstop5.6_exp50ms\g62b3rt_run5_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy = '012915 g62b3rt passive\g62b3rt_run6_topoyvertical_fstop5.6_exp50ms\g62b3rt_run6_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoxland = '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = '012915 g62b3rt passive\g62b3rt_run1_4x3y_fstop5.6_exp50ms\g62b3rt_run1_4x3y_fstop5.6_exp50ms_maps.mat';
files(n).hello = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y

n=n+1;
files(n).subj = 'g62j4rt';
files(n).expt = '012915';
files(n).topox =  '012915 g62j4rt passive\g62j4rt_run5_topoxvertical_fstop5.6_exp50ms\g62j4rt_run5_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy = '012915 g62j4rt passive\g62j4rt_run6_topoyvertical_fstop5.6_exp50ms\g62j4rt_run6_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoxland = '012915 g62j4rt passive\g62j4rt_run3_topox_fstop5.6_exp50ms\g62j4rt_run3_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoyland = '012915 g62j4rt passive\g62j4rt_run4_topoy_fstop5.6_exp50ms\g62j4rt_run4_topoy_fstop5.6_exp50ms_maps.mat';
files(n).grating4x3y6sf3tf = '012915 g62j4rt passive\g62j4rt_run1_4x3y_fstop5.6_exp50ms\g62j4rt_run1_4x3y_fstop5.6_exp50ms_maps.mat';
files(n).hello = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y