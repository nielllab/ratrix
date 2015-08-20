clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'data\imaging\DOI experiments\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'data\imaging\topos\';
n=0;

%%% g62j5rt
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021815a';
% files(n).topox =  '021815 g62j5rt doi\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021815 g62j5rt doi\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021815 g62j5rt doi\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021815b';
% files(n).topox =  '021815 g62j5rt doi\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021815 g62j5rt doi\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021815 g62j5rt doi\g62j5rt_predoi_4x3y(2)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021815c';
% files(n).topox =  '021815 g62j5rt doi\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021815 g62j5rt doi\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021815 g62j5rt doi\g62j5rt_doi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021815d';
% files(n).topox =  '021815 g62j5rt doi\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021815 g62j5rt doi\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021815 g62j5rt doi\g62j5rt_doi_4x3y(2)_fstop5.6_exp50ms\g62j5rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
%%% g62b3r
% n=n+1;
% files(n).subj = 'g62b3rt';
% files(n).expt = '021415a';
% files(n).topox =  '021415 g62b3rt doi\g62b3rt_predoi_topox_fstop5.6_exp50ms\g62b3rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021415 g62b3rt doi\g62b3rt_predoi_topoy_fstop5.6_exp50ms\g62b3rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021415 g62b3rt doi\g62b3rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62b3rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y

n=n+1;
files(n).subj = 'g62b3rt';
files(n).expt = '021415b';
files(n).topox =  '021415 g62b3rt doi\g62b3rt_predoi_topox_fstop5.6_exp50ms\g62b3rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  '021415 g62b3rt doi\g62b3rt_predoi_topoy_fstop5.6_exp50ms\g62b3rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = '021415 g62b3rt doi\g62b3rt_predoi_4x3y(2)_fstop5.6_exp50ms\g62b3rt_predoi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).doi = 'pre';
files(n).monitor = 'vert'; %%% for topox and y

% n=n+1;
% files(n).subj = 'g62b3rt';
% files(n).expt = '021415c';
% files(n).topox =  '021415 g62b3rt doi\g62b3rt_predoi_topox_fstop5.6_exp50ms\g62b3rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021415 g62b3rt doi\g62b3rt_predoi_topoy_fstop5.6_exp50ms\g62b3rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021415 g62b3rt doi\g62b3rt_doi_4x3y(1)_fstop5.6_exp50ms\g62b3rt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62b3rt';
% files(n).expt = '021415d';
% files(n).topox =  '021415 g62b3rt doi\g62b3rt_predoi_topox_fstop5.6_exp50ms\g62b3rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021415 g62b3rt doi\g62b3rt_predoi_topoy_fstop5.6_exp50ms\g62b3rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021415 g62b3rt doi\g62b3rt_doi_4x3y(2)_fstop5.6_exp50ms\g62b3rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
% %%%%%%%
% 
% %%% g62j4rt 021215
% %%% good session
% 
% n=n+1;
% files(n).subj = 'g62j4rt';
% files(n).expt = '021215a';
% files(n).topox =  '021215 g62j4rt doi passive\g62j4rt_predoi_topox_fstop5.6_exp50ms\g62j4rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62j4rt doi passive\g62j4rt_predoi_topoy_fstop5.6_exp50ms\g62j4rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62j4rt doi passive\g62j4rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j4rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j4rt';
% files(n).expt = '021215b';
% files(n).topox =  '021215 g62j4rt doi passive\g62j4rt_predoi_topox_fstop5.6_exp50ms\g62j4rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62j4rt doi passive\g62j4rt_predoi_topoy_fstop5.6_exp50ms\g62j4rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62j4rt doi passive\g62j4rt_predoi_4x3y(2)_fstop5.6_exp50ms\g62j4rt_predoi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y

% n=n+1;
% 
% files(n).subj = 'g62j4rt';
% files(n).expt = '021215c';
% files(n).topox =  '021215 g62j4rt doi passive\g62j4rt_predoi_topox_fstop5.6_exp50ms\g62j4rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62j4rt doi passive\g62j4rt_predoi_topoy_fstop5.6_exp50ms\g62j4rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62j4rt doi passive\g62j4rt_doi_4x3y(1)_fstop5.6_exp50ms\g62j4rt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% 
% files(n).subj = 'g62j4rt';
% files(n).expt = '021215d';
% files(n).topox =  '021215 g62j4rt doi passive\g62j4rt_predoi_topox_fstop5.6_exp50ms\g62j4rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62j4rt doi passive\g62j4rt_predoi_topoy_fstop5.6_exp50ms\g62j4rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62j4rt doi passive\g62j4rt_doi_4x3y(2)_fstop5.6_exp50ms\g62j4rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%g62j5rt 021115
%%% probably didn't get full dose

