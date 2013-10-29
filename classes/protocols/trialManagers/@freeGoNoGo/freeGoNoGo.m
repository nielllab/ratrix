function t=freeGoNoGo(varargin)
% goNoGo  class constructor.
% t=goNoGo(soundManager,percentCorrectionTrials,responseLockoutMs,rewardManager,
%         [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%		  [delayFunction],[responseWindowMs],[showText])

switch nargin
    case 0
        % if no input arguments, create a default object
        a=trialManager();
        t.percentCorrectionTrials=0;
        t.earlyP=0;
        t = class(t,'freeGoNoGo',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'freeGoNoGo'))
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
        
         if t.percentCorrectionTrials~=0
            t.percentCorrectionTrials
            error('you probably don''t want correction trials on goNoGo')
        end
        
        if varargin{3}>=0
            t.earlyP=varargin{3};
        elseif isempty(varargin{3})
            t.earlyP=0;
        else
            error('earlyP must be a true or false');
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

        t = class(t,'freeGoNoGo',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end