function [default t]=getDefaultParameters(t, protocolType,protocolVersion,defaultSettings);


if ~exist('protocolType','var') || isempty(protocolType)
    protocolType='goToRightDetection';
end

if ~exist('protocolVersion','var') || isempty(protocolVersion)
    protocolVersion='2_4'; % 2_3 had a left error
end

if ~exist('defaultSettings','var') || isempty(defaultSettings)
    defaultSettings='Oct.09,2007';
end

switch defaultSettings
    case 'Oct.09,2007'

        default.sndManager=makeStandardSoundManager();


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
        %         default.scalarStartsCached = 0; %removed pmm 2008/05/02
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

        default.framesMotionDelay = Inf;
        default.numMotionStimFrames = 0;
        default.framesPerMotionStim = 0;

        default.cueLum=[];                %luminance of cue square
        default.cueSize=0;               %roughly in pixel radii

        default.xPositionPercent = 0.5;  %target position in percent ScreenWidth
        default.cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank
       
        
        % these were never used due to toggleStim ==1 
        % they were defined up to Jan 2, 2009: 
        %      default.framesTargetOn=int8(50);
        %      default.framesJustFlanker=int8(2);   
        % but then replaced by functionality and not name
        % at that point all rats still havd toggleStim ==1 , but humans used toggleStim ==0
        %       default.framesTargetOn=int8([0 5]);  % aka stimulus.framesStimOn; bad name
        %       default.framesJustFlanker=int8([0 5]);    
        % in order to be replaced evantually by framesTargetOnOff & framesFlankerOnOff
        % in code that was written on jan 12, 2009 on the trunk
        % but only took over rack1 temp when merge happened
        default.targetOnOff= int8([1 10]);
        default.flankerOnOff=int8([1 10]);
        
        default.thresh = 0.001;
        default.yPositionPercent = 0.5;
        default.toggleStim = 1;

        default.displayTargetAndDistractor =0;
        default.xPosNoise=0.0;%standard deviation of noise in fractional screen width
        default.yPosNoise=0;%standard deviation of noise in fractional screen height
        default.persistFlankersDuringToggle=1;

        default.msFlushDuration         =1000;
        %default.rewardSizeULorMS        =0;     %not used! but still defined in nAFC.  Eventually remove. pmm
        default.msMinimumPokeDuration   =10;
        default.msMinimumClearDuration  =10;
        %default.msPenalty               =4000;
        %default.msRewardSoundDuration   =0; %not used! but still defined in nAFC.  Eventually remove. pmm

        default.requestRewardSizeULorMS             =0;
        default.percentCorrectionTrials             =.5; % starts being used on 09-Oct-2008 (always .5 before that)
        default.msResponseTimeLimit                 =0;
        default.pokeToRequestStim                   =1;
        default.maintainPokeToMaintainStim          =1;
        default.msMaximumStimPresentationDuration   =0;
        default.maximumNumberStimPresentations      =0;
        default.doMask                              =1;

        % constant parameters for reinforcement manager
        default.fractionOpenTimeSoundIsOn=0.6;
        default.fractionPenaltySoundIsOn=1;

        % software additions that explicitely state previously undefined defaults
        default.flankerPosAngle=0; %May.30,2008

        %these are explicitely overwritten in setShapingPMM
        default.msPenalty=1000; %May.30,2008
        default.scheduler=minutesPerSession(90,3); %May.30,2008
        default.graduation = repeatIndefinitely(); %May.30,2008

        default.msPuff=0; %July.18,2008

        %default set to nan, which is same as before Nov.12,2008
        %can be overwritten to get relative values
        default.fpaRelativeTargetOrientation=nan;
        default.fpaRelativeFlankerOrientation=nan;
        default.svnRev={'svn://132.239.158.177/projects/ratrix/tags/v1.0.1'}; %1/8/09 - added to support trunk version of trainingStep
        default.svnCheckMode='session';
        %default.svnRev{2}=1920; %not used yet
        
        default.blocking=[];
        default.fitRF=[];
        default.dynamicSweep=[];
        
        default.renderMode='ratrixGeneral-maskTimesGrating';
        
        %for trial manager
        default.eyeTracker=[];
        default.eyeController=[];
        default.datanet=[];
            
        default.frameDropCorner={'off'};
        default.dropFrames=true;  % dropped frames were added in and took effect after feb 2,2009; before: april 11th, 2009
        default.displayMethod='ptb';
        default.requestPorts='center';
        default.saveDetailedFramedrops=true;

        %for reinforcment manager
        default.requestMode='first';  % only first request lick is rewarded
        
        efault.allowFreeDrinkRepeatsAtSameLocation=false;
        
        default.dynamicFlicker=[];    % never was dynamicFlicker by default; oct 14, 2009
        
        default.delayManager=[];  %defaults made explicit Oct 19, 2009
        default.responseWindowMs=[0 Inf];
        default.showText=true;
        default.tmClass='nAFC';
        
    case 'Apr.13,2009'
        %get the above defaults and add on
        [default t]=getDefaultParameters(t,'unused','none','Oct.09,2007');
        default.toggleStim = false;

    otherwise
        error ('unknown default settings date')

