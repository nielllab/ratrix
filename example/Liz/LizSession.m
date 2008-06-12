clear all; clear classes; close all; clc; format long g

%user params
subjectID='test';    %choose which rat: 'test','rat_t', 'rat_u' , 'rat_v'
minsSessionLength=1;
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

%run
startTime=GetSecs; 
while ((GetSecs-startTime)/60 < minsSessionLength)
    r=doTrials(st,r,10);
end

r=removeSubjectFromBox(r,subjectID,b,'no comment','ear')

