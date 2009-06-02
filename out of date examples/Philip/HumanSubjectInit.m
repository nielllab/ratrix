screen clear all
clear classes
close all
clc
format short g

if ispc
    rootPath='C:\pmeier\Ratrix\';
    pathSep='\';
    screenNum = 0; 
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
st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
%st =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

s = subject('test', 'human', 'none', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s,'pmm');

s2 = subject('pmm', 'human', 'none', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s2,'pmm');

s3 = subject('edf', 'human', 'none', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s3,'pmm');

s4 = subject('ear', 'human', 'none', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s4,'pmm');

s5 = subject('p-r', 'human', 'none', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s5,'pmm');

soundManager            =makeStandardSoundManager();
                             
%shared stim parameters                                
maxWidth                =screenWidth;
maxHeight               =screenHeight;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;

pixPerCycs = 16;
goRightOrientations = [0,pi/2]; 
goLeftOrientations =  [0,pi/2]; 
flankerOrientations = [0,pi/2]; %choose a random orientation from this list

topYokedToBottomFlankerOrientation =1;  
topYokedToBottomFlankerContrast =1;


goRightContrast = [1/2];    %choose a random contrast from this list each trial
goLeftContrast =  [0];
flankerContrast = [1];
%    
mean = 0.5;              %normalized luminance
cueLum=0.5;              %luminance of cue square
cueSize=4;               %roughly in pixel radii 

xPositionPercent = 0.5;  %target position in percent ScreenWidth 
cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank
stdGaussMask = 1/16;     %in fraction of vertical extent of stimulus
flankerOffset = 5;       %distance in stdGaussMask  (0-->5.9 when std is 1/16)
%       
framesJustFlanker=int8(2); 
framesTargetOn=int8(3);     
thresh = 0.001;
yPositionPercent = 0.5;  

%freeDrinks = trainingStep(fd, stim, rateCriterion(6,5), noTimeOff());

msFlushDuration         =4000;
msRewardDuration        =75;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =100;
msRewardSoundDuration   =msRewardDuration;

msRequestRewardDuration             =0;
percentCorrectionTrials             =.5;
msResponseTimeLimit                 =0;
pokeToRequestStim                   =1;
maintainPokeToMaintainStim          =1;
msMaximumStimPresentationDuration   =0;
maximumNumberStimPresentations      =0;
doMask                              =1;

    %msPenalty               =100;
    
    
stim1 =  ifFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance); 
nafc1=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
      
     %a range of contrasts  
     N=7;  %
     goRightContrast = 1/256*[2.^[0:N-1]];    %choose a random contrast from this list each trial

stim2 =  ifFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance); 
nafc2=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
      

       %
stim3 =  ifFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance); 
nafc3=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
      
       
featureGoRightWithTwoFlankers_level_1 = trainingStep(nafc1, stim1, performanceCriterion(.85,100), noTimeOff());
featureGoRightWithTwoFlankers_level_2 = trainingStep(nafc2, stim2, performanceCriterion(.85,100), noTimeOff());
featureGoRightWithTwoFlankers_level_3 = trainingStep(nafc3, stim3, performanceCriterion(.85,100), noTimeOff());
p=protocol('ifGratingGoRight human test',{featureGoRightWithTwoFlankers_level_1, featureGoRightWithTwoFlankers_level_2, featureGoRightWithTwoFlankers_level_3});

[s  r]=setProtocolAndStep(s ,p,1,0,1,1,r,'first try','pmm');
[s2 r]=setProtocolAndStep(s2,p,1,0,1,1,r,'first try','pmm');
[s3 r]=setProtocolAndStep(s3,p,1,0,1,1,r,'first try','pmm');
[s4 r]=setProtocolAndStep(s4,p,1,0,1,1,r,'first try','pmm');
[s5 r]=setProtocolAndStep(s5,p,1,0,1,1,r,'first try','pmm');
