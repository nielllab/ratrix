function tm=ifFeatureGoRightWithTwoFlankTrialManager(varargin)
% ||ifFeatureGoRightWithTwoFlankTrialManager||  class constructor.
% This is the first merging of the stimulus manager and the trial manager
% PMM TVN 8/22/2007 first merge, quick for calibration
% PMM Y.Z 12/05/2007 second merge, better for calcStim

%t=ifFeatureGoRightWithTwoFlankTrialManager()

switch nargin
    case 0
        % if no input arguments, create a default object

        
        % edf: you must not change definition of object.  these belong on parent, not you.
        %extra non input values
        %PMM: Stimulus managers are going to be removed. Consider moving these to
        %trialManager class
        %         super.maxWidth=1;
        %         super.maxHeight=1;
        %         super.scaleFactor=0;
        %         super.interTrialLuminance=0;
        %

        s.maxWidth=[];
        s.maxHeight=[];
        s.scaleFactor=[];
        s.interTrialLuminance=[];

        %
        % orientations in radians , these a distributions of possible orientations
        % mean, cueLum, cueSize, contrast, yPositionPercent, xPositionPercent normalized (0 <= value <= 1)
        % stdGaussMask is the std dev of the enveloping gaussian, in normalized  units of the vertical height of the stimulus image
        % thresh is in normalized luminance units, the value below which the stim should not appear
        % cuePercentTargetEcc is an vestigal variable not used
        
        s.goRightOrientations = [];
        s.goLeftOrientations = [];
        s.flankerOrientations = [];
        s.distractorOrientations = [];
        s.distractorFlankerOrientations = [];
        s.topYokedToBottomFlankerOrientation =1;

        s.goRightContrast = [];
        s.goLeftContrast = [];
        s.flankerContrast = [];
        s.distractorContrast = 0;
        s.distractorFlankerContrast = 0;
        s.topYokedToBottomFlankerContrast =1;
        
        s.phase=0;
        s.flankerYokedToTargetPhase =0;

        s.pixPerCycs = 64; %if empty inflate fails
        s.stdGaussMask = 0;
        s.stdsPerPatch=4; %this is an even number that is very reasonable fill of square--has been hardcoded until 8/21/07. Before that, it was always 4.
        s.thresh = 0.001;
        s.gratingType='square';
        s.gaborNormalizeMethod = 'normalizeVertical';

        s.xPositionPercent = 0;
        s.targetYPosPct = 0;
        s.flankerOffset = 0;
        s.positionalHint=0; %fraction of screen hinted.
        s.xPosNoise=0; %
        s.yPosNoise=0; %
        s.cuePercentTargetEcc = 0;

        s.framesTargetOnOff=int8([1 100]);
        s.framesFlankerOnOff=int8([1 100]);

        s.typeOfLUT = 'linearizedDefault';
        s.rangeOfMonitorLinearized=[0 1];
        s.mean = 0;
        s.cueLum=0;
        s.cueSize=1;

        s.displayTargetAndDistractor=0;
        s.distractorYokedToTarget=1;

        s.distractorFlankerYokedToTargetFlanker = 1;
        s.fractionNoFlanks=[];
        s.toggleStim = 0;
        s.persistFlankersDuringToggle=[];

        s.msPenaltyFlashDuration=[];
        s.numPenaltyFlashes=[];
        s.maxDiscriminandumSecs=[];
        s.advancedOnRequestEnd=[];
        s.interTrialDimmingFraction=[];

        s.renderMode='ratrixGeneral';

        s.shapedParameter=[];
        s.shapingMethod=[];
        

        %these have moved to the cache
