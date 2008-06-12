clear all; clear classes; close all; clc; format long g

%kqk212222223222222222232222222222222222212223223kkkkkkkkkkkkqk2322222k2122
%323212232232323223222122kk11qkkkkkkkkkkkkk212222kqkkk23qqqqkkkkkkkkkkkqk23
%222232121223223221223221223221223221223221223221232212232212232223223223222322122232212223221223222122232322122322122232221223221223221222321222322322232223222322322323223223222322232212223222322232232223223232322232223223232223232232232232221221221232212232223232212323221223223223q

%user params
subjectID='test';    %choose which rat: 'test','rat_106', 'edf' , 'rat_v'
minsSessionLength=60;
shapingLevel=1;

rootPath='C:\pmeier\Ratrix\'; pathSep='\';
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]));
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([rootPath 'ServerData' pathSep],0);
possibleIDs=getSubjectIDs(r)

%setup
s=getSubjectFromID(r,subjectID);
b=getBoxIDForSubjectID(r,getID(s));

r=putSubjectInBox(r,subjectID,1,'pmm');
b=getBoxIDForSubjectID(r,getID(s))


st=getStationsForBoxID(r,b)

%doFlush(st,1)

%run
%startTime=GetSecs; 
%while ((GetSecs-startTime)/60 < minsSessionLength)cc
 %   r=doTrials(st,r,10);
%end

numTrials=300;
r=doTrials(st,r,numTrials);

r=removeSubjectFromBox(r,subjectID,b,'no comment','pmm')

if 0
    path=[rootPath 'Boxes\box1\'];
    subjects=['pmm'];%{'test','rat_w'}; %set subjects=[] for all
    ratrixAnalysis(loadRatrixData(path,subjects));
end

