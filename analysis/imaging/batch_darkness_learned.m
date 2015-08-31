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
files(n).topox =  '082915 G62R4LT Darkness\g62r4lt_run1_topoX\g62r4lt_run1_topoX_maps.mat';
files(n).topoy = '082915 G62R4LT Darkness\g62r4lt_run2_topoY\g62r4lt_run2_topoY_maps.mat';
files(n).darkness = '082915 G62R4LT Darkness\g62r4lt_run3_Darkness_16minute\g62r4lt_run3_Darkness_16minute_maps.mat';
files(n).task = 'GTS';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).monitor = 'vert'; 

% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).darkness = ''
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).monitor = 'vert'; 