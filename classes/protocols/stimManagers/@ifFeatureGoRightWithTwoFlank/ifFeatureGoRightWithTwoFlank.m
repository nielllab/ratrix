function s=ifFeatureGoRightWithTwoFlank(varargin)
% ||ifFeatureGoRightWithTwoFlank||  class constructor.
%derived from cuedGoToFeatureWithTwoFlank
%function calls below are out of date; use getDefaultParameters; see setFlankerStimRewardAndTrialManager for signature
% s = ifFeatureGoRightWithTwoFlank([pixPerCycs],[goRightOrientations],[goLeftOrientations],[flankerOrientations],topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,[goRightContrast],[goLeftContrast],[flankerContrast],mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxCorrectOnSameSide,positionalHint,xPosNoise,yPosNoise,displayTargetAndDistractor,phase,persistFlankersDuringToggle,maxWidth,maxHeight,scaleFactor,interTrialLuminance,percentCorrectionTrials)
% s = ifFeatureGoRightWithTwoFlank([32],[pi/2],[pi/2],[0],1,1,[0.5],[0.5],[0.5],0.5,0,1,0.5,0,1/16,3,int8(8),int8(0),0.001,0.5,1,'useThisMonitorsUncorrectedGamma',[0 1],int8(-1),0,0,0,600,800,0,0.5)
% s = ifFeatureGoRightWithTwoFlank([32],[0],[pi/2],[0],1,1,[0.5],[0.5],[0.5],0.5,0,1,0.5,0,1/16,3,int8(8),int8(0),0.001,0.5,1,4,1280,1024,0,0.5)
%
% p=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToRightDetection', '1_9','Oct.09,2007');
% sm=getStimManager(setFlankerStimRewardAndTrialManager(p, 'test'));
% [sm updateSM out scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(sm,'nAFC',100,3,[1 1 1],1280,1024,[]);
% imagesc(out(:,:,1)); colormap(gray)



% pixPerCycs = 32;
% goRightOrientations = [pi/2];
% goLeftOrientations = [pi/2];
% flankerOrientations = [0,pi/2]; %choose a random orientation from this list
% %
% topYokedToBottomFlankerOrientation =1;
% topYokedToBottomFlankerContrast =1;
% %
% goRightContrast = [0.1,0.2,0.3];    %choose a random contrast from this list each trial
% goLeftContrast = [0];
% flankerContrast = [1];
% %
% mean = 0.5;              %normalized luminance
% cueLum=0;                %luminance of cue sqaure
% cueSize=1;               %roughly in pixel radii
% %
% xPositionPercent = 0.5;  %target position in percent ScreenWidth
% cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank
% stdGaussMask =  3;       %in fraction of vertical height
% flankerOffset = 4;       %distance in stdGaussMask (3.5 just touches edge)
% %
% framesJustCue=int8(30);
% framesStimOn=int8(0);      %if 0, then leave stim on, which is a blank
% thresh = 0.001;
% yPositionPercent = 0.5;
%
%Might be missing some arguments
%here:toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxCorrectOnSameSide,
%and more, see getDefaultParams, or setFlankerStimRewardAndTrialManager
% toggleStim = 1;
% typeOfLUT= 'useThisMonitorsUncorrectedGamma';
% rangeOfMonitorLinearized=[0 1];
% s.maxCorrectOnSameSide=-1;
%
% positionalHint=0.2;
% xPosNoise=0.1;%standard deviation of noise in fractional screen width
% yPosNoise=0;%standard deviation of noise in fractional screen height
% displayTargetAndDistractor = 0;
%
% orientations in radians , these a distributions of possible orientations
% mean, cueLum, cueSize, contrast, yPositionPercent, xPositionPercent normalized (0 <= value <= 1)
% stdGaussMask is the std dev of the enveloping gaussian, in normalized  units of the vertical height of the stimulus image
% thresh is in normalized luminance units, the value below which the stim should not appear
% cuePercentTargetEcc is an vestigal variable not used

switch nargin
    case 0
        % if no input arguments, create a default object

        s.pixPerCycs = [];
        s.goRightOrientations = [];
        s.goLeftOrientations = [];
        s.flankerOrientations = [];
        s.distractorOrientations = [];
        s.distractorFlankerOrientations = [];

        s.topYokedToBottomFlankerOrientation =1;
        s.topYokedToBottomFlankerContrast =1;

        s.goRightContrast = [];
        s.goLeftContrast = [];
        s.flankerContrast = [];

        s.mean = 0;
        s.cueLum=0;
        s.cueSize=1;

        s.xPositionPercent = 0;
        s.cuePercentTargetEcc = 0;
        s.stdGaussMask = 0;
        s.flankerOffset = 0;

        s.framesJustCue=8;
        s.framesStimOn=0;
        s.thresh = 0;
        s.targetYPosPct = 0;
        s.toggleStim = 0;
        s.typeOfLUT = [];
        s.rangeOfMonitorLinearized=[];
        s.maxCorrectOnSameSide=-1;

        %ADD THESE!
        s.positionalHint=0; %fraction of screen hinted.
        s.xPosNoise=0; %
        s.yPosNoise=0; %

        %%%%%%%%%%%%% NEW VARIABLES CREATED TO SET DISTRACTORS MIRRORED FROM
        %%%%%%%%%%%%% TARGET AND FLANKERS %%%%%%%%%%%%%%%%%%%%% Y.Z
        s.displayTargetAndDistractor=0;
        s.phase=0;
        s.persistFlankersDuringToggle=[];

        s.distractorFlankerYokedToTargetFlanker = 1;
        s.distractorContrast = 0;
        s.distractorFlankerContrast = 0;
        s.distractorYokedToTarget=1;

        s.flankerYokedToTargetPhase =0;
        s.fractionNoFlanks=[];
        %%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%%


        s.shapedParameter=[];
        s.shapingMethod=[];
        s.shapingValues=[];

        s.gratingType='square';

        
        s.framesMotionDelay = [];
        s.numMotionStimFrames = [];
        s.framesPerMotionStim = [];

        s.protocolType=[];
        s.protocolVersion=[];
        s.protocolSettings = [];

        s.flankerPosAngle = [];
        s.percentCorrectionTrials = [];

        s.fpaRelativeTargetOrientation=[]; 
        s.fpaRelativeFlankerOrientation=[];
        
        % edf: you must not change definition of object.  these belong on parent, not you.
        %extra non input values
        %    s.maxWidth=1;
        %    s.maxHeight=1;
        %    s.scaleFactor=0;
        %    s.interTrialLuminance=0;


        s.stdsPerPatch=0;

        %could inflatable for faster drawing one day
        s.mask =[];
        s.goRightStim =[];
        s.goLeftStim =[];
        s.flankerStim =[];
        s.distractorStim = [];
        s.distractorFlankerStim= [];

        s.LUT=[];


        %     s.goRightStim =zeros(2,2,1);
        %     s.goLeftStim = zeros(2,2,1);
        %     s.flankerStim =zeros(2,2,1);

        s = class(s,'ifFeatureGoRightWithTwoFlank',stimManager());

    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'cuedGoToFeatureWithTwoFlank'))
            s = varargin{1};
        else
            error('Input argument is not a goToFeatureWithTwoFlank object')
        end
    case 56
        % create object using specified values

        if all(varargin{1})>0
            s.pixPerCycs=varargin{1};
        else
            error('pixPerCycs must all be > 0')
        end

        if all(isnumeric(varargin{2})) && all(isnumeric(varargin{3})) && all(isnumeric(varargin{4})) && all(isnumeric(varargin{32})) && all(isnumeric(varargin{33}))
            s.goRightOrientations=varargin{2};
            s.goLeftOrientations=varargin{3};
            s.flankerOrientations=varargin{4};
            s.distractorOrientations=varargin{32};
            s.distractorFlankerOrientations=varargin{33};
        else
            varargin{2}
            varargin{3}
            varargin{4}
            varargin{32}
            varargin{33}
            error('target, distractor and flanker orientations must be numbers')
        end

        if varargin{5}==1 %|| varargin{5}==0
            s.topYokedToBottomFlankerOrientation=varargin{5};
        else
            error('topYokedToBottomFlankerOrientation must be 1')
        end

        if varargin{6}==1 %|| varargin{6}==0
            s.topYokedToBottomFlankerContrast=varargin{6};
        else
            error('topYokedToBottomFlankerContrast must be 1')
        end

        if all(varargin{7} >= 0 & varargin{7}<=1)
            s.goRightContrast=varargin{7};
        else
            error('0 <= all goRightContrasts <= 1')
        end

        if all(varargin{8} >= 0 & varargin{8}<=1)
            s.goLeftContrast=varargin{8};
        else
            error('0 <= all goLeftContrast <= 1')
        end

        if all(varargin{9} >= 0 & varargin{9}<=1)
            s.flankerContrast=varargin{9};
        else
            error('0 <= all flankerContrast <= 1')
        end

        if varargin{10} >= 0 && varargin{10}<=1
            s.mean=varargin{10};
        else
            error('0 <= mean <= 1')
        end

        if (varargin{11} >= 0 & varargin{11}<=1) | isempty(varargin{11})
            s.cueLum=varargin{11};
        else
            error('0 <= cueLum <= 1')
        end

        if varargin{12} >= 0 && varargin{12}<=10
            s.cueSize=varargin{12};
        else
            error('0 <= cueSize <= 10')
        end

        if varargin{13} >= 0 && varargin{13}<=1
            s.xPositionPercent=varargin{13};
        else
            error('0 <= xPositionPercent <= 1')
        end

        if varargin{14} >= 0 && varargin{14}<=1
            s.cuePercentTargetEcc=varargin{14};
        else
            error('0 <= cuePercentTargetEcc <= 1')
        end

        if varargin{15} >= 0
            s.stdGaussMask=varargin{15};
        else
            error('0 <= stdGaussMask')
        end

        if varargin{16} >= 0
            s.flankerOffset=varargin{16}; % also check to see if on screen... need stim.screenHeight
        else
            error('0 <= flankerOffset < something with a center that fits on the screen')
        end

        if all(varargin{17} >= 0) && isinteger(varargin{17}) && size(varargin{17},2)==2 && varargin{17}(1)<varargin{17}(2)
            s.framesJustCue=varargin{17};
        else
            error('0 <= framesJustCue; must be two increasing integers...this will become framesFlankerOnOff')
        end

        if all(varargin{18} >= 0) && isinteger(varargin{18}) && size(varargin{18},2)==2 && varargin{18}(1)<varargin{18}(2)
            s.framesStimOn=varargin{18};
        else
            error('0 <= framesStimOn; must be two increasing integers...this will become framesTargetOnOff')
        end


        if varargin{19} >= 0
            s.thresh=varargin{19};
        else
            error('thresh must be >= 0')
        end

        if isnumeric(varargin{20}) && varargin{20} >= 0 && varargin{20}<=1
            s.targetYPosPct=varargin{20};
        else
            error('yPositionPercent must be numeric')
        end

        if (isnumeric(varargin{21}) && (varargin{21}==1 || varargin{21}==1)) || islogical(varargin{21})
            s.toggleStim=varargin{21};
        else
            error('toggleStim must be logical')
        end

        if strcmp(varargin{22},'linearizedDefault') || strcmp(varargin{22},'useThisMonitorsUncorrectedGamma') || strcmp(varargin{22},'mostRecentLinearized')
            s.typeOfLUT=varargin{22};
        else
            error('typeOfLUT must be linearizedDefault, useThisMonitorsUncorrectedGamma, or mostRecentLinearized')
        end

        if 0<=varargin{23}& varargin{23}<=1 & size(varargin{23},1)==1 & size(varargin{23},2)==2
            s.rangeOfMonitorLinearized=varargin{23};
        else
            error('rangeOfMonitorLinearized must be greater than or =0 and less than or =1')
        end

        if (0<varargin{24}| varargin{24}==-1 )& isinteger(varargin{24})
            s.maxCorrectOnSameSide=varargin{24};
        else
            error('maxCorrectOnSameSide must be an integer greater than 0, or be equal to -1 in order to not limit at all')
        end

        if 0<=varargin{25}& varargin{25}<=1
            s.positionalHint=varargin{25};
        else
            error('positionalHint must be greater than 0, and less than 1')
        end

        if 0<=varargin{26}
            s.xPosNoise=varargin{26};
        else
            error('xPosNoise must be greater than 0')
        end

        if 0<=varargin{27}
            s.yPosNoise=varargin{27};
        else
            error('yPosNoise must be greater than 0')
        end

        if 0==varargin{28}|1==varargin{28};
            s.displayTargetAndDistractor=varargin{28};
        else
            error('displayTargetAndDistractor must be 0 or 1')
        end

        if all(0<=varargin{29}) & all(2*pi>=varargin{29});
            s.phase=varargin{29}; %Phase can now be randomized 07/10/04 pmm
        else
            error('all phases must be >=0 and <=2*pi')
        end

        if (0==varargin{30}) | (1==varargin{30});
            s.persistFlankersDuringToggle=varargin{30};
        else
            error('persistFlankersDuringToggle must be 0 or 1')
        end

        if (0==varargin{31}) | (1==varargin{31});
            s.distractorFlankerYokedToTargetFlanker=varargin{31};
        else
            error('distractorFlankerYokedToTargetFlanker must be 0 or 1')
        end

        %see the other orientations
        %s.distractorOrientations = 0; %32
        %s.distractorFlankerOrientations = 0; %33

        if all(varargin{34} >= 0 & varargin{34}<=1)
            s.distractorContrast=varargin{34};
        else
            error('0 <= all distractorContrast <= 1')
        end

        if all(varargin{35} >= 0 & varargin{35}<=1)
            s.distractorFlankerContrast=varargin{35};
        else
            error('0 <= all distractorFlankerContrast <= 1')
        end

        if (0==varargin{36}) | (1==varargin{36});
            s.distractorYokedToTarget=varargin{36};
        else
            error('distractorYokedToTarget must be 0 or 1')
        end

        if (0==varargin{37}) | (1==varargin{37});
            s.flankerYokedToTargetPhase=varargin{37};
        else
            error('flankerYokedToTargetPhase must be 0 or 1')
        end

        if all(varargin{38} >= 0 & varargin{38}<=1)
            s.fractionNoFlanks=varargin{38};
        else
            error('0 <= all fractionNoFlanks <= 1')
        end

        if (isempty(varargin{39}) | any(strcmp(varargin{39},{'positionalHint', 'stdGaussMask','targetContrast','flankerContrast','xPosNoise'})))
            s.shapedParameter=varargin{39};
        else
            error ('shapedParameter must be positionalHint or stdGaussianMask or targetContrast or flankerContrast or xPosNoise')
        end

        if (isempty(varargin{40}) | any(strcmp(varargin{40},{'exponentialParameterAtConstantPerformance', 'geometricRatioAtCriteria','linearChangeAtCriteria'})))
            s.shapingMethod=varargin{40};
        else
            error ('shapingMethod must be exponentialParameterAtConstantPerformance or geometricRatioAtCriteria or linearChangeAtCriteria')
        end

        if isempty(s.shapingMethod)
            s.shapingValues=[];
        else %only check values if a method is selected
            if (checkShapingValues(ifFeatureGoRightWithTwoFlank(),s.shapingMethod,varargin{41}))
                s.shapingValues=varargin{41};
            else
                error ('wrong fields in shapingValues')
            end
        end

        if  any(strcmp(varargin{42},{'square', 'sine'}))
            s.gratingType=varargin{42};
        else
            error('waveform must be square or sine')
        end

        if  isnumeric(varargin{43}) && length(varargin{43})==1
            s.framesMotionDelay=floor(varargin{43});
        else
            error('framesMotionDelay must be a single number')
        end

        if  isnumeric(varargin{44}) && length(varargin{44})==1
            s.numMotionStimFrames=floor(varargin{44});
        else
            error('numMotionStimFrames must be a single number')
        end

        if  isnumeric(varargin{45}) && length(varargin{45})==1
            s.framesPerMotionStim=floor(varargin{45});
        else
            error('framesPerMotionStim must be a single number')
        end
        
        if  any(strcmp(varargin{46},{'goToRightDetection', 'goToLeftDetection','tiltDiscrim','goToSide'}))
            s.protocolType=varargin{46};
        else
            error('protocolType must be goToRightDetection or goToLeftDetection or tiltDiscrim or goToSide')
        end

        if  any(strcmp(varargin{47},{'1_0','1_1','1_2','1_3','1_4','1_5','1_6','1_7','1_8','1_9','2_0','2_1','2_2','2_3','2_4','2_5'}))
            s.protocolVersion=varargin{47};
        else
            error('protocolVersion must be very specific')
        end

        if  any(strcmp(varargin{48},{'Oct.09,2007'}))
            s.protocolSettings=varargin{48};
        else
            error('protocolSettings must be very specific string')
        end

        if  isnumeric(varargin{49}) && all(size(varargin{49},1)==1)
            s.flankerPosAngle=varargin{49};
        else
            error('flankerPosAngle must be a numeric vector, for now size 1, maybe matrix one day')
        end


        if  varargin{50} >= 0 && varargin{50}<=1 && all(size(varargin{50})==1)
            s.percentCorrectionTrials=varargin{50};
        else
            error('percentCorrectionTrials must be a single numer between 0 and 1')
        end

        if  isnan(varargin{51}) | (isnumeric(varargin{51}) && size(varargin{51},1)==1)

            if ~isnan(varargin{51})
                %error check that the right targets are there
                relatives=varargin{51};
                fpas=s.flankerPosAngle;
                required=repmat(relatives,size(fpas,2),1)-repmat(fpas',1,size(relatives,2));
                if all(ismember(required(:),s.goRightOrientations)) && all(ismember(required(:),s.goLeftOrientations));
                    %good
                else
                    unique(required(:))
                    s.goRightOrientations
                    s.goLeftOrientations
                    error('both goLeft and goRight must have target orientations required for this fpaRelativeTargetOrientation' )
                end
            end
            s.fpaRelativeTargetOrientation=varargin{51};
        else
            error('fpaRelativeTargetOrientation must be a vectors of numbers or NaN')
        end

        if  isnan(varargin{52}) | (isnumeric(varargin{52}) && size(varargin{52},1)==1)

            if ~isnan(varargin{52})
                %error check that the right flankers are there
                relatives=varargin{52};
                fpas=s.flankerPosAngle;
                required=repmat(relatives,size(fpas,2),1)-repmat(fpas',1,size(relatives,2));
                if all(ismember(required(:),s.flankerOrientations))
                    %good
                else
                    unique(required(:))
                    s.flankerOrientations
                    error('flankerOrientations must have flanker orientations required for this fpaRelativeFlankerOrientation' )
                end
            end
            s.fpaRelativeFlankerOrientation=varargin{52};

        else
            error('fpaRelativeTargetOrientation must be a vectors of numbers or NaN')
        end
                
        %s.phase=0; %no longer randomized;   would need movie for that (hieght x width x orientations x phase)
        %maxHeight=varargin{22**old val};

        %determine gabor window size within patch here
        s.stdsPerPatch=4; %this is an even number that is very reasonable fill of square

        %start deflated
        s.mask =[];
        s.goRightStim=[];
        s.goLeftStim=[];
        s.flankerStim=[];
        s.distractorStim = [];
        s.distractorFlankerStim= [];

        s.LUT=[];


        %%%moved functions to util****
        %     function out=getFeaturePatchStim(patchX,patchY,type,variableParams,staticParams,extraParams)
        %     switch type
        %         case 'squareGrating-variableOrientation'
        %             featurePatchStim=zeros(patchX,patchY,length(variableParams));
        %             params=staticParams;
        %             %params= radius   pix/cyc  phase orientation ontrast thresh xPosPct yPosPct
        %              for i=1:length(variableParams)
        %                 params(4)=variableParams(i);  %4th parameter is orientation
        %                 featurePatchStim(:,:,i)=computeGabors(params,extraParams.mean,patchX,patchY,'square',extraParams.normalizeMethod,1);
        %             end
        %
        %         otherwise
        %             error(sprintf('%s is not a defined type of feature',type))
        %     end
        %     out=featurePatchStim;

        %%%this now gets called in the inflate
        %     s.goRightStim =zeros(patchX,patchY,length(s.goRightOrientations));
        %     for i=1:length(s.goRightOrientations)
        %             %params= radius   pix/cyc       phase    orientation              contrast   thresh    xPosPct yPosPct
        %             params = [radius  s.pixPerCycs  s.phase  s.goRightOrientations(i)     1       s.thresh  1/2     1/2   ];
        %             %params =[5  pixPerCycs  phase  goRightOrientations(i)  goRightContrast(i)  thresh  1/2     1/2   ]
        %             %patch=computeGabors(params,'square',mean,patchX,patchY);
        %             s.goRightStim(:,:,i)=computeGabors(params,s.mean,patchX,patchY,'square',normalizeMethod,1);
        %     end
        %
        %     s.goLeftStim =zeros(patchX,patchY,length(s.goLeftOrientations));
        %     for i=1:length(s.goLeftOrientations)
        %             params = [radius  s.pixPerCycs  s.phase  s.goLeftOrientations(i)  1      s.thresh  1/2     1/2   ];
        %             s.goLeftStim(:,:,i)=computeGabors(params,s.mean,patchX,patchY,'square',normalizeMethod,1);
        %     end
        %
        %     s.flankerStim =zeros(patchX,patchY,length(s.flankerOrientations));
        %     for i=1:length(s.flankerOrientations)
        %             params = [radius  s.pixPerCycs  s.phase  s.flankerOrientations(i)     1      s.thresh  1/2     1/2   ];
        %             s.flankerStim(:,:,i)=computeGabors(params,s.mean,patchX,patchY,'square',normalizeMethod,1);
        %     end

        firstSuper=nargin-3;
        s = class(s,'ifFeatureGoRightWithTwoFlank',stimManager(varargin{firstSuper},varargin{firstSuper+1},varargin{firstSuper+2},varargin{firstSuper+3}));

        %s=inflate(s);
        %s=deflate(s);
        %s=inflate(s);
        if ~strcmp(s.typeOfLUT, 'useThisMonitorsUncorrectedGamma')        
        disp(sprintf('at start up will be linearizing monitor in range from %s to %s', num2str(s.rangeOfMonitorLinearized(1)), num2str(s.rangeOfMonitorLinearized(2))))
        end
        %s=fillLUT(s,s.typeOfLUT,s.rangeOfMonitorLinearized,0);


    otherwise
        nargin
        size(nargin)
        error('Wrong number of input arguments')
end

% s=setSuper(s,s.stimManager);