%         s.goRightStim =[];
%         s.goLeftStim =[];
%         s.flankerStim =[];
%         s.distractorStim = [];
%         s.distractorFlankerStim= [];

    s.shapingValues=[];
    s.LUT=[];

    t=s;
    
        % These are displaced trial manager fields in the default
        % constructor
        super.msFlushDuration=0;
        super.rewardSizeULorMS=0;
        super.msMinimumPokeDuration=0;
        super.msMinimumClearDuration=0;
        super.soundMgr=soundManager();
        super.msPenalty=0;
        super.msRewardSoundDuration=0;
        super.reinforcementManager=reinforcementManager();
        super.description='';

        % These are the old nAFC fields
        super.requestRewardSizeULorMS=0;
        %         t.percentCorrectionTrials=0;
        super.msResponseTimeLimit=0;
        super.pokeToRequestStim=0;
        super.maintainPokeToMaintainStim=0;
        super.msMaximumStimPresentationDuration=0;
        super.maximumNumberStimPresentations=0;
        super.doMask=0;

        % a=trialManager();
        %    t = class(t,'nAFC',a);

        % trialManager data members that this method depends on:
        super.station  = 0;    %the station where this trial is running
        super.window   = 1 ;   %pointer to target PTB window (should already be open)
        super.ifi      = 0;    %inter-frame-interval for PTB window in seconds (measured when window was opened)
        super.manualOn = 1;    %allow keyboard responses, quitting, pausing, rewarding, and manual poke indications
        super.timingCheckPct = 0;      %percent of allowable frametime error before apparently dropped frame is reported
        super.numFrameDropReports =1000;   %number of frame drops to keep detailed records of for this trial
        super.percentCorrectionTrials  =0;    %probability that if this trial is incorrect that it will be repeated until correct
        %note this needs to be moved here from wherever it currently is

        



        %     s = class(s,'ifFeatureGoRightWithTwoFlank',stimManager());
        
        t.cache.goRightStim=[];       
        t.cache.goLeftStim = [];
        t.cache.flankerStim=[];       
        t.cache.distractorStim = [];
        t.cache.distractorFlankerStim=[];
        
        t.calib.frame=0;
%         t.calib.framesPerCycleRequested=0;
%         t.calib.framesPerCycleUsed=0;
%         t.calib.contrastNormalizationPerOrientation=[];
        t.calib.method='sweepAllPhasesPerFlankTargetContext';
        t.calib.data=[];

        t.stimDetails=[];%per trial info will go here
        
% More interesting default constructor [to be deleted eventually]
% 
% 
%         super.maxWidth=1280;
%         super.maxHeight=1024;
%         super.scaleFactor=1;
%         super.interTrialLuminance=0;
% 
%         s.pixPerCycs =32;
%         numPhase = 4; 
%         s.phase= 2*pi * [0: numPhase-1]/numPhase; % choose random phase, draw from movie with that (hieght x width x orientations x phase)
%         
%         s.goRightOrientations = [0,pi/2]; %choose a random orientation from this list
%         s.goLeftOrientations =  [0,pi/2];
%         s.flankerOrientations = [0]; 
%         s.distractorOrientations = [0];
%         s.distractorFlankerOrientations = [0];
%         
%         s.topYokedToBottomFlankerOrientation =1;
%         s.topYokedToBottomFlankerContrast =1;
%         s.flankerYokedToTargetPhase =1;
%         
%         s.goRightContrast = [1];    %choose a random contrast from this list each trial
%         s.goLeftContrast =  [1];    %this is normally 0 but just set to 1 for calibration tests
%         s.flankerContrast = [0];
%         s.distractorContrast = 0;
%         s.distractorFlankerContrast = 0;
%         
%         s.mean = 0.5;              %normalized luminance - if not 0.5 then grating can be detected as mean lum changes
%         s.cueLum=0.5;              %luminance of cue square
%         s.cueSize=4;               %roughly in pixel radii
% 
%         s.xPositionPercent = 0.5;  %target position in percent ScreenWidth
%         s.cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank
%         s.stdGaussMask = 1/16;     %in fraction of vertical extent of stimulus
%         s.flankerOffset = 5;       %distance in stdGaussMask  (0-->5.9 when std is 1/16)
%                
%         s.framesTargetOnOff=int8([1 6]);
%         s.framesFlankerOnOff=int8([2 6]);
%         must do after blessing...
%         frameTimes = getFrameChangeTimes(t)
%         frameTimes=[1 2 6];
%         
%         
%         s.thresh = 0.001;
%         s.targetYPosPct = 0.5;
%         s.toggleStim = 0; % This method might have to change
%         s.typeOfLUT= 'useThisMonitorsUncorrectedGamma';
%         s.rangeOfMonitorLinearized=[0 1];
%         s.maxCorrectOnSameSide=-1;
% 
%         s.positionalHint=0; %fraction of screen hinted.
%         s.xPosNoise=0; %
%         s.yPosNoise=0; %
%         
%         s.displayTargetAndDistractor=0;
%         s.persistFlankersDuringToggle=1;
% 
%         s.distractorFlankerYokedToTargetFlanker = 1;
%         s.distractorYokedToTarget=1;
%         s.flankerYokedToTargetPhase =0;
%         s.fractionNoFlanks=0;
% 
%         % determine gabor window size within patch here
%         s.stdsPerPatch=4; %this is an even number that is very reasonable fill of square--has been hardcoded until 8/21/07. Before that, it was always 4.
       
        %t=s;
       

          
        %stimSpec
        % either 'dynamic', in which case stimManager/doDynamicPTBFrame(phaseID) is called on every frame (note this requires thinking about how to save history record), or:
