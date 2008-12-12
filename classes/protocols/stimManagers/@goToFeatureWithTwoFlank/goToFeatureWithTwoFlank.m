function s=goToFeatureWithTwoFlank(varargin)
% ||CuedGoToFeatureWithTwoFlank||  class constructor.
% s = cuedGoToFeatureWithTwoFlank([pixPerCycs],[targetOrientations],[distractorOrientations],[flankerOrientations],leftYokedToRightFlankerOrientation,leftYokedToRightTargetContrast,[targetContrast],[distractorContrast],[flankerContrast],mean,cueLum,cueSize,eccentricity,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 
% s = cuedGoToFeatureWithTwoFlank([32],[0],[0,90],[0,90],1,1,[1],[1],[0],0.5,0,1,0,0,50,3,8,0,0.001,0.5,200,200,0,0.5)
% 
% pixPerCycs = 16;
% targetOrientations = [0,pi/2]; 
% distractorOrientations = [0,pi/2]; 
% flankerOrientations = [0,pi/2]; %choose a random contrast from this list
% %
% leftYokedToRightFlankerOrientation =1;
% leftYokedToRightTargetContrast =1;
% %    
% targetContrast = [1];    %choose a random contrast from this list each trial
% distractorContrast = [1];
% flankerContrast = [0];
% %    
% mean = 0.5;              %normalized luminance
% cueLum=0;                %luminance of cue sqaure
% cueSize=1;               %roughly in pixel radii 
% %    
% eccentricity = 0.5;       %target position from center in percent ScreenWidth 
% cuePercentTargetEcc=0.6; %fraction of distance from center to target
% stdGaussMask = 0.2;      %in diag vals
% flankerOffset = 0.7;     %distance in stdGaussMask
% %       
% framesJustCue=30; 
% framesStimOn=0;          %if 0, then leave stim on
% thresh = 0.001;
% yPositionPercent = 0.5; 
%
% orientations in radians , these a distributions of possible orientations
% mean, cueLum, cueSize, contrast, yPositionPercent, eccentricity normalized (0 <= value <= 1)
% stdGaussMask in pixels  -- the only size specified in pixels
% stdGaussMask is the std dev of the enveloping gaussian, in normalized units of the diagonal of the stim region
% thresh is in normalized luminance units, the value below which the stim should not appear

switch nargin
case 0 
% if no input arguments, create a default object

    s.pixPerCycs = [];
    s.targetOrientations = [];   
    s.distractorOrientations = [];
    s.flankerOrientations = [];
    
    s.leftYokedToRightFlankerOrientation =1;
    s.leftYokedToRightTargetContrast =1;
    
    s.targetContrast = [];
    s.distractorContrast = [];
    s.flankerContrast = [];
    
    s.mean = 0;
    s.cueLum=0;
    s.cueSize=1;
    
    s.eccentricity = 0;
    s.cuePercentTargetEcc = 0;
    s.stdGaussMask = 0;       
    s.flankerOffset = 0;
   
    s.framesJustCue=8; 
    s.framesStimOn=0; 
    s.thresh = 0;
    s.targetYPosPct = 0; 
 
% edf: you must not change definition of object.  these belong on parent, not you.    
    %extra non input values
%    s.maxWidth=1;
%    s.maxHeight=1;
%    s.scaleFactor=0;
%    s.interTrialLuminance=0; 

    s.phase=0;
    
    %could inflatable  for faster drawing one day
    s.targetStim =[];
    s.distractorStim =[];
    s.flankerStim =[];
    
%     s.targetStim =zeros(2,2,1);
%     s.distractorStim = zeros(2,2,1);
%     s.flankerStim =zeros(2,2,1);
       
    s = class(s,'goToFeatureWithTwoFlank',stimManager());   
    
case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'cuedGoToFeatureWithTwoFlank'))
        s = varargin{1}; 
    else
        error('Input argument is not a goToFeatureWithTwoFlank object')
    end
