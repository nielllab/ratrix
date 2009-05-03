function t=autopilot(varargin)
% AUTOPILOT  class constructor.
% t=autopilot(percentCorrectionTrials,soundManager,...
%      rewardManager,[eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%	   [stiulusOnsetMode],[responseWindowMs],[showText])
%
% Used for the whiteNoise, bipartiteField, fullField, and gratings stims, which don't require any response to go through the trial
% basically just play through the stims, with no sounds, no correction trials

switch nargin
    case 0
        % if no input arguments, create a default object

        a=trialManager();
        t.percentCorrectionTrials=0;
        t = class(t,'autopilot',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'autopilot'))
            t = varargin{1};
        else
            error('Input argument is not a autopilot object')
        end
    case {3 4 5 6 7 8 9 10 11 12}
        % percentCorrectionTrials
        if varargin{1}>=0 && varargin{1}<=1
            t.percentCorrectionTrials=varargin{1};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end
        
        d=sprintf('autopilot');

        
        for i=4:12
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        % requestPorts
        if isempty(args{8})
            args{8}='none'; % default autopilot requestPorts should be 'none'
        end

        a=trialManager(varargin{2},varargin{3},args{4},d,args{5},args{6},args{7},args{8},args{9},args{10},args{11},args{12});
        
        t = class(t,'autopilot',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end

