function same = verifyCalcStim080216(s)


%turn calibrationModeOn
%have old inflate from 

%% 
rootPath='C:\pmeier\Ratrix';
addpath(genpath(fullfile(rootPath,'classes')));

%% defaultSettingsDate='Oct.09,2007' 

        default.sndManager=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
            soundClip('keepGoingSound','allOctaves',[300],20000), ...
            soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
            soundClip('wrongSound','tritones',[300 400],20000)});
        %default.sndManager==makeStandardSoundManager()  should preserve
        %functionality... pmm added

        default.maxWidth                =1024;
        default.maxHeight               =768;
        default.scaleFactor             =[1 1];
        default.interTrialLuminance     =0.5;

        default.pixPerCycs =64;
        default.gratingType='square';
        numPhase = 4; default.phase= 2*pi * [0: numPhase-1]/numPhase;
        default.mean = 0.2;
        default.rewardNthCorrect=1*[20,80,100,150,250];
        default.scalar = 1;
%         default.scalarStartsCached = 0; %removed 
        default.maxCorrectOnSameSide=int8(4);

        default.typeOfLUT= 'useThisMonitorsUncorrectedGamma';
        default.rangeOfMonitorLinearized=[0.0 0.5];

        default.flankerOffset = 0;
        default.flankerContrast = [0];

        %%%%%%%%% ADDED DEFAULT VALUES FOR DISPLAYING DISTRACTORS WITH
        %%%%%%%%% FLANKERS %%%%%%%%%%%%%%%%%%%%%%%%% Y.Z
        

        default.distractorOrientation = [0];
        default.distractorContrast = 0;
        default.distractorFlankerOrientation = [0];
        default.distractorFlankerContrast = 0;
        default.distractorYokedToTarget=1;
        default.distractorFlankerYokedToTargetFlanker = 1;
        default.flankerYokedToTargetPhase =0;
        default.fractionNoFlanks=0;

        %%%%%%%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%

        default.topYokedToBottomFlankerOrientation =1;
        default.topYokedToBottomFlankerContrast =1;
        
        default.shapedParameter=[];
        default.shapingMethod=[];
        default.shapingValues=[];
       
        default.cueLum=0;                %luminance of cue square
        default.cueSize=0;               %roughly in pixel radii

        default.xPositionPercent = 0.5;  %target position in percent ScreenWidth
        default.cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank

        default.framesJustFlanker=int8(2);
        default.framesTargetOn=int8(50);
        default.thresh = 0.001;
        default.yPositionPercent = 0.5;
        default.toggleStim = 1;

        default.displayTargetAndDistractor =0;
        default.xPosNoise=0.0;%standard deviation of noise in fractional screen width
        default.yPosNoise=0;%standard deviation of noise in fractional screen height
        default.persistFlankersDuringToggle=1;

        default.msFlushDuration         =1000;
        default.rewardSizeULorMS        =0;     %not used! but still defined in nAFC.  Eventually remove. pmm
        default.msMinimumPokeDuration   =10;
        default.msMinimumClearDuration  =10;
        default.msPenalty               =4000;
        default.msRewardSoundDuration   =0; %not used! but still defined in nAFC.  Eventually remove. pmm

        default.requestRewardSizeULorMS             =0;
        default.percentCorrectionTrials             =.5;
        default.msResponseTimeLimit                 =0;
        default.pokeToRequestStim                   =1;
        default.maintainPokeToMaintainStim          =1;
        default.msMaximumStimPresentationDuration   =0;
        default.maximumNumberStimPresentations      =0;
        default.doMask                              =1;

        % constant parameters for reinforcement manager
        default.fractionOpenTimeSoundIsOn=0.6;
        default.fractionPenaltySoundIsOn=1;
        
