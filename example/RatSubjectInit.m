
%Liz uses this in april 2007 to get rats to do a totem stim task

if 0
    screen clear all; clear classes; close all
    clc; format short g
end

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
%st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
st =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
%old bomb? %st =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

s = subject('test', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s,'pmm');

s2 = subject('rat_114', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s2,'pmm');

s3 = subject('rat_115', 'rat', 'long-evans', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s3,'pmm');
 
s4 = subject('rat_116', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s4,'pmm');
 
s5 = subject('rat_117', 'rat', 'long-evans', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
 r=addSubject(r,s5,'pmm');
 
s6 = subject('rat_118', 'rat', 'long-evans', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s6,'pmm');

s7 = subject('rat_119', 'rat', 'long-evans', 'female', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories');
r=addSubject(r,s7,'pmm');

sndManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
                                      soundClip('keepGoingSound','allOctaves',[300],20000), ...
                                      soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
                                      soundClip('wrongSound','tritones',[300 400],20000)});
                             
%shared stim parameters                                
maxWidth                =screenWidth;
maxHeight               =screenHeight;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;

pixPerCycs =64;
goRightOrientations = [pi/6]; 
goLeftOrientations =  [-pi/6]; 
flankerOrientations = [pi/6,0,-pi/6]; %choose a random orientation from this list

topYokedToBottomFlankerOrientation =0;  
topYokedToBottomFlankerContrast =1;

goRightContrast =    [1];    %choose a random contrast from this list each trial
goLeftContrast =     [1];
flankerContrast =    [0.2];
distractorContrast = [0.2];
%    
mean = 0.5;              %normalized luminance - if not 0.5 then grating can be detected as mean lum changes
cueLum=0;              %luminance of cue square
cueSize=10;               %roughly in pixel radii 

xPositionPercent = 0.5;  %target position in percent ScreenWidth 
cuePercentTargetEcc=0;  %in fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank
stdGaussMask = 1/16;     %in fraction of vertical extent of stimulus
flankerOffset = 3;       %distance in stdGaussMask  (0-->5.9 when std is 1/16)
%       
framesJustFlanker=int8(15); 
framesTargetOn=int8(400);     
thresh = 0.001;
yPositionPercent = 0.5;  
toggleStim = 1;
typeOfLUT= 'useThisMonitorsUncorrectedGamma';  %typeOfLUT= 'linearizedDefault'; rangeOfMonitorLinearized=[0.05 0.8];
rangeOfMonitorLinearized=[0 1];

%freeDrinks = trainingStep(fd, stim, rateCriterion(6,5), noTimeOff());

msFlushDuration         =1000;
msRewardDuration        =100;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =4000;
msRewardSoundDuration   =msRewardDuration;

msRequestRewardDuration             =200;
percentCorrectionTrials             =.5;
msResponseTimeLimit                 =0;
pokeToRequestStim                   =1;
maintainPokeToMaintainStim          =1;
msMaximumStimPresentationDuration   =0;
maximumNumberStimPresentations      =0;
doMask                              =1;

    msPenalty               =12000;

    
mean = 0.2;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
stdGaussMask = 1/5; 
flankerOffset = 0; 

stim1 =  cuedIfFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,distractorContrast,mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxWidth,maxHeight,scaleFactor,interTrialLuminance); 
nafc1=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)

%mean = 0.5; (?)
stdGaussMask = 1/16; 
flankerContrast = [0.3];
flankerOrientations = [pi/6,0,-pi/6];
distractorContrast = [0.3];
flankerOffset = 3; 

stim2 =  cuedIfFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,distractorContrast,mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxWidth,maxHeight,scaleFactor,interTrialLuminance); 
nafc2=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)
         
%then 
flankerContrast = [0.9];
distractorContrast = [0.9];

%then
flankerContrast = [1];
distractorContrast = [1];       

%then
mean = 0.5; %(?)
typeOfLUT= 'linearizedDefault';
rangeOfMonitorLinearized=[0.05 0.8];

%then A B or C
%A
goRightContrast =    [1/256 0.25 0.5 0.75 1];    %choose a random contrast from this list each trial
goLeftContrast = goRightContrast;

%B
toggleStim = 0;

%C
goRightOrientations = pi/6*[0:5]/6; %i.e. 6 small values including zero
goRightOrientations = pi/12; %keeps the ratrix small till you need this step
goLeftOrientations = -goRightOrientations; 
flankerOrientations= union(goRightOrientations,goLeftOrientations);


stim3 =  cuedIfFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,distractorContrast,mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxWidth,maxHeight,scaleFactor,interTrialLuminance); 
nafc3=nAFC(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,...
           msPenalty,msRequestRewardDuration,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration)


       
featureGoRightWithTwoFlankers_level_1 = trainingStep(nafc1, stim1, performanceCriterion(.85,100), nTrialsThenWait([500],[1],[4],[1]));
featureGoRightWithTwoFlankers_level_2 = trainingStep(nafc2, stim2, performanceCriterion(.85,100), nTrialsThenWait([500],[1],[4],[1]));
featureGoRightWithTwoFlankers_level_3 = trainingStep(nafc3, stim3, performanceCriterion(.85,100), nTrialsThenWait([500],[1],[4],[1]));
p=protocol('ifGratingGoRight rat test',{featureGoRightWithTwoFlankers_level_1, featureGoRightWithTwoFlankers_level_2, featureGoRightWithTwoFlankers_level_3});

[s  r]=setProtocolAndStep(s ,p,1,0,1,1,r,'first try','pmm');
[s2 r]=setProtocolAndStep(s2,p,1,0,1,1,r,'first try','pmm');
[s3 r]=setProtocolAndStep(s3,p,1,0,1,1,r,'first try','pmm');
[s4 r]=setProtocolAndStep(s4,p,1,0,1,1,r,'first try','pmm');
[s5 r]=setProtocolAndStep(s5,p,1,0,1,1,r,'first try','pmm');
[s6 r]=setProtocolAndStep(s6,p,1,0,1,1,r,'first try','pmm');
[s7 r]=setProtocolAndStep(s7,p,1,0,1,1,r,'first try','pmm');

[s  r]=setProtocolAndStep(s ,p,1,0,1,1,r,'first try','pmm'); %test
isa(stim1,'stimManager')
isa(stim1,'cuedIfFeatureGoRightWithTwoFlank')
stim1