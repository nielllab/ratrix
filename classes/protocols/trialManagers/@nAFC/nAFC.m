function t=nAFC(varargin)
% NAFC  class constructor.
% t=nAFC(soundManager,percentCorrectionTrials,rewardManager,
%         [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%		  [delayManager],[responseWindowMs],[showText],[customDescription])

argN=[3 13];

t.percentCorrectionTrials=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        a=trialManager();
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'nAFC'))
            t = varargin{1};
        else
            error('Input argument is not a nAFC object')
        end
    case cellCount(argN) %{3 4 5 6 7 8 9 10 11 12 13}
        
        % percentCorrectionTrials
        if varargin{2}>=0 && varargin{2}<=1
            t.percentCorrectionTrials=varargin{2};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end
        
        for i=argN(1)+1:argN(end)
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        % requestPorts
        if isempty(args{8})
            args{8}='center'; % default nAFC requestPorts should be 'center'
        end
        
        if isempty(args{13})
            d=sprintf(['n alternative forced choice' ...
                '\n\t\t\tpercentCorrectionTrials:\t%g'], ...
                t.percentCorrectionTrials);
        else
            d=args{13};
        end
        
        a=trialManager(varargin{1},varargin{3},args{4},d,args{5},args{6},args{7},args{8},args{9},args{10},args{11},args{12});
                
    otherwise
        nargin
        error('Wrong number of input arguments')
end

t = class(t,'nAFC',a);
end