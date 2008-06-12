clear all
clear classes
close all
clc
format long g

ratrixPath='C:\eflister\Ratrix\';

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([ratrixPath 'classes' filesep]));
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([ratrixPath 'ServerData' filesep],1);
st=station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','parallelPort',[ratrixPath 'Stations' filesep 'station1' filesep],'0378',int8(0),int8(1),true);
b=box(int8(1),[ratrixPath 'Boxes' filesep 'box1' filesep]);

r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

s = subject('test', 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
r=addSubject(r,s,'edf');


msFlushDuration         =1000;
msRewardDuration        =150;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =8000;
msRewardSoundDuration   =msRewardDuration;
soundManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});
freeDrinkLikelihood=0;
fd = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);

pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.04;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

freeDrinks = trainingStep(fd, stim, repeatIndefinitely(), noTimeOff());

p=protocol('gabor free drinks',{freeDrinks});

[s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');

r=putSubjectInBox(r,getID(s),1,'edf');

%display(r)

ids=getSubjectIDs(r);
s=getSubjectFromID(r,ids{1});
b=getBoxIDForSubjectID(r,getID(s));
st=getStationsForBoxID(r,b);

r2=makeNonpersistedRatrixForStationID(r,getID(st(1)));

r2=establishDB(r2,['C:\eflister\test\' 'ServerData' filesep],1); %THIS DOESN'T WORK THE FIRST TIME, BUT DOES ONCE THE DIRS ARE CREATED

ids=getSubjectIDs(r2);
s=getSubjectFromID(r2,ids{1});
b=getBoxIDForSubjectID(r2,getID(s));
st=getStationsForBoxID(r2,b);

%display(s)
%display(st)
%display(out)

r2=doTrials(st(1),r2,1000);