%         stimSpec.stimArray   = [];     %must be of same type (logical, uint8, single, or double) as and within range of extremeVals
%         stimSpec.extremeVals = [0 255];     %[dimmestVal brightestVal] values that would appear in stimArray to specify luminance extremes
%         %                           note, the linear position of the stimArray
%         %                           value within the extremeVals is used to
%         %                           determine the corresponding CLUT entry (depends on CLUT length), which
%         %                           specifies the actual pixel value
%         stimSpec.metaPixelSize = 1;  %[height width] in real pixels represented by each stimPixel ([] means scale to full screen)
%         stimSpec.frameTimes  =[frameTimes 0];     %list of integers > 0 for each page in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               stimArray, indicating number of frames to hold each page
%         %                            last entry can be 0 to hold it, otherwise the
%         %                            stim loops **PMM What about toggling?
%         stimSpec.frameSounds  =[];    %list of sound names to play during each frame (this is in addition to fixed sounds, such as those caused by licks/pokes)
% 
%         t.stimSpec=stimSpec;
        
        size(fields(t))

        t = class(t,'ifFeatureGoRightWithTwoFlankTrialManager',trialManager());
        %ToDo: t = class(t,'ifFeatureGoRightWithTwoFlankTrialManager',nAFC(super.xxx,super.xxx));
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'ifFeatureGoRightWithTwoFlankTrialManager'))
            t = varargin{1};
        else
            error('Input argument is not a ifFeatureGoRightWithTwoFlankTrialManager object')
        end
    case 2
        if isa(varargin{1}, 'struct')
            parameterStructure = varargin{1};
        else
            error('expecting first argument to be a parameterStructure that will be checked after blessing')
        end
    
        if isa(varargin{2}, 'struct')
            super = varargin{2};
        else
            error('expecting second argument to be a structure that will be passed to the appropriate super class')
        end

        %ToDo: reflect new trialManager super class which probably owns old nAFC terms
       
        t = errorCheck(ifFeatureGoRightWithTwoFlankTrialManager,parameterStructure);  
        
        rm=parameterStructure.rm;
        parameterStructure = rmfield(parameterStructure, 'rm')
        switch rm.type
            case 'rewardNcorrectInARow'
                reinforcementMgr=rewardNcorrectInARow(rm.rewardNthCorrect, rm.msPenalty,rm.fractionOpenTimeSoundIsOn,rm.fractionPenaltySoundIsOn, rm.scalar);
            otherwise
                error ('Not an allowed reinforment manager type')
        end



        parameterStructure
        default=ifFeatureGoRightWithTwoFlankTrialManager;

        paramField=fields(parameterStructure);
        paramField{end+1}='trialManager' %add in the super class field which does not exist yet for the parameters
        defaultField=fields(default)

        hasAllFieldsInThatOrder(paramField,defaultField);
        
        disp(sprintf('parameterStructure has %d fields and the default constructor has %d fields', size(paramField,1), size(defaultField,1)))

        t = class(parameterStructure,'ifFeatureGoRightWithTwoFlankTrialManager',trialManager(...
        super.msFlushDuration,...
        ...super.rewardSizeULorMS,...
        super.msMinimumPokeDuration,...
        super.msMinimumClearDuration,...
        super.soundMgr,...
        ...super.msPenalty,...
        ...super.msRewardSoundDuration,...
        reinforcementMgr,...
        super.description));
        
        %%Note: calcStim of this class requires some util functions:
        %     function
        %     out=getFeaturePatchStim(patchX,patchY,type,variableParams,staticParams,extraParams)
        % As well as some inflate functions...maybe they should all be
        % methods...PMM

    otherwise
        error('Wrong number of input arguments')
end


%t = errorCheck(t);  %maybe get rid of this
% t=setSuper(t,?);
%t=setSuper(t,t.trialManager(?  %what's this?

t=getCalibrationSettings(t,'uncalibrated');
t = setCalibrationModeOn(t, 0);
%t=inflate(t); % Note: The LUT's and the cache will now appear in the trialmanager...
disp(sprintf('linearizing monitor in range from %s to %s', num2str(t.rangeOfMonitorLinearized(1)), num2str(t.rangeOfMonitorLinearized(2))))
tm=fillLUT(t,t.typeOfLUT,t.rangeOfMonitorLinearized,0);

disp(sprintf('sucessfully created: %s', class(tm)))

