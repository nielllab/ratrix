function t=promptedNAFC(varargin)
% promptedNAFC  class constructor.
%subplass of nACF, allows for prompts
% t=promptedNAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
%                requestRewardSizeULorMS,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
%                maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask, rewardManager,...
%                delayMeanMs, delayStdMs, delayStim, promptStim)
% msResponseTimeLimit=0 means unlimited response time
% msMaximumStimPresentationDuration=0 means unlimited stim presentation duration
% maximumNumberStimPresentations=0 means unlimited presentations
switch nargin
    case 0
        % if no input arguments, create a default object
        
        t.delayMeanMs=[];
        t.delayStdMs=[];
        t.delayStim=[];
       t.promptStim=[];
        
        
        a=nAFC();
        t = class(t,'promptedNAFC',a);
        
        
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'promptedNAFC'))
            t = varargin{1};
        else
            error('Input argument is not a promptedNAFC object')
        end
    case 17

        if varargin{14}>=0
            t.delayMeanMs=varargin{14};
        else
            error('delayMean must be >= 0')
        end
        
        if varargin{15}>=0
            t.delayStdMs=varargin{15};
        else
            error('delayStd must be >= 0')
        end
        
        if varargin{16}>=0  && varargin{16}<=1 && all(size(varargin{16})==[1 1])
            t.delayStim=varargin{16};
        else
            error('delayStim must a single luminance value 0 to 1 for now...maybe one day a movie...better yet: stimManager.calcStim(''delayPhase'')')
        end
        
        if varargin{17}>=0 && varargin{17}<=1 &&  all(size(varargin{17})==[1 1])
            t.promptStim=varargin{17};
        else
            error('promptStim must a single luminance value 0 to 1 for now...maybe one day a movie...better yet: stimManager.calcStim(''delayPhase'')')
        end

        a=nAFC(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},varargin{13});
        t = class(t,'promptedNAFC',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.nAFC);