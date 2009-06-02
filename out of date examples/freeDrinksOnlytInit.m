
%master shaping template for detection and tilt discrimination tasks
if 0
    screen clear all; clear classes; close all
    clc; format short g
end

if ispc
    rootPath='C:\pmeier\Ratrix\';
    pathSep='\';
    screenNum = 0; 
    screenWidth=1024;  screenHeight=768;
    soundOn = 1;
elseif isosx 
    rootPath='/Users/pmmeier/Desktop/Ratrix/';
    pathSep='\';
    screenNum = 0; 
    rect=Screen('Rect', screenNum); screenWidth=rect(3);  screenHeight=rect(4);
    soundOn = 0;    
else  %use default
    %rootPath='C:\Ratrix\';
    error('must enter rootPath')
    pathSep='\';
    screenNum =2;
    screenWidth= 800;  screenHeight=600;
    soundOn = 1;
end

%% addPaths
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]))
warning('on','MATLAB:dispatcher:nameConflict')


%%  make new ratrix station and box
r=ratrix([rootPath 'ServerData' pathSep],1);
%st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
rigStation  =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep],'B888',int8(2),int8(1),logical(soundOn));
%workStation =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep],'0378',int8(0),int8(1),logical(soundOn));
%oldBombStation =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(2),int8(1),logical(soundOn));
%macOsStation =  
st=rigStation;
b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

%% shared parameters for free drinks

msFlushDuration         =1000;
msRewardDuration        =100;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1;
msRewardSoundDuration   =msRewardDuration;
sndManager            =makeStandardSoundManager();

pctStochasticReward=0.0;  %0.01 or 0.001;                                  

pixPerCycs              =[20];
targetOrientations      =0;%rand*pi;%[pi/2];
distractorOrientations  =[];
mean                    =.5; 
radius                  =.1;
contrast                =1;  
thresh                  =.00005;
yPosPct                 =.65; 
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;


%% universal free drink subject
s = subject('freeDrinkSubject', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories'); r=addSubject(r,s,'pmm');

msRewardDuration        =100;
msPenalty               =1;
msRewardSoundDuration   =msRewardDuration;
pctStochasticReward=0.01;  %0.01 or 0.001;   

% contrast                =1;   % if wrong for shaping, show nothing!
% maxWidth                =800;
% maxHeight               =600;
% scaleFactor             =[1 1];

contrast                =1;   % if wrong for shaping, show nothing!
maxWidth                =120;
maxHeight               =100;
scaleFactor             =[0];

pctStochasticReward=0.01;  %juicey
fd1 = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);

pctStochasticReward=0.001;  %some
fd2 = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);

pctStochasticReward=0;  %none
fd3 = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);

stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
freeDrinksStep1 = trainingStep(fd1, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
freeDrinksStep2 = trainingStep(fd2, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
freeDrinksStep3 = trainingStep(fd3, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
fdSteps=protocol('contrasty gabor free drinks weening',{freeDrinksStep1, freeDrinksStep2, freeDrinksStep3});
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');

%% rat 132
% a specific rat's free drink
s = subject('rat_132', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories'); r=addSubject(r,s,'pmm');
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');  %juicey  (0.01)
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,2,r,'first try','pmm'); %some (0.001)
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,3,r,'first try','pmm'); %no stochastic

%% rat 133
% a specific rat's free drink
s = subject('rat_133', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories'); r=addSubject(r,s,'pmm');
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');  %juicey  (0.01)
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,2,r,'first try','pmm'); %some (0.001)
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,3,r,'first try','pmm'); %no stochastic


s = subject('fdtest', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories'); r=addSubject(r,s,'pmm');
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,2,r,'first try','pmm'); %some (0.001)


%% old format for fd for each rat
% msRewardDuration        =100;
% msPenalty               =1;
% msRewardSoundDuration   =msRewardDuration;
% pctStochasticReward=0.0;  %0.01 or 0.001;    
% contrast                =0;   % if wrong for shaping, show nothing!
% fd = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);
% stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% freeDrinksStep = trainingStep(fd, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
% p=protocol('blank gabor free drinks',{freeDrinksStep});
% [s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','pmm');

%% check
isa(stim,'stimManager')
isa(stim,'ifFeatureGoRightWithTwoFlank')
stim
