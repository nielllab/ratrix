clear all
clear classes
close all
clc
format long g

rootPath='/Users/pmmeier/Desktop/Ratrix/';
pathSep='/';
screenNum = 0;
soundOn = 0;

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]))
%rmpath([rootPath 'Server' pathSep 'classes' pathSep 'protocols' pathSep 'stimManagers' pathSep 'HandleParam' pathSep 'CVS'])
%rmpath([rootPath 'Server' pathSep 'classes' pathSep 'protocols' pathSep 'stimManagers' pathSep 'HandleParam'])
warning('on','MATLAB:dispatcher:nameConflict')

flush_solo;

r=ratrix([rootPath 'ServerData' pathSep],1);
%st=station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','parallelPort','C:\eflister\Ratrix\Stations\station1\','B888',int8(2),int8(1),logical(1));
 st=station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);

r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

s = subject('test', 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s,'edf');

msFlushDuration         =1000;
msRewardDuration        =200;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =8000;
msRewardSoundDuration   =3*msRewardDuration;
soundManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
                                      soundClip('keepGoingSound','allOctaves',[300],20000), ...
                                      soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
                                      soundClip('wrongSound','tritones',[300 400],20000)});
stim = RomoBarMotionStimulus;

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
goRomo = trainingStep(nafc, stim, repeatIndefinitely(), noTimeOff());
                           
p=protocol('romoromo',{goRomo});

[s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');

r=putSubjectInBox(r,getID(s),1,'edf');

disp(display(r))

ids=getSubjectIDs(r);
s=getSubjectFromID(r,ids{1});
b=getBoxIDForSubjectID(r,getID(s));
st=getStationsForBoxID(r,b);

r=doTrials(st(1),r,10);

