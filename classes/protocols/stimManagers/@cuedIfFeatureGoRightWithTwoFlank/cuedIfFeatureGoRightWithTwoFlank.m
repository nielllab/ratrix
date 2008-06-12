function s=cuedIfFeatureGoRightWithTwoFlank(varargin)
% ||cuedIfFeatureGoRightWithTwoFlank||  class constructor.
%derived from ifFeatureGoRightWithTwoFlank which was derived from cuedGoToFeatureWithTwoFlank
%s = cuedIfFeatureGoRightWithTwoFlank([pixPerCycs],[goRightOrientations],[goLeftOrientations],[flankerOrientations],topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,[goRightContrast],[goLeftContrast],[flankerContrast],[distractorContrast],mean,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 
%s = cuedIfFeatureGoRightWithTwoFlank([32],[pi/6],[pi/6],[0],0,1,[1],[1],[0.2],[0.2],0.5,0,10,0.5,0,1/16,3,int8(8),int8(0),0.001,0.5,1,'useThisMonitorsUncorrectedGamma',[0 1],600,800,0,0.5)

%s = cuedIfFeatureGoRightWithTwoFlank([32],[pi/6],[-pi/6],[pi/6, -pi/6],0,1,[1],[1],[0.5],[0.5],0.5,0,10,0.5,0,1/16,3,int8(8),int8(0),0.001,0.5,1,'useThisMonitorsUncorrectedGamma',[0 1],1280,1024,0,0.5)
%[stimulus updateSM out scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(s,'nAFC',100,3,[1 1 1],1280,1024,[]); imagesc(out(:,:,2))

% pixPerCycs = 32;
% goRightOrientations = [pi/2]; 
% goLeftOrientations = [pi/2]; 
% flankerOrientations = [0,pi/2]; %choose a random orientation from this list
% %
% topYokedToBottomFlankerOrientation =0;
% topYokedToBottomFlankerContrast =1;
% %    
% goRightContrast = [0.1,0.2,0.3];    %choose a random contrast from this list each trial
% goLeftContrast = [0];
% flankerContrast = [1];
% %    
% mean = 0.5;              %normalized luminance
% cueLum=0;                %luminance of cue sqaure
% cueSize=10;               %roughly in pixel radii 
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
% toggleStim = 1;
% typeOfLUT= 'useThisMonitorsUncorrectedGamma';
% rangeOfMonitorLinearized=[0 1];
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
    
    s.topYokedToBottomFlankerOrientation =1;
    s.topYokedToBottomFlankerContrast =1;
    
    s.goRightContrast = [];
    s.goLeftContrast = [];
    s.flankerContrast = [];
    s.distractorContrast = [];
    
    s.mean = 0;
    s.cueLum=0;
    s.cueSize=1;
    
    s.xPositionPercent = 0;
    s.cuePercentTargetEcc = 0;
    s.stdGaussMask = 0;       
    s.flankerOffset = 0;
   
    s.framesJustCue=int8(0); 
    s.framesStimOn=0; 
    s.thresh = 0;
    s.targetYPosPct = 0; 
    s.toggleStim = 0;
    s.typeOfLUT = [];
    s.rangeOfMonitorLinearized=[];
    
% edf: you must not change definition of object.  these belong on parent, not you.    
    %extra non input values
%    s.maxWidth=1;
%    s.maxHeight=1;
%    s.scaleFactor=0;
%    s.interTrialLuminance=0; 

    s.phase=0;
    s.stdsPerPatch=0;
    
    %could inflatable for faster drawing one day
    s.goRightStim =[];
    s.goLeftStim =[];
    s.flankerStim =[];
    
    s.LUT=[];
    
    
%     s.goRightStim =zeros(2,2,1);
%     s.goLeftStim = zeros(2,2,1);
%     s.flankerStim =zeros(2,2,1);
       
    s = class(s,'cuedIfFeatureGoRightWithTwoFlank',stimManager());   
    
case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'cuedGoToFeatureWithTwoFlank'))
        s = varargin{1}; 
    else
        error('Input argument is not a goToFeatureWithTwoFlank object')
    end
