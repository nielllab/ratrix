clear all; clear classes; close all; clc; format long g

%kqk212222223222222222232222222222222222212223223kkkkkkkkkkkkqk2322222k2122
%2kqk32kq232k2k222kqkqk2k2222222222222222222222222kqqqqqk22223kkkkkkk22221k
%22222kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkq
%k2kkkkkkkkkkkkkkkk22222222kq12221222k2kqqqqqqqk2k2222222222222kq
%kqkkkkkqkkkkqkqkqk22222122222222322222122223222221222222222212232212232121

%user params
subjectID='test';   %choose which rat: 'test','rat_107', 'edf' ,'rat_v'

rootPath='C:\pmeier\Ratrix\'; pathSep='\';
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]));
warning('on','MATLAB:dispatcher:nameConflict')
%r=ratrix([rootPath 'ServerData' pathSep],0); possibleIDs=getSubjectIDs(r)

numTrialsPerLoop=1000; %maximum trials, scheduler will choose less
numLoops=99;  %set to high and wait for kq to break it

loop=0;
while loop<numLoops
    %setup
    loop=loop+1
    r=ratrix([rootPath 'ServerData' pathSep],0);
    
    s=getSubjectFromID(r,subjectID);
    b=getBoxIDForSubjectID(r,getID(s));
    r=putSubjectInBox(r,subjectID,1,'pmm');
    b=getBoxIDForSubjectID(r,getID(s))
    st=getStationsForBoxID(r,b)
    
    r=doTrials(st,r,numTrialsPerLoop); %run
    r=removeSubjectFromBox(r,subjectID,b,'no comment','pmm')
    
    data=loadRatrixData([rootPath 'Boxes\box1\'],{subjectID},1);
    if strcmp(data{1}.trialRecords(end).response,'manual kill')
        numToAnalyze=loop;
        loop=numLoops
    else %restart the ratrix to shrink trial records
        RatSubjectInit 
    end   
    
    %loop=numLoops+1 %for debugging
end


% [p t]=getProtocolAndStep(s);
% t=getTrainingStep(p,t)
% s=getStimManager(t)
% 
% disp(t)
% display(t)
% display(getTrialManager(t))
%
% doFlush(st,1)

if 1
    path=[rootPath 'Boxes\box1\'];
    subjects={subjectID};%{'test','rat_w'}; %set subjects=[] for all
    lastN=numToAnalyze;
    data=loadRatrixData(path,subjects,lastN);
    ratrixAnalysis(data);
end

