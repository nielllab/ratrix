function t=ball(varargin)
% BALL  class constructor.
% t=ball(percentCorrectionTrials,soundManager,...
%      rewardManager,[eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%	   [delayManager],[responseWindowMs],[showText])

argN=[3 12];
t.percentCorrectionTrials=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        a=trialManager();
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'ball'))
            t = varargin{1};
        else
            error('Input argument is not a ball object')
        end
    case mat2cell(argN(1):argN(2),1,ones(1,argN(2)-argN(1)+1)) % {3 4 5 6 7 8 9 10 11 12}
        % percentCorrectionTrials
        if varargin{1}>=0 && varargin{1}<=1
            t.percentCorrectionTrials=varargin{1};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end
        
        d=sprintf('ball');
        
        for i=4:12
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        % requestPorts
        if isempty(args{8})
            args{8}='none';
        end

        a=trialManager(varargin{2},varargin{3},args{4},d,args{5},args{6},args{7},args{8},args{9},args{10},args{11},args{12});
                
    otherwise
        nargin
        error('Wrong number of input arguments')
end

t = class(t,'ball',a);