case 24
% create object using specified values    
    
    if all(varargin{1})>0
        s.pixPerCycs=varargin{1};
    else
        error('pixPerCycs must all be > 0')
    end
    
    if all(isnumeric(varargin{2})) && all(isnumeric(varargin{3}))
        s.targetOrientations=varargin{2};
        s.distractorOrientations=varargin{3};
        s.flankerOrientations=varargin{4};
    else
        error('target, distractor and flanker orientations must be numbers')
    end
      
    
    if varargin{5}==1 || varargin{5}==0
        s.leftYokedToRightFlankerOrientation=varargin{5};
    else
        error('leftYokedToRightFlankerOrientation must be 0 or 1')
    end
    
    if varargin{6}==1 || varargin{6}==0
        s.leftYokedToRightTargetContrast=varargin{6};
    else
        error('leftYokedToRightTargetContrast must be 0 or 1')
    end  
        
    if all(varargin{7} >= 0 & varargin{7}<=1)
        s.targetContrast=varargin{7};
    else
        error('0 <= all targetContrasts <= 1')
    end
    
    if all(varargin{8} >= 0 & varargin{8}<=1)
        s.distractorContrast=varargin{8};
    else
        error('0 <= all distractorContrast <= 1')
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
    
    if varargin{11} >= 0 && varargin{11}<=1
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
        s.eccentricity=varargin{13};
    else
        error('0 <= eccentricity <= 1')
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
    
    if varargin{17} >= 0 && isinteger(varargin{17})
        s.framesJustCue=varargin{17};
    else
        error('0 <= framesJustCue; must be an integer')
    end
    
    if varargin{18} >= 0 && isinteger(varargin{17})
        s.framesStimOn=varargin{18};
    else
        error('0 <= framesStimOn; must be an integer')
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
    
    s.phase=0; %no longer randomized;   would need movie for that (hieght x width x orientations x phase)
    maxHeight=varargin{22};
    patchX=ceil(maxHeight*s.stdGaussMask);  %stdGaussMask control patch size which control the radius due to wierd geometric sixing in gabors
    patchY=patchX;
    
    %PRECACHE PATCHES
    s.targetStim =zeros(patchX,patchY,length(s.targetOrientations));
    for i=1:length(s.targetOrientations)
            %params= radius   pix/cyc  phase    orientation              contrast   thresh    xPosPct yPosPct
            params = [5  s.pixPerCycs  s.phase  s.targetOrientations(i)     1       s.thresh  1/2     1/2   ];
            %params =[5  pixPerCycs  phase  targetOrientations(i)  targetContrast(i)  thresh  1/2     1/2   ]
            %patch=computeGabors(params,'square',mean,patchX,patchY);
            s.targetStim(:,:,i)=computeGabors(params,'square',s.mean,patchX,patchY);
    end
            
    s.distractorStim =zeros(patchX,patchY,length(s.distractorOrientations));
    for i=1:length(s.distractorOrientations)
            params = [5  s.pixPerCycs  s.phase  s.distractorOrientations(i)  1      s.thresh  1/2     1/2   ];
            s.distractorStim(:,:,i)=computeGabors(params,'square',s.mean,patchX,patchY);
    end
    
    s.flankerStim =zeros(patchX,patchY,length(s.flankerOrientations));
    for i=1:length(s.flankerOrientations)
            params = [5  s.pixPerCycs  s.phase  s.flankerOrientations(i)     1      s.thresh  1/2     1/2   ];
            s.flankerStim(:,:,i)=computeGabors(params,'square',s.mean,patchX,patchY);
    end

    s = class(s,'goToFeatureWithTwoFlank',stimManager(varargin{21},varargin{22},varargin{23},varargin{24}));   
    
    %**set super inflatable class?  just use structable with inflate method?
otherwise
    error('Wrong number of input arguments')
end