function [parameterStructure, super] = getDefaultParameters(tm)

% create a parameter structure and a super structure with default parameters

super.soundMgr            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

s.maxWidth                =1024;
s.maxHeight               =768;
s.scaleFactor             =[1 1]; %1?
s.interTrialLuminance     =0.5;


        s.goRightOrientations = [0,pi/2]; %choose a random orientation from this list
        s.goLeftOrientations =  [0,pi/2];
        s.flankerOrientations = [0,pi/2]; 
        s.distractorOrientations = [0];
        s.distractorFlankerOrientations = [0];
        s.topYokedToBottomFlankerOrientation =1;

        s.goRightContrast = [1];   
        s.goLeftContrast =  [1];   
        s.flankerContrast = [0.25];
        s.distractorContrast = 1;
        s.distractorFlankerContrast = 0;
        s.topYokedToBottomFlankerContrast =1;
        
        numPhase = 4; 
        s.phase= 2*pi * [0: numPhase-1]/numPhase;
        s.flankerYokedToTargetPhase =0;

        
        s.pixPerCycs = 32;
        s.stdGaussMask = 1/16;
        s.stdsPerPatch = 4;
        s.thresh = 0.001;
        s.gratingType='sine';
        s.gaborNormalizeMethod = 'normalizeVertical';

        s.xPositionPercent = 0.5;
        s.targetYPosPct = 0.5;
        s.flankerOffset = 5; %distance in stdGaussMask  (0-->5.9 when std is 1/16)
        s.positionalHint=0; %fraction of screen hinted.
        s.xPosNoise=0; %
        s.yPosNoise=0; %
        s.cuePercentTargetEcc = 0.6; 
        
        s.framesTargetOnOff=int8([20 60]);
        s.framesFlankerOnOff=int8([10 60]);

        s.typeOfLUT = 'useThisMonitorsUncorrectedGamma';
        s.rangeOfMonitorLinearized=[0 1];
        s.mean = 0.5;              %normalized luminance - if not 0.5 then grating can be detected as mean lum changes
        s.cueLum=0.5;              
        s.cueSize=4;

        s.displayTargetAndDistractor=0;
        s.distractorYokedToTarget=1;
        
        s.distractorFlankerYokedToTargetFlanker = 1;
        s.fractionNoFlanks=0;
        s.toggleStim = 1;
        s.persistFlankersDuringToggle=1;
        
        s.msPenaltyFlashDuration=100;
        s.numPenaltyFlashes=int8(3);
        s.maxDiscriminandumSecs=10;
        s.advancedOnRequestEnd=0;
        s.interTrialDimmingFraction=0.01;

        s.renderMode='ratrixGeneral';

        s.shapedParameter='positionalHint';
        s.shapingMethod='linearChangeAtCriteria';
        shapingValues.numSteps = uint8(6);
        shapingValues.performanceLevel = 0.75;
        shapingValues.numTrials = uint8([100]);
        shapingValues.startValue = 0.2;
        shapingValues.currentValue = shapingValues.startValue;
        shapingValues.goalValue = 0.1;


        s.shapingValues = shapingValues;
        s.LUT=[];
        s.cache=[];
        s.calib=[];
        s.stimDetails=[];

        parameterStructure=s;
       

super.msFlushDuration         =1000;
super.msRewardDuration        =150; %todo: ? get rid of because the reward manager has it
super.msMinimumClearDuration  =10;
super.msMinimumPokeDuration   =10;
super.msPenalty               =4000; %todo: ? get rid of because the reward manager has it
super.msRewardSoundDuration   =super.msRewardDuration;

super.msRequestRewardDuration             =0; %todo: this should move the reward manager
super.percentCorrectionTrials             =.5; %todo: this should move the "correlation manager"
super.msResponseTimeLimit                 =0;
super.pokeToRequestStim                   =1;
super.maintainPokeToMaintainStim          =1; %todo: ? does this still work?
super.msMaximumStimPresentationDuration   =0;
super.maximumNumberStimPresentations      =0;
super.doMask                              =1;
super.description='basicTrialManager';
        
%new
%todo: add these in?
% super.station=                            [];
% super.window=                             [];
% super.ifi=                                [];
% super.framePulsesEnabled=                 1;
% super.manualEnabled=                      1;
% super.manualOn=                           1;
% super.timingCheckPct=                     [];
% super.numFrameDropReports=                1000;
% super.percentCorrectionTrials=            0.5;
% super.percentRejectSameConsecutiveAnswer= [0 0 0 1];

% parameters for reinforcement manager
rm.type='rewardNcorrectInARow';
rm.fractionOpenTimeSoundIsOn=0.6;
rm.fractionPenaltySoundIsOn=1;
rm.msRewardNthCorrect=2*[20,80,100,150,250];
rm.msPenalty=15000;  %is this in reinforcement manager?
rm.scalar=1;
rm.scalarStartsCached=0;
parameterStructure.rm=rm;