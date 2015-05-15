clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'C:\data\imaging\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'C:\data\imaging\topos\';

n=0;


n=n+1;

files(n).subj = 'g62l8rn';
files(n).expt = '031315';
files(n).topox =  'passive map files 2015\g62l8rn behav 031315 day6\g62l8rn_run2_portrait_topoX_maps.mat';
files(n).topoy =  'passive map files 2015\g62l8rn behav 031315 day6\g62l8rn_run3_portrait_topoY_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = ''; % portrait
files(n).grating3x2y6sf4tf = '';
files(n).background3x2yBlank = '';
files(n).behavGratings = 'passive map files 2015\g62l8rn behav 031315 day6\g62l8rn_run4_portrait_BehaveStim2sf_maps.mat';
files(n).behavGratings3x = 'passive map files 2015\g62l8rn behav 031315 day6\g62l8rn_run5_portrait_BehaveStim3sf4orient_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).monitor = 'vert'; %%% for topox and y

n=n+1;

files(n).subj = 'g62b1lt';
files(n).expt = '030915';
files(n).topox =  'passive map files 2015\g62b1lt 030915\g62l1lt_run1_topox_fstop5.6_exp50ms_maps.mat';
files(n).topoy =  'passive map files 2015\g62b1lt 030915\g62l1lt_run2_topoy_fstop5.6_exp50ms_maps.mat';
files(n).topoxland =  '';
files(n).topoyland = '';
files(n).grating4x3y6sf3tf = ''; % portrait
files(n).grating3x2y6sf4tf = '';
files(n).background3x2yBlank = '';
files(n).behavGratings = 'passive map files 2015\g62b1lt 030915\g62l1lt_run3_behavstim_fstop5.6_exp50ms_maps.mat';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1;
% 
% files(n).subj = 'g62m9tt';
% files(n).expt = '030515';
% files(n).topox =  'passive map files 2015\g62l10rt\G62L10-rt_run1_portrait_topoX_maps.mat';
% files(n).topoy =  'passive map files 2015\g62l10rt\G62L10-rt_run2_portrait_topoY_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = ''; % portrait
% files(n).grating3x2y6sf4tf = '';
% files(n).background3x2yBlank = '';
% files(n).behavGratings = 'passive map files 2015\g62l10rt\G62L10-rt_run3_portrait_BehaveStim2sf_75_25_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).monitor = 'vert'; %%% for topox and y

% n=n+1;
% 
% files(n).subj = 'g62m9tt';
% files(n).expt = '030515';
% files(n).topox =  '2015 behavior\g62m9tt\g62m9tt 030515\G62M9tt_run2_portrait_topoX_maps.mat';
% files(n).topoy =  '2015 behavior\g62m9tt\g62m9tt 030515\G62M9tt_run3_portrait_topoY_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '2015 behavior\g62m9tt\g62m9tt 030515\G62M9tt_run5_landscape_4x3yGratings_maps.mat'; % portrait
% files(n).grating3x2y6sf4tf = '';
% files(n).background3x2yBlank = '';
% files(n).behavGratings = '2015 behavior\g62m9tt\g62m9tt 030515\G62M9tt_run4_portrait_BehaveStim2sf_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).monitor = 'vert'; %%% for topox and y
% % n=n+1;
% 
% files(n).subj = 'g62j4rt';
% files(n).expt = '030415';
% files(n).topox =  'passive map files 2015\g624jrt 030415\G62J4rt_run4_portrait_topoX_50msexp_maps.mat';
% files(n).topoy =  'passive map files 2015\g624jrt 030415\G62J4rt_run5_portrait_topoY_50msexp_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\g624jrt 030415\G62J4rt_run1_landscape_centered_4x3yGratings_50msexp_maps.mat'; % centered
% files(n).grating3x2y6sf4tf = '';
% files(n).background3x2yBlank = 'passive map files 2015\g624jrt 030415\G62J4rt_run2_landscape_backgroundNEW_50msexp_maps.mat';
% files(n).behavGratings = 'passive map files 2015\g624jrt 030415\G62J4rt_run3_portrait_behavestim2sf_50msexp_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% 
% files(n).monitor = 'vert'; %%% for topox and y




% n=n+1;\
% 
% files(n).subj = 'g62L10rt';
% files(n).expt = '022215';
% files(n).topox =  'passive map files 2015\G62L10-rt_run1_portrait_topoX_50msexp_maps.mat';
% files(n).topoy =  'passive map files 2015\G62L10-rt_run2_portrait_topoY_50msexp_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\G62L10-rt_run3_landscape_4x3yGratings_50msexp_maps.mat';
% files(n).grating3x2y6sf4tf = 'passive map files 2015\G62L10-rt_run4_landscape_3x2yGratings_50msexp_maps.mat';
% files(n).background3x2y = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
% n=n+1;
% 
% files(n).subj = 'g62L10lt';
% files(n).expt = '022215';
% files(n).topox =  'passive map files 2015\G62L10-LT_run3_portrait_topoX_maps.mat';
% files(n).topoy =  'passive map files 2015\G62L10-LT_run4_portrait_topoY_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\G62L10-LT_run1_landscape_4x3yGratings_maps.mat';
% files(n).grating3x2y6sf4tf = 'passive map files 2015\G62L10-LT_run2_landscape_3x2yGratings_maps.mat';
% files(n).background3x2y = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
% n=n+1;
% 
% files(n).subj = 'g62n3rn';
% files(n).expt = '022215';
% files(n).topox =  'passive map files 2015\G62n3RN_run1_portrait_topoX_maps.mat';
% files(n).topoy =  'passive map files 2015\G62n3RN_run2_portrait_topoY_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\G62n3RN_run3_landscape_4x3yGrating_maps.mat';
% files(n).grating3x2y6sf4tf = 'passive map files 2015\G62n3RN_run4_landscape_3x2yGrating_maps.mat';
% files(n).background3x2y = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y

