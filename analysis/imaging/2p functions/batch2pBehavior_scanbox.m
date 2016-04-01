%batch2pBehavior_scanbox    JW 3/28/16

clear all
close all
dbstop if error
pathname = '\\maxwell2b\F\2p data\compiled 2p\'; %for Maxwell
outpathname = '';
n=0;


n=n+1;
files(n).subj = 'g62dd2ln'; 
files(n).expt = '032816';
files(n).topox_session_data =  'topoX_session_data.mat';
files(n).topoy_session_data = 'topoY_session_data.mat';
files(n).behav_session_data = 'GTS_behavior_session_data.mat';
files(n).Orientations_w_blank_session_data = '2pOrientation_session_data.mat';
files(n).behavstim2sf_session_data = 'BehavStim2sf_session_data.mat';
files(n).behavstim3x4orient_session_data = 'BehavStim3x4orient_session_data.mat';
files(n).sizeSelect_session_data = '';
files(n).topox_pts =  '';
files(n).topoy_pts = '';
files(n).behav_pts = '';
files(n).Orientations_w_blank_pts = '';
files(n).behavstim2sf_pts = '';
files(n).behavstim3x4orient_pts = '';
files(n).master_pts = '';
files(n).monitor = 'vert';
files(n).task = 'GTS';
files(n).learningDay = 'learned';
files(n).spatialfreq = '200';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';


% n=n+1;
% files(n).subj = ''; 
% files(n).expt = '';
% files(n).topox_session_data =  '';
% files(n).topoy_session_data = '';
% files(n).behav_session_data = '';
% files(n).Orientations_w_blank_session_data = '';
% files(n).behavstim2sf_session_data = '';
% files(n).behavstim3x4orient_session_data = '';
% files(n).sizeSelect_session_data = '';
% files(n).topox_pts =  '';
% files(n).topoy_pts = '';
% files(n).behav_pts = '';
% files(n).Orientations_w_blank_pts = '';
% files(n).behavstim2sf_pts = '';
% files(n).behavstim3x4orient_pts = '';
% files(n).master_pts = '';
% files(n).monitor = 'vert';
% files(n).task = '';
% files(n).learningDay = '';
% files(n).spatialfreq = '200';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';