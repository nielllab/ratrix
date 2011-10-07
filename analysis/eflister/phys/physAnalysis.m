function physAnalysis
%1) to export files from spike, run phys2txt.s2s (following instructions at its top)

%TODO 
% allow multiple simultaneous wavemark id's
% deal w/various framepulse protocols, inc parity
% deal w/time offset of stim
% deal w/stim id + rpt/unq id

%         if you need to edit or see stim/phys file (unusual), you need an editor that can handle very large txt files (~1GB) 
%            'textpad' worked for me
%            (http://www.download.com/TextPad/3000-2352_4-10303640.html?tag=lst-0-1)

%2) provide cell array of <base> from above (full paths)

pth='E:\tmpPhysTxt\164\hack\03.17.09\3b43c16b7b96f501204aa3bca54bd522856d2320\';
fileNames={'3b43c16b7b96f501204aa3bca54bd522856d2320'};

%failed -- seems to have pulse problems...
%pth='/Users/eflister/Desktop/physChk/164/10.16.08/71d175b616650bff5161fb39a38d8ea40550bd59/';
%fileNames={'71d175b616650bff5161fb39a38d8ea40550bd59'};

pth='/Users/eflister/Desktop/physChk/164/10.21.08/7877f102598baece5bd3a79ec76311f0ff33befa/chunk1/'; %also 2 and 3
fileNames={'7877f102598baece5bd3a79ec76311f0ff33befa'};


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
forcePhysRecompile=0;
drawStims=1;

%7) this file will call compilePhysData, which makes the "compiled data.txt" file
% this makes loading the stimulus faster for the future
% you should then call doAnalysis, which works on this file

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(fileparts(pathstr))),'bootstrap'))
setupEnvironment;

compilePhysData(pth,fileNames,stimTimes,binsPerSec,pulsesPerRepeat,numRepeats,uniquesEvery,drawSummary,drawStims,forceStimRecompile,forcePhysRecompile);