% 
% 
% n=n+1;
% 
% files(n).subj = 'g62l8rn';
% files(n).expt = '021815';
% files(n).topox =  'passive map files 2015\G62L8RN_run3_portrait_topoX_50msexp_maps.mat';
% files(n).topoy =  'passive map files 2015\G62L8RN_run4_portrait_topoY_50msexp_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\G62L8RN_run1_landscape_4x3yGratings_50msexp_maps.mat';
% files(n).grating3x2y6sf4tf = 'passive map files 2015\G62L8RN_run2_landscape_3x2yGratings_50msexp_maps.mat';
% files(n).background3x2y = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% % 
% n=n+1;
% 
% files(n).subj = 'g62m9tt';
% files(n).expt = '021515';
% files(n).topox =  '021515 G62M9TT prebehavior\G62M9TT_run1_portrait_topoX_50msexp\G62M9TT_run1_portrait_topoX_50msexp_maps.mat';
% files(n).topoy =  '021515 G62M9TT prebehavior\G62M9TT_run2_portrait_topoY_50msexp\G62M9TT_run2_portrait_topoY_50msexp_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '021515 G62M9TT prebehavior\G62M9TT_run6_landscape_4x3_gratings_22min_50msexp\G62M9TT_run6_landscape_4x3_gratings_22min_50msexp_maps.mat';
% files(n).grating3x2y6sf4tf = '021515 G62M9TT prebehavior\G62M9TT_run7_landscape_3x2_gratings_20min_50msexp\G62M9TT_run7_landscape_3x2_gratings_20min_50msexp_maps.mat';
% files(n).background3x2y = '021515 G62M9TT prebehavior\G62M9TT_run5_landscape_3x2_background_12min_50msexp\G62M9TT_run5_landscape_3x2_background_12min_50msexp_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% n=n+1
% files(n).subj = 'g62k2rt';
% files(n).expt = '021515';
% files(n).topox =  'passive map files 2015\G62K2RT_run6_portrait_topoX_maps.mat';
% files(n).topoy =  'passive map files 2015\G62K2RT_run7_portrait_topoY_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\G62K2RT_run1_landscape_4x3_gratings_22min_maps.mat';
% files(n).grating3x2y6sf4tf = 'passive map files 2015\G62K2RT_run2_landscape_3x2_gratings_20min_maps.mat';
% files(n).background3x2y = 'passive map files 2015\G62K2RT_run3_landscape_3x2_background_12min_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
% n=n+1
% files(n).subj = 'g62n1ln';
% files(n).expt = '021515';
% files(n).topox =  'passive map files 2015\G62N1LN_run1_portrait_topoX_50msexp_maps.mat';
% files(n).topoy =  'passive map files 2015\G62N1LN_run2_portrait_topoY_50msexp_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = 'passive map files 2015\G62N1LN_run8_landscape_4x3_Gratings_22min_maps.mat';
% files(n).grating3x2y6sf4tf = 'passive map files 2015\G62N1LN_run6_landscape_3x2_Gratings_20min_maps.mat';
% files(n).background3x2y = 'passive map files 2015\G62N1LN_run5_landscape_3x2Background_50msexp_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
% 
% 
% 
% 
% n=n+1;
% 
% files(n).subj = 'g62bl8rn';
% files(n).expt = '021415';
% files(n).topox =  '021415_G62L8-RN_preBehavior\G62L8-RN_run1_topoX_portrait_50msexp\G62L8-RN_run1_topoX_portrait_50msexp_maps.mat';
% files(n).topoy =  '021415_G62L8-RN_preBehavior\G62L8-RN_run2_topoY_portrait_50msexp\G62L8-RN_run2_topoY_portrait_50msexp_maps.mat';
% files(n).topoxland =  '';
% files(n).topoyland = '';
% files(n).grating4x3y6sf3tf = '';
% files(n).grating3x2y6sf4tf = '021415_G62L8-RN_preBehavior\G62L8-RN_run6_3x2_gratings_20min_landscape_50msexp\G62L8-RN_run6_3x2_gratings_20min_landscape_50msexp_maps.mat';
% files(n).background3x2y = '021415_G62L8-RN_preBehavior\G62L8-RN_run5_3x2Background_12min_landscape_50msexp\G62L8-RN_run5_3x2Background_12min_landscape_50msexp_maps.mat';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; 
% files(n).doi = 'pre';
% files(n).monitor = 'vert'; %%% for topox and y
