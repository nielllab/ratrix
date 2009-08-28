function physAnalysis
%1) to export files from spike, run phys2txt.s2s (following instructions at its top)

%TODO 
% allow multiple simultaneous wavemark id's
% deal w/various framepulse protocols, inc parity
% deal w/time offset of stim
% deal w/stim id + rpt/unq id

%         if you need to edit or see stim file, you need an editor that can handle very large txt files (~1GB) 
%            'textpad' worked for me
%            (http://www.download.com/TextPad/3000-2352_4-10303640.html?tag=lst-0-1)

%2) provide cell array of <base> from above (full paths)
pth='C:\Documents and Settings\rlab\Desktop\cell2\';
fileNames={'cell 2'};

%3) enter time ranges of particular stims for each set of files (enter 0's for stimuli not shown):

stimTimes=[];

%stimTimes(:,:,1) = [
%1425 1850;  % gaussian 
%];

%stimTimes(:,:,2)=[
%389.1093948    1589.1474132; % gaussian 2.5 std
%1594.2254112   2874.2534028; % natural hateren t001
%2879.3494116    4159.3714056 % white hateren t001
%];

%4) enter the resolution at which you want to analyze:
binsPerSec=1000;

%5) enter the repeat/unique format (one entry for each stim in stimTimes):

pulsesPerRepeat=[];
numRepeats=[];
uniquesEvery=[];

%pulsesPerRepeat=[100*5*60]; %[120000,800,800];
%numRepeats=[1];             %[1,160,160];
%uniquesEvery=[0];           %[0,5,5];

%6) set output flags:
drawSummary=1;
forceStimRecompile=0;
drawStims=1;

%7) this file will call CompileBasicStimSet, which makes the "compiled data.txt" file
% this makes loading the stimulus faster for the future
% you should then call doAnalysis, which works on this file

close all;
clc
format long g
addpath(genpath('.'))
CompileBasicStimSet(pth,fileNames,stimTimes,binsPerSec,pulsesPerRepeat,numRepeats,uniquesEvery,drawSummary,drawStims,forceStimRecompile);