function t=soundManager(varargin)
% SOUNDMANAGER  class constructor.
% t = soundManager({soundClips})
% typical soundClips: {correctSound,keepGoingSound,trySomethingElseSound,wrongSound}

t.clips={};
t.players={};

% %edf does not endorse the following old choices
% t.pahandle = [];
% t.latbias = 0;
% % Default to auto-selected default output device if none specified:
% t.deviceid = -1;
% % Request latency mode 2, which used to be the best one in our measurement:
% t.reqlatencyclass = 1; % class 2 empirically the best, 3 & 4 == 2
% % Requested output frequency, may need adaptation on some audio-hw:
% t.freq = 44100;        % Must set this. 96khz, 48khz, 44.1khz.
% t.buffersize = 4096;     % Need to set to max(4096), otherwise sounds bad.
% % Need to determine empirically
% t.latbias = 30/t.freq;
% %t.latbias = -0.001;

switch nargin
    case 0
        % if no input arguments, create a default object
    case 1
        if (isa(varargin{1},'soundManager')) % if single argument of this class type, return it
            t = varargin{1};
            return
        elseif isVectorOfType(varargin{1},'soundClip') % create object using specified values
            t.clips=varargin{1};
        else
            error('must pass in a vector of soundClips')
        end
    otherwise
        error('Wrong number of input arguments')
end
t.playingNonLoop=false(1,length(t.clips));
t.playingLoop=false(1,length(t.clips));
t.clipDurs=zeros(1,length(t.clips));
t = class(t,'soundManager');