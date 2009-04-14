function spec=stimSpec(varargin)
% stimSpec  class constructor. 
% spec=stimSpec(stimulus,transitions,stimType,startFrame,framesUntilTransition,stochasticDistribution,scaleFactor,isFinalPhase,hz,phaseType,phaseLabel,[isStim],[indexPulses])
%
% INPUTS
% stimulus                  the stimulus frames to show, or expert-mode parameters struct (equivalent to non-phased 'out')
% transitions               a cell array of the format {port1 target1 port2 target2 ...} where triggering port1 will cause a phase transition to 
%                               the phase specified by target1, triggering port2 will cause a phase transition to the phase specified by target2, etc.
%                               the port values are a subset of all ports and the target values are indices into the array of stimSpec objects.
%                               if the port value is empty ([]), then there is no phase transition by port triggering (instead, this is the special 'frame timeout' transition, see below)
%                               this 'frame timeout' transition is also used even if framesUntilTransition is empty, but if the stimType is 'cache'
%                               or 'timedFrames' with a nonzero end, and we finish showing the stimulus for the specified duration.
% stimType                  must be one of the non-phased values for stimManager.calcStim()'s 'type' output, with the same properties 
%                               ('static', {'trigger',toggleStim}, 'cache', 'loop', {'timedFrames', [frameTimes]}, {'indexedFrames', [frameIndices]}, or 'expert') - default is loop
%                               this is effectively a phase-specific type, instead of trial-specific
% startFrame                what frame of the stimulus to start this phase at; if 'loop' mode, automatically start at first frame after looping through once
%                               set to zero to start at the beginning
% framesUntilTransition     length of the frame timeout (if we have shown this phase for framesUntilTransition frames with no transition by port selection,
%                               then advance to the next phase as specified by the criterion automatically)
%                           	if framesUntilTransition is greater than the length of the stimulus and the stimType is 'cache' or
%                               'timedFrames' with nonzero end, then we will throw an error during the validation process.                                  
%                               advances to the special 'frame timeout' phase - see above
%                               if empty, then hold this phase indefinitely until a port transition is triggered 
%                               or we transition due to the strategy of 'cache' or 'timedFrames'.
% stochasticDistribution    a cell array of values {pA, portA, pB, portB,...} where pA specifies the probability of stochastically triggering
%                            	portA, and pB specifies the probability of triggering portB, etc
%                           	this is done for every frame of the stimulus (loop of runRealTimeLoop), and the execution order is whatever comes first
%                               in this cell array (ie pA is tried, then pB, and so forth)
% scaleFactor               the scaleFactor associated with this phase - see stimManager.calcStim()'s scaleFactor output for details
% isFinalPhase              a flag if this is the final phase of the trial (defaults to zero)
% hz                        if trialManager.displayMethod = 'ptb':
%                               value is ignored (the resolution is set by stimManager.calcStim()'s resolutionIndex for the whole trial, it is not phase-specific)
%                               for non-expert phase types, phaseify happens to set this value to stimManager.calcStim()'s requested screen Hz, but it is still ignored
%                           if trialManager.displayMethod = 'LED' 
%                               non-expert phase types:
%                                   stimManager.calcStim() returns a desired Hz for the LED as its resolutionIndex output
%                                   this value is passed to trialManager.runRealTimeLoop() via stimSpec.hz so that the analogoutput can be configured to the desired Hz for each phase
%                               expert phase types:
%                                   set this value to your desired value for each phase (stimManager.calcStim()'s resolutionIndex output is ignored)
%                           even when ignored, value must be scalar >0 (on mac, can be 0, and is ignored because Screen('Resolutions') and Screen('Resolution') return 0hz -- macs do not have the data acquisition toolbox and therefore cannot have trialManager.displayMethod='LED' anyway)
% phaseType                 one of {'reinforced', ''} -- reinforced will ask the reinforcement manager how much water/airpuff to deliver at the beginning of the phase
%                               a reward that extends beyond the end of the phase is cut off.
% phaseLabel                a text label for the given phase to be stored in phaseRecords
% isStim                    a boolean indicating whether to set the station's stim pin high during this phase (usually during discriminanda) [defaults to false]
% indexPulses               a boolean vector same length as stimulus indicating what to output on the station's indexPin during each frame (defaults to all false)

% fields in the stimSpec object
spec.stimulus = zeros(1,1,1);
spec.transitions = {[], 0};
spec.stimType = 'loop';
spec.startFrame = 1;
spec.framesUntilTransition = [];
spec.stochasticDistribution = []; % for now the "distribution" is a unit random criterion between 0 and 1
spec.scaleFactor=0;
spec.isFinalPhase = 0;
spec.hz=0;
spec.phaseType=[];
spec.phaseLabel='';
spec.isStim=false;
spec.indexPulses=[];

switch nargin
    case 0
        % if no input arguments, create a default object
        
        spec = class(spec,'stimSpec');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'stimSpec'))
            spec = varargin{1};
            % if single argument is a stimulus, use blank sounds and
            % rewardDuration
        elseif isa(varargin{1}, 'numeric')
            spec.stimulus = varargin{1};
            spec = class(spec,'stimSpec');
        else
            error('Input argument is not a stimSpec object or cell array of stim frames')
        end
    case {11 12 13}
        % stimulus
        spec.stimulus = varargin{1};
        % transitions
        goodInput = 0;
        if iscell(varargin{2})
            temp = varargin{2}; % this is the cell array that has key value pairs
            for i=1:2:length(varargin{2})-1 % check each transition port set
                if isa(varargin{2}{i}, 'numeric')
                    
                    goodInput=1;
                else
                    error('Invalid port set specified');
                end
            end
            spec.transitions = varargin{2};
        else
            error('Invalid inputs');
        end
        
        % stimType
        if ischar(varargin{3}) && (strcmp(varargin{3}, 'loop') || ...
                strcmp(varargin{3}, 'cache') || strcmp(varargin{3},'expert')) % handle single char arrays
            spec.stimType = varargin{3};
        elseif iscell(varargin{3})
            typeArray = varargin{3};
            if strcmp(typeArray{1}, 'timedFrames') || strcmp(typeArray{1}, 'indexedFrames') || ...
                    strcmp(typeArray{1},'trigger')
                % error-check that if we want trigger mode, only a 2-frame movie
                if strcmp(typeArray{1}, 'trigger')
                    if size(spec.stimulus,3) ~= 2
                        size(spec.stimulus,3)
                        error('trigger mode only works with a 2-frame movie');
                    end
                    if typeArray{2}~=0 && typeArray{2}~=1 %edf asks: why not ~islogical(typeArray{2})?
                        typeArray{2}
                        error('toggleStim must be a logical');
                    end
                end
                spec.stimType = varargin{3};
            else
                error('invalid specification of stimType in cell array format');
            end
        else
            error('stimType must be trigger, loop, cache, timedFrames, indexedFrames, or expert');
        end
        % startFrame
        if isscalar(varargin{4}) && varargin{4}>=0
            spec.startFrame=varargin{4};
        else
            error('startFrame must be >=0');
        end
        % framesUntilTransition
        if isscalar(varargin{5}) && varargin{5} > 0
            spec.framesUntilTransition = varargin{5};
            % check that we have a 'frame timeout' port specified in the transitions
            if ~any(cellfun('isempty',spec.transitions))
                spec.framesUntilTransition
                spec.transitions
                error('if defining framesUntilTransition, must specify a ''frame timeout'' phase target');
            end
        elseif isempty(varargin{5})
            spec.framesUntilTransition = [];
        else
            error('framesUntilTransition must be a real scalar or empty')
        end
        % stochasticDistribution
        if iscell(varargin{6})
                stoD = varargin{6};
                if isreal(stoD{1}) && stoD{1} >= 0 && stoD{1} < 1 && isvector(stoD{2})
                    spec.stochasticDistribution = varargin{6};
                else
                    error('distribution must be a real number in [0,1) and port must be a vector');
                end
        elseif isempty(varargin{6})
            'do nothing here b/c we do not want any auto requests';
        else
            error('stochasticDistribution must be a cell array');
        end
        % scaleFactor
        if (length(varargin{7})==2 && all(varargin{7}>0)) || (length(varargin{7})==1 && varargin{7}==0)
            spec.scaleFactor=varargin{7};
        elseif isempty(varargin{7})
            spec.scaleFactor=[];
        else
            error('scale factor is either 0 (for scaling to full screen) or [width height] positive values, or empty to be filled in by a reinforced phase')
        end
        % isFinalPhase
            if isscalar(varargin{8}) && (varargin{8} == 0 || varargin{8} == 1)
                spec.isFinalPhase = varargin{8};
            else
                error('isFinalPhase must be a scalar 0 or 1')
            end
        % hz
        if isscalar(varargin{9}) && (varargin{9}>0 || (ismac && varargin{9}==0)) && isreal(varargin{9})
            spec.hz=varargin{9};
        else
            error('hz must be scalar real >0')
        end
        % phaseType - we need this so that runRealTimeLoop knows whether or not this phase should do a reward/airpuff, etc
        if ~isempty(varargin{10}) && ischar(varargin{10}) && strcmp(varargin{10},'reinforced')
            spec.phaseType=varargin{10};
        elseif isempty(varargin{10})
            spec.phaseType=[];
        else
            error('phaseType must be ''reinforced'',or []');
        end     
        % phaseLabel
        if ischar(varargin{11})
            spec.phaseLabel=varargin{11};
        elseif isempty(varargin{11})
            spec.phaseLabel='';
        else
            error('phaseLabel must be a string or empty');
		end

		if nargin>=12 && ~isempty(varargin{12})
			spec.isStim=varargin{12};
		end
		if islogical(spec.isStim) && isscalar(spec.isStim)
			%pass
		else
			error('isStim must be logical scalar')
		end
		
        if (isempty(spec.scaleFactor) || isempty(spec.stimulus)) && ~strcmp(spec.phaseType,'reinforced')
            error('empty scaleFactor and stimulus allowed only for reinforced phaseType');
		end
        
		stimLen=size(spec.stimulus,3);
		if nargin>=13 && ~isempty(varargin{13})
			spec.indexPulses=varargin{13};
		else
			spec.indexPulses=false(1,stimLen);
		end
		if isvector(spec.indexPulses) && islogical(spec.indexPulses) && length(spec.indexPulses)==stimLen
			%pass
		else
			error('indexPulses must be logical vector same length as stimulus')
		end
		
        spec = class(spec,'stimSpec');
        
    otherwise
        error('Wrong number of input arguments')
end