% n=n+1;
% 
% files(n).subj = 'g62j5rt';
% files(n).expt = '021115a';
% files(n).topox =  '021115 g62j5rt doi passive\g62j5rt_predoi_topox_fstop5.6_exp50ms\g62j5rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021115 g62j5rt doi passive\g62j5rt_predoi_topoy_fstop5.6_exp50ms\g62j5rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021115 g62j5rt doi passive\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
% % 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021115b';
% files(n).topox =  '021115 g62j5rt doi passive\g62j5rt_predoi_topox_fstop5.6_exp50ms\g62j5rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021115 g62j5rt doi passive\g62j5rt_predoi_topoy_fstop5.6_exp50ms\g62j5rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021115 g62j5rt doi passive\g62j5rt_predoi_4x3y(2)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021115c';
% files(n).topox =  '021115 g62j5rt doi passive\g62j5rt_predoi_topox_fstop5.6_exp50ms\g62j5rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021115 g62j5rt doi passive\g62j5rt_predoi_topoy_fstop5.6_exp50ms\g62j5rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021115 g62j5rt doi passive\g62j5rt_doi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '021115d';
% files(n).topox =  '021115 g62j5rt doi passive\g62j5rt_predoi_topox_fstop5.6_exp50ms\g62j5rt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021115 g62j5rt doi passive\g62j5rt_predoi_topoy_fstop5.6_exp50ms\g62j5rt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021115 g62j5rt doi passive\g62j5rt_doi_4x3y(2)_fstop5.6_exp50ms\g62j5rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y


% files(n).subj = 'g62j4rt';
% files(n).expt = '020515a';
% files(n).topox =  '020515 g62j4rt doi passive\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j4rt doi passive\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '\020515 g62j4rt doi passive\g62j4rt_predoi_4x3y(1)_fstop5.6_exp50ms\g62j4rt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% % 
% n=n+1;
% files(n).subj = 'g62j4rt';
% files(n).expt = '020515b';
% files(n).topox =  '020515 g62j4rt doi passive\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j4rt doi passive\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '020515 g62j4rt doi passive\g62j4rt_doi_4x3y(1)_fstop5.6_exp50ms\g62j4rt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j4rt';
% files(n).expt = '020515c';
% files(n).topox =  '020515 g62j4rt doi passive\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j4rt doi passive\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j4rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '020515 g62j4rt doi passive\g62j4rt_doi_4x3y(2)_fstop5.6_exp50ms\g62j4rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '020515a';
% files(n).topox =  '020515 g62j5rt doi passive\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j5rt doi passive\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '020515 g62j4rt doi passive\g62j4rt_doi_4x3y(2)_fstop5.6_exp50ms\g62j4rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '020515b';
% files(n).topox =  '020515 g62j5rt doi passive\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j5rt doi passive\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '020515 g62j5rt doi passive\g62j5rt_predoi_4x3y(2)_fstop5.6_exp50ms\g62j5rt_predoi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '020515c';
% files(n).topox =  '020515 g62j5rt doi passive\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j5rt doi passive\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '020515 g62j5rt doi passive\g62j5rt_doi_4x3y(1)_fstop5.6_exp50ms\g62j5rt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% files(n).subj = 'g62j5rt';
% files(n).expt = '020515d';
% files(n).topox =  '020515 g62j5rt doi passive\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoxvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoy = '020515 g62j5rt doi passive\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms\g62j5rt_predoi_topoyvertical_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '020515 g62j5rt doi passive\g62j5rt_doi_4x3y(2)_fstop5.6_exp50ms\g62j5rt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y

% files(n).subj = 'g62b1lt';
% files(n).expt = '021215a';
% files(n).topox =  '021215 g62b1lt doi passive\g62b1lt_predoi_topox_fstop5.6_exp50ms\g62b1lt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62b1lt doi passive\g62b1lt_predoi_topoy_fstop5.6_exp50ms\g62b1lt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62b1lt doi passive\g62b1lt_predoi_4x3y(1)_fstop5.6_exp50ms\g62b1lt_predoi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'something bad happened at beginning'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y


% n=n+1;
% files(n).subj = 'g62b1lt';
% files(n).expt = '021215b';
% files(n).topox =  '021215 g62b1lt doi passive\g62b1lt_predoi_topox_fstop5.6_exp50ms\g62b1lt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62b1lt doi passive\g62b1lt_predoi_topoy_fstop5.6_exp50ms\g62b1lt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62b1lt doi passive\g62b1lt_predoi_4x3y(2)_fstop5.6_exp50ms\g62b1lt_predoi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% 
% files(n).subj = 'g62b1lt';
% files(n).expt = '021215c';
% files(n).topox =  '021215 g62b1lt doi passive\g62b1lt_predoi_topox_fstop5.6_exp50ms\g62b1lt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62b1lt doi passive\g62b1lt_predoi_topoy_fstop5.6_exp50ms\g62b1lt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62b1lt doi passive\g62b1lt_doi_4x3y(1)_fstop5.6_exp50ms\g62b1lt_doi_4x3y(1)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% 
% files(n).subj = 'g62b1lt';
% files(n).expt = '021215d';
% files(n).topox =  '021215 g62b1lt doi passive\g62b1lt_predoi_topox_fstop5.6_exp50ms\g62b1lt_predoi_topox_fstop5.6_exp50ms_maps.mat';
% files(n).topoy =  '021215 g62b1lt doi passive\g62b1lt_predoi_topoy_fstop5.6_exp50ms\g62b1lt_predoi_topoy_fstop5.6_exp50ms_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021215 g62b1lt doi passive\g62b1lt_doi_4x3y(2)_fstop5.6_exp50ms\g62b1lt_doi_4x3y(2)_fstop5.6_exp50ms_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'post';
% files(n).monitor = 'vert'; %%% for topox and y
