clear all; clear classes; close all; clc; format long g

%user params
subjectID='rat_w';    %choose which rat: 'test','rat_t', 'rat_u' , 'rat_v'
minsSessionLength=60;
shapingLevel=1;

rootPath='C:\Ratrix\'; pathSep='\';
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]));
warning('on','MATLAB:dispatcher:nameConflict')
r=ratrix([rootPath 'ServerData' pathSep],0);
possibleIDs=getSubjectIDs(r)

%setup
s=getSubjectFromID(r,subjectID);
%b=getBoxIDForSubjectID(r,getID(s));

r=putSubjectInBox(r,subjectID,1,'ear');
b=getBoxIDForSubjectID(r,getID(s))
st=getStationsForBoxID(r,b)
[s r]=setStepNum(s,shapingLevel,r,'testing','ear');

%doFlush(st,1)

%run
%startTime=GetSecs; 
%while ((GetSecs-startTime)/60 < minsSessionLength)cc
 %   r=doTrials(st,r,10);
%end

numTrials=1000;
r=doTrials(st,r,numTrials);

r=removeSubjectFromBox(r,subjectID,b,'no comment','pmm')

path='C:\Ratrix\Boxes\box1\';
subjects=[];%{'rat_v','rat_w'}; %set subjects=[] for all
ratrixAnalysis(loadRatrixData(path,subjects));