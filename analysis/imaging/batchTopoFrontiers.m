clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'C:\data\imaging\DOI experiments\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'C:\data\imaging\topos\';
n=0;

%%% g62l1lt
n=n+1;
files(n).subj = 'g62l1lt';
files(n).expt = '021915a';
files(n).topox =  '021915 G62L1lt doi\g62l1lt_predoi_topoxvertical_fstop5.6_exp50ms\g62l1lt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '021915 G62L1lt doi\g62l1lt_predoi_topoyvertical_fstop5.6_exp50ms\g62l1lt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y

%%% g62j5rt
n=n+1;
files(n).subj = 'g62j5rt';
files(n).expt = '021815a';
files(n).topox =  '021815 g62j5rt doi\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '021815 g62j5rt doi\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = '021815 g62j5rt doi\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'pre';
files(n).monitor = 'vert'; %%% for topox and y
% 

%%%g62k2rt
n=n+1;
files(n).subj = 'g62k2rt';
files(n).expt = '021815a';
files(n).topox =  '021815 g62k2rt saline\g62k2rt_predoi_topoxvertical_fstop5.6_exp50ms\g62k2rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy = '021815 g62k2rt saline\g62k2rt_predoi_topoyvertical_fstop5.6_exp50ms\g62k2rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y


% 

n=n+1;
files(n).subj = 'g62l1lt';
files(n).expt = '021715a';
files(n).topox =  '021715 g62l1lt saline\g62l1lt_predoi_topoxvertical_fstop5.6_exp50ms\g62l1lt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy = '021715 g62l1lt saline\g62l1lt_predoi_topoyvertical_fstop5.6_exp50ms\g62l1lt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y


%%% g62b3rt
n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '021415a';
files(n).topox =  '021415 g62b3rt doi\g62b3rt_predoi_topox_fstop5.6_exp50ms\g62b3rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '021415 g62b3rt doi\g62b3rt_predoi_topoy_fstop5.6_exp50ms\g62b3rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = '021415 g62b3rt doi\g62b3rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62b3rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'pre';
files(n).monitor = 'vert'; %%% for topox and y



%%%%%%%

%%% g62j4rt 021215
%%% good session

n=n+1;
files(n).subj = 'g62j4rt';
files(n).expt = '021215a';
files(n).topox =  '021215 g62j4rt doi passive\g62j4rt_predoi_topox_fstop5.6_exp50ms\g62j4rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '021215 g62j4rt doi passive\g62j4rt_predoi_topoy_fstop5.6_exp50ms\g62j4rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = '021215 g62j4rt doi passive\g62j4rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j4rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'pre';
files(n).monitor = 'vert'; %%% for topox and y

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%g62j5rt 021115
%%% probably didn't get full dose

n=n+1;

files(n).subj = 'g62j5rt';
files(n).expt = '021115a';
files(n).topox =  '021115 g62j5rt doi passive\g62j5rt_predoi_topox_fstop5.6_exp50ms\g62j5rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '021115 g62j5rt doi passive\g62j5rt_predoi_topoy_fstop5.6_exp50ms\g62j5rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = '021115 g62j5rt doi passive\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'pre';
files(n).monitor = 'vert'; %%% for topox and y

n=n+1;
files(n).subj = 'g62b1rt';
files(n).expt = '020615a';
files(n).topox =  '020615 g62b1rt doi passive\g62b1rt_predoi_topox_fstop5.6_exp50ms\g62b1rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '020615 g62b1rt doi passive\g62b1rt_predoi_topoy_fstop5.6_exp50ms\g62b1rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'bad imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y
% 

n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '020615a';
files(n).topox =  '020615 g62b3rt doi passive\g62b3rt_predoi_topox_fstop5.6_exp50ms\g62b3rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '020615 g62b3rt doi passive\g62b3rt_predoi_topoy_fstop5.6_exp50ms\g62b3rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% 
% files(n).subj = 'g62j4rt';
% files(n).expt = '020515a';
% files(n).topox =  '020515 g62j4rt doi passive\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j4rt doi passive\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
n=n+1;
files(n).subj = 'g62j5rt';
files(n).expt = '020515a';
files(n).topox =  '020515 g62j5rt doi passive\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '020515 g62j5rt doi passive\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y
% 
n=n+1;
files(n).subj = 'g622jrt';
files(n).expt = '012915a';
files(n).topox =  'older\012915 g62j4rt passive\g62j4rt_run5_topoxvertical_fstop5.6_exp50ms\g62j4rt_run5_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  'older\012915 g62j4rt passive\g62j4rt_run6_topoyvertical_fstop5.6_exp50ms\g62j4rt_run6_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y


n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '012915a';
files(n).topox =  'older\012915 g62b3rt passive\g62b3rt_run5_topoxvertical_fstop5.6_exp50ms\g62b3rt_run5_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  'older\012915 g62b3rt passive\g62b3rt_run6_topoyvertical_fstop5.6_exp50ms\g62b3rt_run6_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y

n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '012815a';
files(n).topox =  'older\012815 g62b3rt passive viewing\g62b3rt_run6_topoX_Fstop5.6_50ms\g62b3rt_run6_topoX_Fstop5.6_maps.mat';
files(n).topoy =  'older\012815 g62b3rt passive viewing\g62b3rt_run7_topoY_Fstop5.6_50ms\g62b3rt_run7_topoY_Fstop5.6_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; %%% for topox and y

n=n+1;
files(n).subj = 'g62j4rt';
files(n).expt = '011615a';
files(n).topox =  'older\011615 g62j4rt passive viewing\g62j4rt_run1_fstop5.6_exp50ms_topox\g62j4rt_run1_fstop5.6_exp50ms_topox_maps.mat';
files(n).topoy =  'older\011615 g62j4rt passive viewing\g62j4rt_run2_fstop5.6_exp50ms_topoy\g62j4rt_run2_fstop5.6_exp50ms_topoy_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'looks like landscape mode'; 
files(n).monitor = 'vert'; %%% for topox and y


% 
