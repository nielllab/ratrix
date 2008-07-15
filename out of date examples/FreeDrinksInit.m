warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath('C:\eflister\Ratrix\Server\'));
warning('on','MATLAB:dispatcher:nameConflict')

%kkkkkkq

clear classes
close all
clc
format long g
r=ratrix('C:\eflister\Ratrix\ServerData\',1);
%                   int8([7,6,8]),int8([3,4,2]) old bomb?
 st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','parallelPort','C:\eflister\Ratrix\Stations\station1\','0378',int8(0),int8(1),logical(1));
%st=station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','keyboard'    ,'C:\eflister\Ratrix\Stations\station1\',[]    ,int8(2),int8(1),logical(1));
b=box(int8(1),'C:\eflister\Ratrix\Boxes\box1\');

r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

s = subject('rat_102', 'rat', 'long-evans', 'male', '01/11/2007', '02/09/2007', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s,'edf');

msFlushDuration         =1000;
msRewardDuration        =200;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =8000;
msRewardSoundDuration   =3*msRewardDuration;
soundMgr           =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
                                      soundClip('keepGoingSound','allOctaves',[300],20000), ...
                                      soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
                                      soundClip('wrongSound','tritones',[300 400],20000)});

stochasticFreeDrink = 0.01;
                                  
fd = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundMgr,msPenalty,msRewardSoundDuration,stochasticFreeDrink);
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


p=protocol('erikTest',{freeDrinks});


[s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');

r=putSubjectInBox(r,getID(s),1,'edf');

disp(display(r))

ids=getSubjectIDs(r);
s=getSubjectFromID(r,ids{1});
b=getBoxIDForSubjectID(r,getID(s));
st=getStationsForBoxID(r,b);

r=doTrials(st(1),r,1000);

