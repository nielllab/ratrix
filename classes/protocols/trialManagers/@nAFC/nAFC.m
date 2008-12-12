function t=nAFC(varargin)
% NAFC  class constructor.
% t=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
%                requestRewardSizeULorMS,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
%                maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask, rewardManager, [eyeTracker,eyeController])
% msResponseTimeLimit=0 means unlimited response time
% msMaximumStimPresentationDuration=0 means unlimited stim presentation duration
% maximumNumberStimPresentations=0 means unlimited presentations
switch nargin
    case 0
        % if no input arguments, create a default object

        a=trialManager();

        t.requestRewardSizeULorMS=0;
        t.percentCorrectionTrials=0;
        t.msResponseTimeLimit=0;
        t.pokeToRequestStim=0;
        t.maintainPokeToMaintainStim=0;
        t.msMaximumStimPresentationDuration=0;
        t.maximumNumberStimPresentations=0;
        t.doMask=0;

        t = class(t,'nAFC',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'nAFC'))
            t = varargin{1};
        else
            error('Input argument is not a nAFC object')
        end
    case {13 15}



%       this gets set by the setRequestReward method now - 12/10/08
        if varargin{5}>=0
            t.requestRewardSizeULorMS=varargin{5};
        else
            error('requestRewardSizeULorMS must be >= 0')
        end

        if varargin{6}>=0 && varargin{6}<=1
            t.percentCorrectionTrials=varargin{6};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end

        if varargin{7}>=0
            t.msResponseTimeLimit=varargin{7};
        else
            error('msResponseTimeLimit must be >= 0')
        end

        if varargin{8}==0 || varargin{8}==1
            t.pokeToRequestStim=varargin{8};
        else
            error('pokeToRequestStim must be logical')
        end

        if varargin{9}==0 || varargin{9}==1
            t.maintainPokeToMaintainStim=varargin{9};
        else
            error('maintainPokeToMaintainStim must be logical')
        end

        if varargin{10}>=0
            t.msMaximumStimPresentationDuration=varargin{10};
        else
            error('msMaximumStimPresentationDuration must be >= 0')
        end

        if varargin{11}>=0
            t.maximumNumberStimPresentations=varargin{11};
        else
            error('maximumNumberStimPresentations must be >= 0')
        end

        if varargin{12}==0 || varargin{12}==1
            t.doMask=varargin{12};
        else
            error('doMask must be logical')
        end

        if t.msResponseTimeLimit == 0
            responseTimeLimitStr = 'unlimited';
        else
            responseTimeLimitStr = sprintf('%d',t.msResponseTimeLimitStr);
        end

        if t.msMaximumStimPresentationDuration == 0
            maxStimPresDurStr = 'unlimited';
        else
            maxStimPresDurStr = sprintf('%d',t.msMaximumStimPresentationDuration);
        end

        if t.maximumNumberStimPresentations == 0
            maxNumStimPresStr = 'unlimited';
        else
            maxNumStimPresStr = sprintf('%d',t.maximumNumberStimPresentations);
        end
        
        d=sprintf(['n alternative forced choice' ...
            '\n\t\t\trequestRewardSizeULorMS:\t%d' ...
            '\n\t\t\tpercentCorrectionTrials:\t%g' ...
            '\n\t\t\tmsResponseTimeLimit:\t%s'...
            '\n\t\t\tpokeToRequestStim:\t%d' ...
            '\n\t\t\tmaintainPokeToMaintainStim:\t%d' ...
            '\n\t\t\tmsMaximumStimPresentationDuration:\t%s' ...
            '\n\t\t\tmaximumNumberStimPresentations:\t%s' ...
            '\n\t\t\tdoMask:\t%d'], ...
            t.requestRewardSizeULorMS,t.percentCorrectionTrials,responseTimeLimitStr,...
            t.pokeToRequestStim,t.maintainPokeToMaintainStim,maxStimPresDurStr,...
            maxNumStimPresStr,t.doMask);

        if nargin==13
            a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{13},d);
        elseif nargin==15
            a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{13},varargin{14},varargin{15},d);
        else
            error('should never happen')
        end
        
        t = class(t,'nAFC',a);
        % setRequestRewardSizeULorMS
        t=setRequestReward(t,varargin{5},true);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end