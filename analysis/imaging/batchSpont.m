clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'C:\data\imaging\DOI experiments\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'C:\data\imaging\topos\';
n=0;

%%% g62j5rt
n=n+1;
files(n).subj = 'g62j4rt';
files(n).expt = '031915';
files(n).topox =  '031915 g62j4rt doi\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '031915 g62j4rt doi\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoxland='';
files(n).topoyland='';
files(n).spont=  '031915 g62j4rt doi\g62j4rt_postdoi_darkness_fstop5.6_exp50ms\g62j4rt_postdoi_darkness_fstop5.6_exp50ms_maps.mat';
files(n).background3x2yBlank = '031915 g62j4rt doi\g62j4rt_postdoi_background_fstop5.6_exp50ms\g62j4rt_postdoi_background_fstop5.6_exp50ms_maps.mat';
files(n).grating4x3y6sf3tf = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'post';
files(n).monitor = 'vert'; %%% for topox and y


%%% g62j5rt
n=n+1;
files(n).subj = 'g62j4rt';
files(n).expt = '031915';
files(n).topox =  '031915 g62j4rt doi\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '031915 g62j4rt doi\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
files(n).topoxland='';
files(n).topoyland='';
files(n).spont=  '031915 g62j4rt doi\g62j4rt_predoi_darkness_fstop5.6_exp50ms\g62j4rt_predoi_darkness_fstop5.6_exp50ms_maps.mat';
files(n).background3x2yBlank = '031915 g62j4rt doi\g62j4rt_predoi_background_fstop5.6_exp50ms\g62j4rt_predoi_background_fstop5.6_exp50ms_maps.mat'
files(n).grating4x3y6sf3tf = '021815 g62j5rt doi\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'pre';
files(n).monitor = 'vert'; %%% for topox and y