end


% save these
default.protocolType=protocolType;
default.protocolVersion=protocolVersion;
default.protocolSettings = defaultSettings;

%% set protocol type
switch protocolVersion
    case 'none'
        % do nothing... just for internal setting calls... don't use
    case '1_0'
        switch protocolType

            case 'goToSide'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0,pi/2];
                default.goLeftOrientations =  [0,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list\

                default.stdGaussMask = 1/8;
                default.positionalHint=0.2;
                default.displayTargetAndDistractor=1;

            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [0,pi/2];
                default.goLeftOrientations =  [0,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            case 'goToLeftDetection'

                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0,pi/2];
                default.goLeftOrientations =  [0,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            case 'tiltDiscrim'

                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];
                %default.distractorContrast = [0]; %do we need this?
                %note: displayTargetAndDistractor =0; in default

                default.goRightOrientations = [pi/6];
                default.goLeftOrientations =  [-pi/6];
                default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list
                %default.topYokedToBottomFlankerOrientation =1;  %note this is redundant with default params

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;


            otherwise
                error('unknown type of protocol requested')
        end

    case '1_1'
        switch protocolType
            case 'goToRightDetection'  % has four orientations
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [-pi/4,0,pi/4,pi/2]; %-45,0,45,90=horiz
                default.goLeftOrientations =  [-pi/4,0,pi/4,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
            case 'goToLeftDetection'  % has four orientations
                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [-pi/4,0,pi/4,pi/2]; %-45,0,45,90=horiz
                default.goLeftOrientations =  [-pi/4,0,pi/4,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
            case 'tiltDiscrim' % has +/- 45

                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];
                %default.distractorContrast = [0]; %do we need this?
                %note: displayTargetAndDistractor =0; in default

                default.goRightOrientations = [pi/4];
                default.goLeftOrientations =  [-pi/4];
                default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list
                %default.topYokedToBottomFlankerOrientation =1;  %note this is redundant with default params

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end

    case '1_2'
        switch protocolType

            case 'tiltDiscrim' % has +/- 45

                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];
                %default.distractorContrast = [0]; %do we need this?
                %note: displayTargetAndDistractor =0; in default

                default.goRightOrientations = [pi/4];
                default.goLeftOrientations =  [-pi/4];
                default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list
                %default.topYokedToBottomFlankerOrientation =1;  %note this is redundant with default params

                default.stdGaussMask = 1/8;
                default.positionalHint=0.2;
                default.displayTargetAndDistractor=0;

            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end
    case '1_3'  %no more horizontal targets
        switch protocolType

            case 'goToSide'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/8;
                default.positionalHint=0.2;
                default.displayTargetAndDistractor=1;

            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            case 'goToLeftDetection'

                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end
    case {'1_4','1_7'}  %no more horizontal targets or flankers
        switch protocolType

            case 'goToSide'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0]; %choose a random orientation from this list

                default.stdGaussMask = 1/8;
                default.positionalHint=0.2;
                default.displayTargetAndDistractor=1;

            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            case 'goToLeftDetection'

                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [0];
                default.flankerOrientations = [0]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end
    case '1_5'  %h-v  used by adam and pam
        switch protocolType

            case 'tiltDiscrim' % like 1_2 w/ its hint but has +/- 90 Horiz-Vert

                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];
                %default.distractorContrast = [0]; %do we need this?
                %note: displayTargetAndDistractor =0; in default

                default.goRightOrientations = [0];
                default.goLeftOrientations =  [pi/2];
                default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list
                %default.topYokedToBottomFlankerOrientation =1;  %note this is redundant with default params

                default.stdGaussMask = 1/8; %Smaller so the positional hint is more evident
                default.positionalHint=0.1; %
                default.displayTargetAndDistractor=0;

            otherwise
                protocolVersion=protocolVersion
                protocolType=protocolType
                error('unknown type of protocol for this version')
        end

    case '1_6' % similar to 1_1 but all four flanker orients
        switch protocolType
            case 'goToRightDetection'  % has four orientations
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [-pi/4,0,pi/4,pi/2]; %-45,0,45,90=horiz
                default.goLeftOrientations =  [-pi/4,0,pi/4,pi/2];
                default.flankerOrientations =  [-pi/4,0,pi/4,pi/2];

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
            case 'goToLeftDetection'  % has four orientations
                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [-pi/4,0,pi/4,pi/2]; %-45,0,45,90=horiz
                default.goLeftOrientations =  [-pi/4,0,pi/4,pi/2];
                default.flankerOrientations =  [-pi/4,0,pi/4,pi/2];

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;


            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end

    case '1_8' % only 2 orients and they are -15, 15
        %!!!!MISTAKE version, not germline, used for only 2 days, lacks flankerPosAngle
        %no real problem--could be construed as an unnessesary shaping step that eases from
        %vertical to tipped flankerPositions

        switch protocolType
            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                orients=[-pi/12,pi/12];%%-15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
                default.phase=[0 pi];
            case 'goToLeftDetection'  % has four orientations
                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                orients=[-pi/8,pi/8]; %%-15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

                default.phase=[0 pi];
            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end
    case {'1_9', '2_1', '2_2','2_3'} % only 2 orients and they are -15, 15   fixed and first used on Jun.04,2008 sadly, not the same angle L vs R
        switch protocolType
            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                orients=[-pi/12,pi/12];%%-15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
                default.phase=[0 pi];
                default.flankerPosAngle=orients;

            case 'goToLeftDetection'  % has four orientations
                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                orients=[-pi/8,pi/8]; %%-22.5, 22.5  % MISTAKE!! this is a different angle for left rats! should be 15deg= pi/12 instead is 22.5 deg..
                %leaving it incorrect b/c thats what it is for these rats!
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

                default.phase=[0 pi];
                default.flankerPosAngle=orients;

            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end
    case {'2_4','2_5validate'} %like 2_3 but with fixed orientations for left
        switch protocolType
            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                orients=[-pi/12,pi/12];%%-15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
                default.phase=[0 pi];
                default.flankerPosAngle=orients;

            case 'goToLeftDetection'  
                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                orients=[-pi/12,pi/12]; %fixed, now -15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;

                default.phase=[0 pi];
                default.flankerPosAngle=orients;
            case 'goNoGo'
                default.goRightContrast = [1];    %RULE FOR CODE RE-USE: 'goDetection' uses "right" for "go"
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                orients=[-pi/12,pi/12];%%-15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
                default.phase=[0 pi];
                default.flankerPosAngle=orients;
                
                
                %set a few things unique to go-no-go
                percentile=0.99;
                value=10000;
                fixedDelayMs=1000;
                default.delayManager=flatHazard(percentile, value, fixedDelayMs);
                
                default.responseWindowMs=[500 1500];  % do these conflict with one another?
                default.responseLockoutMs=500;
                
                default.requestPorts='none';
                default.tmClass='goNoGo';
                % default.rewardNthCorrect=1*[20,80,100,150,250];  % really? 
            case 'cuedGoNoGo'
                default.goRightContrast = [1];    %RULE FOR CODE RE-USE: 'goDetection' uses "right" for "go"
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                orients=[-pi/12,pi/12];%%-15, 15
                default.goRightOrientations = orients;
                default.goLeftOrientations =  orients;
                default.flankerOrientations = orients;

                default.stdGaussMask = 1/5;
                default.positionalHint=0;
                default.displayTargetAndDistractor=0;
                default.phase=[0 pi];
                default.flankerPosAngle=orients;
                
                
                %set a few things unique to go-no-go
                %percentile=0.99;
                %value=10000;
                %fixedDelayMs=1000;
                %default.delayManager=flatHazard(percentile, value, fixedDelayMs);
                default.delayManager=constantDelay(1000);
                
                default.responseWindowMs=[500 1500];  % do these conflict with one another?
                default.responseLockoutMs=500;
                
                default.requestPorts='none';
                default.tmClass='nAFC'; % not actually using goNoGo trial Manager!
                
                
            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end
    case '2_0'
        switch protocolType
            case 'tiltDiscrim' %like 1_0, but protocol has auto shaping smaller targets

                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [pi/6];
                default.goLeftOrientations =  [-pi/6];
                default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0; %
                default.displayTargetAndDistractor=0;

            otherwise
                protocolVersion=protocolVersion
                error('unknown type of protocol for this version')
        end



    otherwise
        error ('unknown version')
end