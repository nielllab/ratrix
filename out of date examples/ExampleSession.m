clear all
clear classes
close all
clc
format long g

rootPath='/Users/pmmeier/Desktop/Ratrix/';
pathSep='/';

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]))
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([rootPath 'ServerData' pathSep],0);

%sessions (separate file logs) will be defined as separate when the
%scheduler tells trials to stop

%sessions should display protocol/training step at top.  separate session as you graduate through training steps?

%graduation events should get logged in subject log, probably not trial
%logs

display(r)

r=commandAllBoxes(r,'start','hello','edf',1);
r=commandAllBoxes(r,'stop','good bye','edf',1);