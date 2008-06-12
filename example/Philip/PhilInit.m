clear all
clear classes
close all
clc
format long g

if ispc
    rootPath='C:\Ratrix\';
    pathSep='\';
    screenNum = 1; %one is good for Rig2D
    screenWidth=1280;  screenHeight=1024;
    soundOn = 1;
elseif isosx 
    rootPath='/Users/pmmeier/Desktop/Ratrix/';
    pathSep='\';
    screenNum = 0; 
    rect=Screen('Rect', screenNum); screenWidth=rect(3);  screenHeight=rect(4);
    soundOn = 0;    
else  %use default
    %rootPath='C:\Ratrix\';
    'must enter rootPath'
    pathSep='\';
    screenNum =2;
    screenWidth= 800;  screenHeight=600;
    soundOn = 1;
end

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]))
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([rootPath 'ServerData' pathSep],1);
st =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
%st=station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep] ,[]    ,int8(screenNum),int8(1),logical(soundOn));
st2=station(int8(2),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station2' pathSep] ,[]    ,int8(screenNum),int8(1),logical(soundOn));

b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);

r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));
r=addStationToBoxID(r,st2,getID(b));

s = subject('Test', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s,'pmm');

s2 = subject('RAT_T', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s2,'pmm');

s3 = subject('RAT_U', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s3,'pmm');

s4 = subject('RAT_V', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s4,'pmm');

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
fd = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,msPenalty,msRewardSoundDuration);

maxWidth                =screenWidth;
maxHeight               =screenHeight;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;

pixPerCycs = 16;
targetOrientations = [pi/2,0];      %first one is goTo, second one is goAway
distractorOrientations = [0,pi/2];  %choose a random contrast from this list
flankerOrientations = [0,pi/2];     %choose a random contrast from this list
%
leftYokedToRightFlankerOrientation =1;
leftYokedToRightTargetContrast =1;
%    
targetContrast = [1];    %choose a random contrast from this list each trial
distractorContrast = [1];
flankerContrast = [1];
%    
mean = 0.5;              %normalized luminance
cueLum=1;                %luminance of cue sqaure
cueSize=2;               %roughly in pixel radii 
%    
eccentricity = 0.5;       %target position from center in percent ScreenWidth 
cuePercentTargetEcc=0.6; %fraction of distance from center to target
stdGaussMask = 0.3;      %defines patch size of maxHeight*stdGaussMask, which is linearly yoked to std via sqrt(2)/5
flankerOffset = 0.7;     %distance in stdGaussMask
%       
framesJustCue=int8(100); 
framesStimOn=int8(0);          %if 0, then leave stim on
thresh = 0.001;
yPositionPercent = 0.5;  
stim = cuedGoToFeatureWithTwoFlank(pixPerCycs,targetOrientations,distractorOrientations,flankerOrientations,leftYokedToRightFlankerOrientation,leftYokedToRightTargetContrast,targetContrast,distractorContrast,flankerContrast,mean,cueLum,cueSize,eccentricity,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustCue,framesStimOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%stim = cuedGoToFeatureWithTwoFlank([8],[0,pi/2],[0,pi/2],[0,pi/2],1,1,[1],[1],[0.5],0.5,0,1,0.5,0.6,0.2,0.7,int8(100),int8(0),0.001,0.5,200,200,[1,1],0.5);

% pixPerCycs              =[20];
% targetOrientations      =[pi/2];
% distractorOrientations  =[];
% mean                    =.5; 
% radius                  =4;
% contrast                =1;
% thresh                  =.00005;
% yPosPct                 =.65; 
% maxWidth                =800;
% maxHeight               =600;
% scaleFactor             =[1 1];
% interTrialLuminance     =.5;
% stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

isa(stim,'stimManager')

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


isa(stim,'stimManager')
isa(stim,'cuedGoToFeatureWithTwoFlank')

goToGrating = trainingStep(nafc, stim, performanceCriterion(.85,100), hourRange(8,20));

isa(getStimManager(goToGrating),'stimManager')
isa(getStimManager(goToGrating),'cuedGoToFeatureWithTwoFlank')


radius                  =4;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65; 
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