case 28
% create object using specified values    
    
    if all(varargin{1})>0
        s.pixPerCycs=varargin{1};
    else
        error('pixPerCycs must all be > 0')
    end
    
    if all(isnumeric(varargin{2})) && all(isnumeric(varargin{3}))
        s.goRightOrientations=varargin{2};
        s.goLeftOrientations=varargin{3};
        s.flankerOrientations=varargin{4};
    else
        error('target, distractor and flanker orientations must be numbers')
    end
      
    
    if varargin{5}==1 || varargin{5}==0
        s.topYokedToBottomFlankerOrientation=varargin{5};
    else
        error('topYokedToBottomFlankerOrientation must be 0 or 1')
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
    
     if all(varargin{10} >= 0 & varargin{10}<=1)
        s.distractorContrast=varargin{10};
    else
        error('0 <= all distractorContrast <= 1')
    end

    
    if varargin{11} >= 0 && varargin{11}<=1
        s.mean=varargin{11};
    else
        error('0 <= mean <= 1')
    end
    
    if varargin{12} >= 0 && varargin{12}<=1
        s.cueLum=varargin{12};
    else
        error('0 <= cueLum <= 1')
    end
    
    if varargin{13} >= 0 && varargin{13}<=10
        s.cueSize=varargin{13};
    else
        error('0 <= cueSize <= 10')
    end
    
    if varargin{14} >= 0 && varargin{14}<=1
        s.xPositionPercent=varargin{14};
    else
        error('0 <= xPositionPercent <= 1')
    end
    
    if varargin{15} >= 0 && varargin{15}<=1
        s.cuePercentTargetEcc=varargin{15};
    else
        error('0 <= cuePercentTargetEcc <= 1')
    end
    
    if varargin{16} >= 0 
        s.stdGaussMask=varargin{16};
    else
        error('0 <= stdGaussMask')
    end
    
    if varargin{17} >= 0 
        s.flankerOffset=varargin{17}; % also check to see if on screen... need stim.screenHeight
    else
        error('0 <= flankerOffset < something with a center that fits on the screen')  
    end
    
    if varargin{18} >= 0 && isinteger(varargin{18})
        s.framesJustCue=varargin{18};
    else
        error('0 <= framesJustCue; must be an integer')
    end
    
    if varargin{19} >= 0 && isinteger(varargin{19})
        s.framesStimOn=varargin{19};
    else
        error('0 <= framesStimOn; must be an integer')
    end
    

    if varargin{20} >= 0
        s.thresh=varargin{20};
    else
        error('thresh must be >= 0')
    end
    
    if isnumeric(varargin{21}) && varargin{21} >= 0 && varargin{21}<=1
        s.targetYPosPct=varargin{21};
    else
        error('yPositionPercent must be numeric')
    end
    
    if isnumeric(varargin{22})
        s.toggleStim=varargin{22};
    else
        error('toggleStim must be logical')
    end
    
    if strcmp(varargin{23},'linearizedDefault') || strcmp(varargin{23},'useThisMonitorsUncorrectedGamma') || strcmp(varargin{23},'mostRecentLinearized')
        s.typeOfLUT=varargin{23};
    else
        error('typeOfLUT must be linearizedDefault, useThisMonitorsUncorrectedGamma, or mostRecentLinearized')
    end
    
    if 0<=varargin{24}& varargin{24}<=1 & size(varargin{24},1)==1 & size(varargin{24},2)==2
        s.rangeOfMonitorLinearized=varargin{24};
    else
        error('rangeOfMonitorLinearized must be greater than or =0 and less than or =1')
    end
 
    
    s.phase=0; %no longer randomized;   would need movie for that (hieght x width x orientations x phase)
    maxHeight=varargin{26};

    %determine gabor window size within patch here
    s.stdsPerPatch=4; %this is an even number that is very reasonable fill of square
    
    %start deflated
    s.goRightStim=[];
    s.goLeftStim=[];
    s.flankerStim=[];
   
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
    

    s = class(s,'cuedIfFeatureGoRightWithTwoFlank',stimManager(varargin{25},varargin{26},varargin{27},varargin{28})); 
    
    s=inflate(s);
    s=deflate(s);
    s=inflate(s);
    disp(sprintf('linearizing monitor in range from %s to %s', num2str(s.rangeOfMonitorLinearized(1)), num2str(s.rangeOfMonitorLinearized(2))))
    s=fillLUT(s,s.typeOfLUT,s.rangeOfMonitorLinearized,0); 
    
    
otherwise
    error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);




class(s)

