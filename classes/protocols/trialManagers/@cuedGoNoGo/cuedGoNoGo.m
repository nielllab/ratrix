function t=cuedGoNoGo(varargin)
% cuedGoNoGo  class constructor.
% t=cuedGoNoGo(soundManager,rewardManager,
%         [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%		  [delayManager],[responseWindowMs],[showText])

%cuedGoNoGo is very similar to nAFC, with no new parameters



switch nargin
    case 0
        % if no input arguments, create a default object
        a=trialManager();
        t=struct([]); 
        t = class(t,'cuedGoNoGo',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'cuedGoNoGo'))
            t = varargin{1};
        else
            error('Input argument is not a cuedGoNoGo object')
        end
    case {3 4 5 6 7 8 9 10 11}

        t=struct([]); % no extra fields needed
        d=sprintf(['cuedGoNoGo']);
        
        for i=3:11
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        % requestPorts
        if isempty(args{7})
            args{7}='none'; % default cuedGoNoGo requestPorts should be 'none'
        end

        %a=trialManager(varargin{1},varargin{3},args{4},d,args{5},args{6},args{7},args{8},args{9},args{10},args{11},args{12}); % old is wrong now
        a=trialManager(varargin{1},varargin{2},args{3},d,args{4},args{5},args{6},args{7},args{8},args{9},args{10},args{11}); % this is better
                
        t = class(t,'cuedGoNoGo',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end