%%        protocolVersion='1_2';  protocolType='tiltDiscrim' % has +/- 45
%                 
%                 default.goRightContrast = [1];    %choose a random contrast from this list each trial
%                 default.goLeftContrast =  [1];
%                 default.flankerContrast = [0];
%                 %default.distractorContrast = [0]; %do we need this?
%                 %note: displayTargetAndDistractor =0; in default
% 
%                 default.goRightOrientations = [pi/4];
%                 default.goLeftOrientations =  [-pi/4];
%                 default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list
%                 %default.topYokedToBottomFlankerOrientation =1;  %note this is redundant with default params
% 
%                 default.stdGaussMask = 1/8;
%                 default.positionalHint=0.2;
%                 default.displayTargetAndDistractor=0;
                
%% case 'goToRightDetection'   1_3
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
                
%%


default.gRightOrientations=[pi]
default.stdGaussMask = 1/5;
        default.pixPerCycs =64;
                default.mean = 0.5;

p=default;
stim = ifFeatureGoRightWithTwoFlank([p.pixPerCycs],[p.goRightOrientations],[p.goLeftOrientations],[p.flankerOrientations],...
    p.topYokedToBottomFlankerOrientation,p.topYokedToBottomFlankerContrast,[p.goRightContrast],[p.goLeftContrast],...
    [p.flankerContrast],p.mean,p.cueLum,p.cueSize,p.xPositionPercent,p.cuePercentTargetEcc,p.stdGaussMask,p.flankerOffset,...
    p.framesJustFlanker,p.framesTargetOn,p.thresh,p.yPositionPercent,p.toggleStim,p.typeOfLUT,p.rangeOfMonitorLinearized,...
    p.maxCorrectOnSameSide,p.positionalHint,p.xPosNoise,p.yPosNoise,p.displayTargetAndDistractor,p.phase,p.persistFlankersDuringToggle,...
    p.distractorFlankerYokedToTargetFlanker,p.distractorOrientation,p.distractorFlankerOrientation,p.distractorContrast,...
    p.distractorFlankerContrast, p.distractorYokedToTarget, p.flankerYokedToTargetPhase, p.fractionNoFlanks,...
    p.shapedParameter, p.shapingMethod, p.shapingValues,'square',...
    p.maxWidth,p.maxHeight,p.scaleFactor,p.interTrialLuminance);
  
%% newStimOut
                
trialRecords.response=3;
trialRecords.correct=1;
trialRecords.stimDetails.correctionTrial=0;
trialRecords.targetPorts=1;
    
               [newSM,   updateSM, newStimOut, LUT, scaleFactor,type, targetPorts, distractorPorts, stimulusDetails, interTrialLuminance]= ...
                calcStim(stim, 'nAFC', 100, [3], 3, 1024, 768,  trialRecords);

%% oldStimOut
            
  [newSM,   updateSM, oldStimOut, LUT, scaleFactor,type, targetPorts, distractorPorts, stimulusDetails, interTrialLuminance]= ...
                calcStimOld080216(stim, 'nAFC', 100, [3], 3, 1024, 768,  trialRecords);
            
%%

close all


figure;  imagesc(reshape(newStimOut(:,:,1),768,1024));
figure;  imagesc(reshape(oldStimOut(:,:,1),768,1024));
figure

 subplot(231);  imagesc(reshape(newStimOut(:,:,1),768,1024));
 subplot(232);  imagesc(reshape(oldStimOut(:,:,1),768,1024));
 diffStim=double(newStimOut)-double(oldStimOut);
 subplot(233);  imagesc(reshape(diffStim(:,:,1),768,1024));
 subplot(234);  hist(double(newStimOut(diffStim~=0)),256)
 subplot(235);  hist(double(oldStimOut(diffStim~=0)),256)
subplot(236);  hist(double(diffStim(diffStim~=0)),256)
colormap(gray)
same=0;

where=[];
errorAt=[];
where=find(oldStimOut(:,:,1)~=newStimOut(:,:,1));
if length(where)>0
    errorAt=zeros(768,1024);
    errorAt(where)=1;
    figure; imagesc(errorAt)
    unique(diffStim)
else
    same=1;
end

same
            