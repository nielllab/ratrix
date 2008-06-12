function t=soundManager(varargin)
% SOUNDMANAGER  class constructor.
% t = soundManager(correctSound,keepGoingSound,trySomethingElseSound,wrongSound)

t.AUDIO_PLAYER = 1;
t.PSYCH_PORT_AUDIO = 2;
t.clips={};
t.records=struct([]);
t.pahandle = [];
t.latbias = 0;
% Default to auto-selected default output device if none specified:
t.deviceid = -1;
% Request latency mode 2, which used to be the best one in our measurement:
t.reqlatencyclass = 1; % class 2 empirically the best, 3 & 4 == 2
% Requested output frequency, may need adaptation on some audio-hw:
t.freq = 44100;        % Must set this. 96khz, 48khz, 44.1khz.
t.buffersize = 4096;     % Need to set to max(4096), otherwise sounds bad.
t.playerType = t.AUDIO_PLAYER;
% Need to determine empirically
t.latbias = 30/t.freq;
%t.latbias = -0.001;

switch nargin
    case 0
        % if no input arguments, create a default object
        t = class(t,'soundManager');
    case 1
        if (isa(varargin{1},'soundManager')) % if single argument of this class type, return it
            t = varargin{1};
        elseif isVectorOfType(varargin{1},'soundClip') % create object using specified values
            t.clips=varargin{1};
            t = class(t,'soundManager');
        else
            error('must pass in a vector of soundClips')
        end
    case 2
        if isVectorOfType(varargin{1},'soundClip') % create object using specified values
            t.clips=varargin{1};
            t = class(t,'soundManager');
        else
            error('must pass in a vector of soundClips')
        end
        if isa(varargin{2},'char')
            if strcmp(varargin{2},'audioplayer')
                t.playerType = t.AUDIO_PLAYER;
            elseif strcmp(varargin{2},'psychportaudio')
                t.playerType = t.PSYCH_PORT_AUDIO;
            else
                error('Second argument to soundManager constructor should be sound player type as a string (audioplayer or psychportaudio)')
            end
        else
            error('Second argument to soundManager constructor should be sound player type as a string (audioplayer or psychportaudio)')
        end
    otherwise
        error('Wrong number of input arguments')
end