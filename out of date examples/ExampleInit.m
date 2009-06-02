clear all
clear classes
close all
clc
format long g

rootPath='C:\Documents and Settings\rlab\Desktop\ratrixDemo\';
pathSep='\';
screenNum = 0;
soundOn = 0;

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'classes' pathSep]))
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([rootPath 'ServerData' pathSep],1);                                                                                     %'B888'
st =station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep],'0378',int8(screenNum),int8(1),logical(soundOn));
%st =station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep] ,[]    ,int8(screenNum),int8(1),logical(soundOn));
st2=station(int8(2),int8([7,6,8]),int8([3,4,2]),600,500,  'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station2' pathSep] ,[]    ,int8(screenNum),int8(1),logical(soundOn));

b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);

r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));
r=addStationToBoxID(r,st2,getID(b));

s = subject('Test', 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
r=addSubject(r,s,'edf');

s2 = subject('Test2', 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
r=addSubject(r,s2,'edf');

msFlushDuration         =1000;
msRewardDuration        =150;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =8000;
msRewardSoundDuration   =msRewardDuration;
freeDrinkLikelihood     =0;
soundManager            =makeStandardSoundManager();


fd = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);

pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5; 
radius                  =4;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65; 
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);





freeDrinks = trainingStep(fd, stim, rateCriterion(6,5), noTimeOff());

msRequestRewardDuration             =0;
percentCorrectionTrials             =.5;
msResponseTimeLimit                 =0;
pokeToRequestStim                   =1;
maintainPokeToMaintainStim          =1;
msMaximumStimPresentationDuration   =0;
maximumNumberStimPresentations      =0;
doMask                              =1;
nafc=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
          msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
          maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
goToGrating = trainingStep(nafc, stim, performanceCriterion(.85,100), hourRange(8,20));
                           
pixPerCycs              =2.^[1:9];
targetOrientations      =[pi/2];
distractorOrientations  =[0];       
stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
orientationDiscrim = trainingStep(nafc, stim, repeatIndefinitely(), randomBursts(60,3));

p=protocol('orientation shaping',{freeDrinks, goToGrating, orientationDiscrim});

[s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');
[s2 r]=setProtocolAndStep(s2,p,1,0,1,1,r,'first try','edf');

r=putSubjectInBox(r,getID(s),1,'edf');
r=putSubjectInBox(r,getID(s2),1,'edf');

display(r)

r=removeSubjectFromBox(r,getID(s),getBoxIDForSubjectID(r,getID(s)),'testing','edf');

display(r)

r=putSubjectInBox(r,getID(s),1,'edf');
r=removeSubjectFromBox(r,getID(s2),getBoxIDForSubjectID(r,getID(s2)),'testing','edf');