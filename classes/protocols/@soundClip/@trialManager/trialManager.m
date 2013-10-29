function t=trialManager(varargin)
% TRIALMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% t=trialManager(soundManager,reinforcementManager,eyeController,customDescription,
%   frameDropCorner, dropFrames, displayMethod, requestPorts,saveDetailedFramedrops,delayManager,responseWindowMs[,showText])
%
% 10/8/08 - this is the new integrated trialManager that handles all stims in a phased way - uses phased doTrial and stimOGL
%
% soundMgr - the soundManager object
% reinforcementManager - the reinforcementManager object
% description - a string description of this trialManager
% eyeController - the eyeController object
% frameDropCorner - a struct containing frameDropCorner params
% dropFrames - whether or not to skip dropped frames
% displayMethod - 'LED' or 'ptb'
% requestPorts - one of the strings {'none', 'center', 'all'}; defines which ports should be returned as requestPorts
%       by the stimManager's calcStim; the default for nAFC is 'center' and the default for freeDrinks is 'none'
% saveDetailedFrameDrops - a flag indicating whether or not to save detailed timestamp information for each dropped frame (causes large trialRecord files!)
% delayManager - an object that determines how to stimulus onset works (could be immediate upon request, or some delay)
% responseWindowMs - the timeout length of the 'discrim' phase in milliseconds (should be used by phaseify)
requiredSoundNames = {'correctSound','keepGoingSound','trySomethingElseSound','wrongSound','trialStartSound'};

t.soundMgr=soundManager();
t.reinforcementManager=reinforcementManager();
t.description='';
t.eyeController=[];
t.frameDropCorner={};
t.dropFrames=false;
t.saveDetailedFramedrops=false;
t.displayMethod='';
t.requestPorts='center'; % either 'none','center',or 'all'
t.showText='full'; %off, light, or full
t.delayManager=[];
t.responseWindowMs=[0 Inf];

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
    case {11 12}
        
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
        
        % eyeController
        t.eyeController=varargin{3};
        
        % customDescription
        customDescription=varargin{4};
        
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
        t.frameDropCorner=varargin{5};
        
        % dropFrames
        t.dropFrames=varargin{6};
        
        % displayMethod
        t.displayMethod=varargin{7};
        
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
            if strcmp(t.displayMethod,'LED')
                
                [a b]=getMACaddress;
                x=daqhwinfo('nidaq');
                
                
                if a && ismember(b,{'0014225E4685','0018F35DF141'}) && length(x.InstalledBoardIds)>0
                    %pass
                else
                    b
                    length(x.InstalledBoardIds)>0
                    error('can''t make an LED trialManager cuz this machine doesn''t have a nidaq -- currently only known nidaq is in left rig machine')
                end
            end
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
        t.requestPorts=varargin{8};
        if ischar(t.requestPorts) && (strcmp(t.requestPorts,'none') || strcmp(t.requestPorts,'all') || strcmp(t.requestPorts,'center'))
            %pass
        else
            t.requestPorts
            error('requestPorts must be ''none'', ''all'', or ''center''');
        end
        
        % saveDetailedFramedrops
        if islogical(varargin{9})
            t.saveDetailedFramedrops=varargin{9};
        elseif isempty(varargin{9})
            % pass - ignore empty args
        else
            error('saveDetailedFramedrops must be a logical');
        end
        
		% delayManager
		if ~isempty(varargin{10}) && isa(varargin{10},'delayManager')
            t.delayManager=varargin{10};
        elseif isempty(varargin{10})
			t.delayManager=[];
        else
            error('delayManager must be empty or a valid delayManager object');
		end
		
		% responseWindowMs
		if ~isempty(varargin{11})
			if isvector(varargin{11}) && isnumeric(varargin{11}) && length(varargin{11})==2
				if varargin{11}(1)>varargin{11}(2) || varargin{11}(1)<0 || isinf(varargin{11}(1))
					error('responseWindowMs must be [min max] within the range [0 Inf] where min cannot be infinite');
				else
					t.responseWindowMs=varargin{11};
				end
			else
				error('responseWindowMs must be a 2-element array');
			end
		else
			t.responseWindowMs=[0 Inf];
		end
		
        % showText
        if nargin==12
            if islogical(varargin{12})
                if varargin{12}
                    t.showText='full';  % good for development, may cause frame drops if eye tracker and other things are on
                else
                    t.showText='off';
                end
            elseif isempty(varargin{12})
                %pass - ignore empty args
            elseif ismember(varargin{12},{'full','light','off'})  % list of acceptable modes.  "light" is faster and drops fewer frames
                 t.showText=varargin{12};
            else
                error('showText must be logical or aproved string, or empty');
            end
        end
        
        t = class(t,'trialManager');
        
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end