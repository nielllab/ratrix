function t=goNoGo(varargin)
% goNoGo  class constructor.
% t=goNoGo(soundManager,percentCorrectionTrials,responseLockoutMs,rewardManager,
%         [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%		  [delayFunction],[responseWindowMs],[showText])

switch nargin
    case 0
        % if no input arguments, create a default object
        a=trialManager();
        t.percentCorrectionTrials=0;
        t.responseLockoutMs=[];
        t = class(t,'goNoGo',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'goNoGo'))
            t = varargin{1};
        else
            error('Input argument is not a goNoGo object')
        end
    case {4 5 6 7 8 9 10 11 12 13}

        % percentCorrectionTrials
        if varargin{2}>=0 && varargin{2}<=1
            t.percentCorrectionTrials=varargin{2};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end
        
        if isscalar(varargin{3}) && varargin{3}>=0
            t.responseLockoutMs=varargin{3};
        elseif isempty(varargin{3})
            t.responseLockoutMs=[];
        else
            error('responseLockoutMs must be a real scalar or empty');
        end
        
        d=sprintf(['goNoGo' ...
            '\n\t\t\tpercentCorrectionTrials:\t%g'], ...
            t.percentCorrectionTrials);
        
        for i=5:13
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        % requestPorts
        if isempty(args{9})
            args{9}='none'; % default goNoGo requestPorts should be 'none' (all ports are targetPorts?)
        end

        a=trialManager(varargin{1},varargin{4},args{5},d,args{6},args{7},args{8},args{9},args{10},args{11},args{12},args{13});

        t = class(t,'goNoGo',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end