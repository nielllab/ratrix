clear all
clear classes
close all
clc
format long g

if ispc
    rootPath='C:\Ratrix\';
    pathSep='\';
    screenNum = 2; %one is good for Rig2D  %edf: not anymore it ain't!
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
b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

s = subject('Test', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s,'pmm');

s2 = subject('RAT_T', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s2,'pmm');

s3 = subject('RAT_U', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s3,'pmm');

s4 = subject('RAT_V', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s4,'pmm');

s5 = subject('RAT_W', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s5,'pmm');

soundManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
                                      soundClip('keepGoingSound','allOctaves',[300],20000), ...
                                      soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
                                      soundClip('wrongSound','tritones',[300 400],20000)});

                                  
%shared stim parameters                                
maxWidth                =screenWidth;
maxHeight               =screenHeight;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;

pixPerCycs = 32;
targetOrientations = [pi/2,0];      %first one is goTo, second one is goAway
distractorOrientations = [0,pi/2];  %choose a random contrast from this list
flankerOrientations = [0,pi/2];     %choose a random contrast from this list
%
leftYokedToRightFlankerOrientation =1;
leftYokedToRightTargetContrast =1;
%    
targetContrast = [1];    %choose a random contrast from this list each trial
distractorContrast = [1];
flankerContrast = [0];
%    
mean = 0.5;              %normalized luminance
cueLum=0.3;                %luminance of cue sqaure
cueSize=8;               %roughly in pixel radii 
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

%freeDrinks = trainingStep(fd, stim, rateCriterion(6,5), noTimeOff());

msFlushDuration         =4000;
msRewardDuration        =75;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =4000;
msRewardSoundDuration   =msRewardDuration;

msRequestRewardDuration             =0;
percentCorrectionTrials             =.5;
msResponseTimeLimit                 =0;
pokeToRequestStim                   =1;
maintainPokeToMaintainStim          =1;
msMaximumStimPresentationDuration   =0;
maximumNumberStimPresentations      =0;
doMask                              =1;

    msPenalty               =6000;
    framesJustCue           =int8(70); 

stim1 = cuedGoToFeatureWithTwoFlank(pixPerCycs,targetOrientations,distractorOrientations,flankerOrientations,leftYokedToRightFlankerOrientation,leftYokedToRightTargetContrast,targetContrast,distractorContrast,flankerContrast,mean,cueLum,cueSize,eccentricity,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustCue,framesStimOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
nafc1=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
       
    msPenalty               =4000;
    framesJustCue           =int8(30); 
    
stim2 = cuedGoToFeatureWithTwoFlank(pixPerCycs,targetOrientations,distractorOrientations,flankerOrientations,leftYokedToRightFlankerOrientation,leftYokedToRightTargetContrast,targetContrast,distractorContrast,flankerContrast,mean,cueLum,cueSize,eccentricity,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustCue,framesStimOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
nafc2=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
stim3 = cuedGoToFeatureWithTwoFlank(pixPerCycs,targetOrientations,distractorOrientations,flankerOrientations,leftYokedToRightFlankerOrientation,leftYokedToRightTargetContrast,targetContrast,distractorContrast,flankerContrast,mean,cueLum,cueSize,eccentricity,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustCue,framesStimOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

    msPenalty               =3000;
    framesJustCue           =int8(8); 

nafc3=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
       
cuedGoToHorizontal_level_1 = trainingStep(nafc1, stim1, performanceCriterion(.85,100), noTimeOff());
cuedGoToHorizontal_level_2 = trainingStep(nafc2, stim2, performanceCriterion(.85,100), noTimeOff());
cuedGoToHorizontal_level_3 = trainingStep(nafc3, stim3, performanceCriterion(.85,100), noTimeOff());
p=protocol('cuedGoToHorizontal penalty decreases v1',{cuedGoToHorizontal_level_1, cuedGoToHorizontal_level_2, cuedGoToHorizontal_level_3});

[s  r]=setProtocolAndStep(s ,p,1,0,1,1,r,'first try','ear');
[s2 r]=setProtocolAndStep(s2,p,1,0,1,1,r,'first try','ear');
[s3 r]=setProtocolAndStep(s3,p,1,0,1,1,r,'first try','ear');
[s4 r]=setProtocolAndStep(s4,p,1,0,1,1,r,'first try','ear');
[s5 r]=setProtocolAndStep(s5,p,1,0,1,1,r,'first try','ear');
