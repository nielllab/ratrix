%% compare 2 groups

close all
clear all
dbstop if error
warning('off','all')

% select first file for comparison
[preFile p] = uigetfile('*.mat','select PRE file');
cd(p)
% select second file for comparison
[postFile p] = uigetfile('*.mat','select POST file');

fnames = {preFile,postFile};
grpnames = {'pre','post'};

psfilename = 'tempWF.ps'; 
if exist(psfilename,'file')==2;delete(psfilename);end

% preparing to plot
mycol = {'k','r'};
areas = {'V1','P','LM','AL','RL','AM','PM','MM'};
pltrange = [0 0.01];
% csval=11; %circular shift for nat im data -> remove for KC?

imagerate = 10;
load('C:\grating4x3y5sf3tf_short011315.mat','isi','duration'); %KC: this stuff? ,'familiar'
cyclength = (isi+duration)*imagerate;
base = 8:10; %indices for baseline
peak = 14:16; %indices for peak response
imrange = [0 0.05]; %range to display images at
ptsrange = 2; %+/- pixels from selected point to average over
range = -ptsrange:ptsrange;
timepts = 0:1/imagerate:cyclength/imagerate-1/imagerate; %cycle time points