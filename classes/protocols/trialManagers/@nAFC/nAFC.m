function t=nAFC(varargin)
% NAFC  class constructor.
% t=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
%                msPenalty,requestRewardSizeULorMS,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
%                maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration,eyepuffMS)
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
    case 16




        if varargin{7}>=0
            t.requestRewardSizeULorMS=varargin{7};
        else
            error('requestRewardSizeULorMS must be >= 0')
        end

        if varargin{8}>=0 && varargin{8}<=1
            t.percentCorrectionTrials=varargin{8};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end

        if varargin{9}>=0
            t.msResponseTimeLimit=varargin{9};
        else
            error('msResponseTimeLimit must be >= 0')
        end

        if varargin{10}==0 || varargin{10}==1
            t.pokeToRequestStim=varargin{10};
        else
            error('pokeToRequestStim must be logical')
        end

        if varargin{11}==0 || varargin{11}==1
            t.maintainPokeToMaintainStim=varargin{11};
        else
            error('maintainPokeToMaintainStim must be logical')
        end

        if varargin{12}>=0
            t.msMaximumStimPresentationDuration=varargin{12};
        else
            error('msMaximumStimPresentationDuration must be >= 0')
        end

        if varargin{13}>=0
            t.maximumNumberStimPresentations=varargin{13};
        else
            error('maximumNumberStimPresentations must be >= 0')
        end

        if varargin{14}==0 || varargin{14}==1
            t.doMask=varargin{14};
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

        a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{15},d,varargin{16});
        t = class(t,'nAFC',a);
        
    otherwise
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.trialManager);