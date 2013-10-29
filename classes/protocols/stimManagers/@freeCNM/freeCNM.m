function s=freeCNM(varargin)
% Continuous NonMatch (CNM) class constructor.
% s =
% CNM(mean,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% mean normalized (0 <= value <= 1)
% Description of arguments:
% =========================
% mean - Mean brightness
% soundParams.soundType = {'allOctaves','tritones', 'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','tone','CNMToneTrain','empty'} (valid sound clip types)
% soundParams.freqs - (Fundamental) frequencies of sounds to play
% soundParams.duration sound duration in ms
% soundParams.amp - sound amplitude
% soundParams.isi - ms, time between tones in a CNMToneTrain
% soundParams.toneDuration - ms, duration of each tone in a CNMToneTrain
% soundParams.startfreq - 1 or 2, index of soundParams.freqs to start at

s.mean = 0;
s.freqs = 0;
s.amplitude = [];
s.toneDuration = [];
s.duration = [];
s.isi = [];
s.startfreq = [];
s.stimSound = []; % Sound to play for the stimulus
s.stimSound2 = []; %2nd tone, played during early penalty (phase 3)
s.audioStimulus = true;
s.soundType='';
        
switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'freeCNM',stimManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'freeCNM'))
            s = varargin{1};
        else
            error('Input argument is not a freeCNM object')
        end
    case 6
        % create object using specified values
        if varargin{1} >=0
            s.mean=varargin{1};
        else
            error('0 <= mean <= 1')
        end
        
        soundParams=varargin{2};
        s.soundType=soundParams.soundType;
        
        %error checking on soundParams and assign to s:
        if all(soundParams.amp>=0) && all(soundParams.amp<=1)
            s.amplitude=soundParams.amp;
        else
            error(' amplitudes  must be 0 <= x <= 1')
        end
        if all(soundParams.duration>=0)
            s.duration=soundParams.duration; %mw 04.05.2012
        else
            error(' duration  must be >0')
        end
        
        switch s.soundType
            case {'allOctaves','tritones'}
                if soundParams.freqs > 0
                    s.freqs=soundParams.freqs;
                else
                    error('freq must be > 0')
                end
                
            case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
                %no specific error checking here
            case {'tone', 'CNMToneTrain','freeCNMToneTrain'}
                if soundParams.freqs > 0
                    s.freqs=soundParams.freqs;
                    s.isi=soundParams.isi;
                    s.toneDuration=soundParams.toneDuration;
                    s.startfreq = soundParams.startfreq;
                else
                    error('freq must be > 0')
                end

            otherwise
                error('freeCNM: soundType not recognized')
        end
        
        s = class(s,'freeCNM',stimManager(varargin{3},varargin{4},varargin{5},varargin{6}));
        
    otherwise
        error('Wrong number of input arguments')
end