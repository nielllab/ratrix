function s=crossModal(varargin)
% Cross Modal class constructor.
% s =
% crossModal(switchType,switchParameter,switchMethod,blockingLength,currentModality,[pixPerCycs],[targetContrasts],[distractorContrasts],fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPositionPercent,soundFreq,[soundChannelAmplitudes],maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% hemifieldFlicker([pixPerCycs],[targetContrasts],[distractorContrasts],fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 
% mean, contrasts, yPositionPercent normalized (0 <= value <= 1)
% stereoDiscrim(mean,freq,[amplitudes],maxWidth,maxHeight,scaleFactor,interTrialLuminance)
%
% E.G. 
%
% switchType              = 'ByNumberOfTrials';
% switchParameter         = 220;
% switchMethod            = 'Random';
% blockingLength          = 20;
% currentModality         = []; % Default
% pixPerCycs              =[20];
% targetContrasts         =[0.8];
% distractorContrasts     =[];
% fieldWidthPct           = 0.2;
% fieldHeightPct          = 0.2;
% mean                    =.5;
% stddev                  =.04; % Only used for Gaussian Flicker
% thresh                  =.00005;
% flickerType             =0; % 0 - Binary Flicker; 1 - Gaussian Flicker
% yPosPct                 =.65;
% maxWidth                =800;
% maxHeight               =600;
% scaleFactor             =[1 1];
% interTrialLuminance     =.5;
% soundFreq               = 200;
% soundAmp                = [0 0.5];
% s=crossModal(switchType,switchParameter,switchMethod,blockingLength,currentModality,pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,soundFreq,soundAmp,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%

% Determine how to switch between sets (~200? or per day?) of trials
% Whether we are currently in the initially blocked trials
s.isBlocking = false;
% trialNum - What trial number we are currently on for the current modality
s.trialNum = [];
% currentModality - Which modality is currently active [ 0 - hemifield; 1 - stereoDiscrim ]
s.currentModality = [];
% blockingLength - How long blocking is done for
s.blockingLength = [];
% Determine how often the modality should switch
s.modalitySwitchType = []; % 'Never' 'ByNumberOfTrials' 'ByNumberOfHoursRun' 'ByNumberOfDaysWorked'
s.modalitySwitchParameter = []; %  []      200                2                    1
s.modalitySwitchMethod = []; % 'Alternating' 'Random'
s.modalityTimeStarted = [];
s.trialNum = [];
s.audioStimulus = []; % Where to store the calculated audioStimulus
% Hold the underlying component stim managers
s.hemifieldFlicker = [];
s.stereoDiscrim = [];

switch nargin
case 0 
% if no input arguments, create a default object
    s.hemifieldFlicker = hemifieldFlicker();
    s.stereoDiscrim = stereoDiscrim();
    s = class(s,'crossModal',stimManager());    
case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'crossModal'))
        s = varargin{1}; 
    else
        error('Input argument is not a crossModal object')
    end
case 21
    % number of blocking trials initially .... might be stochastic?
    % 
    % create object using specified values
    s.modalitySwitchType = varargin{1}; % How often the modality switches
    s.modalitySwitchParameter = varargin{2}; % Parameter for the Switch Type
    s.modalitySwitchMethod = varargin{3}; % Whether the switch should be random, or if it should alternate
    s.blockingLength = varargin{4}; % How many trials to block initially
    s.currentModality = varargin{5}; % What modality should be relevant when initialized (empty if randomly assigned)

    i = 6; % Index where arguments for the component stim managers start
    s.hemifieldFlicker = hemifieldFlicker(varargin{i},varargin{i+1},varargin{i+2},varargin{i+3},varargin{i+4},varargin{i+5},varargin{i+6},...
        varargin{i+7},varargin{i+8},varargin{i+9},varargin{i+12},varargin{i+13},varargin{i+14},varargin{i+15});
    s.stereoDiscrim = stereoDiscrim(varargin{i+5},varargin{i+10},varargin{i+11},varargin{i+12},varargin{i+13},varargin{i+14},varargin{i+15});
    s = class(s,'crossModal',stimManager(varargin{i+12},varargin{i+13},varargin{i+14},varargin{i+15}));   
    
otherwise
    error('Wrong number of input arguments')
end