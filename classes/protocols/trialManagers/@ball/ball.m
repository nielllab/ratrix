function t=ball(varargin)
% BALL  class constructor.
% t=ball(percentCorrectionTrials,soundManager,...
%      rewardManager,[eyeController],[frameDropCorner],[dropFrames],[displayMethod],[saveDetailedFramedrops],
%	   [delayManager],[responseWindowMs],[showText])

argN=[3 11];

t=struct([]);

switch nargin
    case 0
        % if no input arguments, create a default object
        a=nAFC();
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'ball'))
            t = varargin{1};
        else
            error('Input argument is not a ball object')
        end
    case cellCount(argN) % {3 4 5 6 7 8 9 10 11 12}
        
        d=sprintf('ball');
        
        for i=argN(1)+1:argN(end)
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        requestPorts='none';

        a=nAFC(varargin{2},varargin{1},varargin{3},args{4},args{5},args{6},args{7},requestPorts,args{8},args{9},args{10},args{11},d);
                
    otherwise
        nargin
        error('Wrong number of input arguments')
end

t = class(t,'ball',a);
end