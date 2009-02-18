function t=trialManager(varargin)
% TRIALMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% t=trialManager(soundManager,reinforcementManager,eyeTracker,eyeController,customDescription,datanet,
%   frameDropCorner, dropFrames, displayMethod, requestPorts)
%
% 10/8/08 - this is the new integrated trialManager that handles all stims in a phased way - uses phased doTrial and stimOGL
%
% soundMgr - the soundManager object
% reinforcementManager - the reinforcementManager object
% description - a string description of this trialManager
% eyeTracker - the eyeTracker object
% eyeController - the eyeController object
% datanet - the datanet object
% frameDropCorner - a struct containing frameDropCorner params
% dropFrames - whether or not to skip dropped frames
% displayMethod - 'LED' or 'ptb'
% requestPorts - one of the strings {'none', 'center', 'all'}; defines which ports should be returned as requestPorts
%       by the stimManager's calcStim; the default for nAFC is 'center' and the default for freeDrinks is 'none'
requiredSoundNames = {'correctSound','keepGoingSound','trySomethingElseSound','wrongSound'};

t.soundMgr=soundManager();
t.reinforcementManager=reinforcementManager();
t.description='';
t.eyeTracker=[];
t.eyeController=[];
t.datanet=[];
t.frameDropCorner={};
t.dropFrames=false;
t.displayMethod='';
t.requestPorts='none'; % either 'none','center',or 'all'

switch nargin
    case 0
        % if no input arguments, create a default object
        
        t = class(t,'trialManager');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'trialManager'))
            t = varargin{1};
        else
            error('Input argument is not a trialManager object')
        end
    case 10
        
        % soundManager
        if isa(varargin{1},'soundManager') && all(ismember(requiredSoundNames, getSoundNames(varargin{1})))
            t.soundMgr=varargin{1};
        else
            error(['not a soundManager object, or doesn''t contain required sounds ' printAsList(requiredSoundNames)])
        end
        
        % reinforcementManager
        if isa(varargin{2},'reinforcementManager')
            t.reinforcementManager=varargin{2};
        else
            error('must be a reinforcementManager')
        end
        
        % eyeTracker
        t.eyeTracker=varargin{3};
        
        % eyeController
        t.eyeController=varargin{4};
        
        % customDescription
        customDescription=varargin{5};
        
        % datanet
        t.datanet=varargin{6};
        
        
        if isa(t.eyeTracker,'eyeTracker') || isempty(t.eyeTracker)
            %pass
        else
            error('must be an eyeTracker or empty')
        end
        
        if isempty(t.eyeController)
            %pass
        else
            ec=t.eyeController
            error('must be a empty -- until we actually have controllers...then maybe its an controller object or a parameter pair list;  example:  {''driftCorrect'',{param1, param2}}')
        end
        
        if ischar(customDescription)
            % do nothing
        else
            error('not a string')
        end
        
        % frameDropCOrner
        t.frameDropCorner=varargin{7};
        
        % dropFrames
        t.dropFrames=varargin{8};
        
        % displayMethod
        t.displayMethod=varargin{9};
        
        if isempty(t.dropFrames)
            t.dropFrames=false;
        elseif islogical(t.dropFrames) && isscalar(t.dropFrames)
            %pass
        else
            error('dropFrames must be scalar logical')
        end
        
        if isempty(t.displayMethod)
            t.displayMethod='ptb';
        elseif ismember(t.displayMethod,{'LED','ptb'})
            %pass
        else
            error('displayMethod must be one of {''LED'',''ptb''}')
        end
        
        if isempty(t.frameDropCorner)
            t.frameDropCorner={'off'};
        elseif iscell(t.frameDropCorner) && (strcmp(t.frameDropCorner{1},'off') || ...
                (isvector(t.frameDropCorner{2}) && all(t.frameDropCorner{2}>=0) && all(t.frameDropCorner{2}<=1) && ...
                (strcmp(t.frameDropCorner{1},'sequence') || (strcmp(t.frameDropCorner{1},'flickerRamp') && all(size(t.frameDropCorner{2})==[1 2])))))
            %pass
        else
            error('frameDropCorner must be {''off''}, {''sequence'',[vector of normalized luminance values]}, or {''flickerRamp'',[rampBottomNormalizedLuminanceValue flickerNormalizedLuminanceValue]}')
        end
        
        if strcmp(t.displayMethod,'LED')
            if strcmp(t.frameDropCorner{1},'off') && ~t.dropFrames
                %pass
            else
                error('must have dropFrames=false and frameDropCorner={''off''} for LED')
            end
        end
        
        % requestPorts
        t.requestPorts=varargin{10};
        if ischar(t.requestPorts) && (strcmp(t.requestPorts,'none') || strcmp(t.requestPorts,'all') || strcmp(t.requestPorts,'center'))
            %pass
        else
            error('requestPorts must be ''none'', ''all'', or ''center''');
        end
        
        t = class(t,'trialManager');
        
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end