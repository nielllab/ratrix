clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'C:\data\imaging\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'C:\data\imaging\topos\';

n=1;
files(n).subj = 'g62r4lt';
files(n).expt = '082914';
files(n).topox =  '082915 G62R4LT BackgroundGratings_3x2y2sf\g62r4lt_run2_topoX\g62r4lt_run2_topoX_maps.mat';
files(n).topoy = '082915 G62R4LT BackgroundGratings_3x2y2sf\g62r4lt_run3_topoY\g62r4lt_run3_topoY_maps.mat';
files(n).background_3x2y2sf = '082915 G62R4LT BackgroundGratings_3x2y2sf\g62r4lt_run4_BackgroundGratings_3x2y2sf\g62r4lt_run4_darkness_16min_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).background_3x2y2sf = '';
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).monitor = 'vert'; 