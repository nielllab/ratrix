function t=nAFC(varargin)
% NAFC  class constructor.
% t=nAFC(soundManager,percentCorrectionTrials,rewardManager,
%         [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts])

switch nargin
    case 0
        % if no input arguments, create a default object
        a=trialManager();
        t.percentCorrectionTrials=0;
        t = class(t,'nAFC',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'nAFC'))
            t = varargin{1};
        else
            error('Input argument is not a nAFC object')
        end
    case {3 4 5 6 7 8}

        % percentCorrectionTrials
        if varargin{2}>=0 && varargin{2}<=1
            t.percentCorrectionTrials=varargin{2};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end
        
        d=sprintf(['n alternative forced choice' ...
            '\n\t\t\tpercentCorrectionTrials:\t%g'], ...
            t.percentCorrectionTrials);
        
        for i=4:8
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

        a=trialManager(varargin{1},varargin{3},args{4},d,args{5},args{6},args{7},args{8});

        t = class(t,'nAFC',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end