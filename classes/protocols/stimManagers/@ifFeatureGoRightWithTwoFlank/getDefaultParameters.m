function [default t]=getDefaultParameters(t, protocolType,protocolVersion,defaultSettings);

switch defaultSettings
    case 'Oct.09,2007'

        default.sndManager=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
            soundClip('keepGoingSound','allOctaves',[300],20000), ...
            soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
            soundClip('wrongSound','tritones',[300 400],20000)});


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

        default.protocolType=protocolType;
        default.protocolVersion=protocolVersion;
        default.protocolSettings = defaultSettings;

        default.cueLum=[];                %luminance of cue square
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
        %default.rewardSizeULorMS        =0;     %not used! but still defined in nAFC.  Eventually remove. pmm
        default.msMinimumPokeDuration   =10;
        default.msMinimumClearDuration  =10;
        %default.msPenalty               =4000;
        %default.msRewardSoundDuration   =0; %not used! but still defined in nAFC.  Eventually remove. pmm

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
        
        % software additions that explicitely state previously undefined defaults
        default.flankerPosAngle=0; %May.30,2008

        %these are explicitely overwritten in setShapingPMM
        default.msPenalty=1000; %May.30,2008
        default.scheduler=minutesPerSession(90,3); %May.30,2008
        default.graduation = repeatIndefinitely(); %May.30,2008
        
        default.msPuff=0; %July.18,2008
            
    otherwise
        error ('unknown default settings date')

end


%% set protocol type
switch protocolVersion
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
          case {'1_9', '2_1', '2_2'} % only 2 orients and they are -15, 15   fixed and first used on Jun.04,2008
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

                orients=[-pi/8,pi/8]; %%-15, 15
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