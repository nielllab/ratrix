function s=stereoDiscrim(varargin)
% Stereo Discrim class constructor.
% s =
% stereoDiscrim(mean,freq,[amplitudes],maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% mean normalized (0 <= value <= 1)
% Description of arguments:
% =========================
% mean - Mean brightness
% freq - (Fundamental) frequency of sound to play
% [amplitudes] - [low high] sound amplitudes from 0<=x<=1

s.mean = 0;
s.freq = 0;
s.amplitudes = [];
s.stimSound = []; % Sound to play for the stimulus
s.audioStimulus = true;
s.soundType='';

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'stereoDiscrim',stimManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'stereoDiscrim'))
            s = varargin{1};
        else
            error('Input argument is not a stereoDiscrim object')
        end
    case 7
        % create object using specified values
        if varargin{1} >=0
            s.mean=varargin{1};
        else
            error('0 <= mean <= 1')
        end
        
        soundType=varargin{2};
        soundParams=varargin{3};
        %error checking on soundParams and assign to s:
        switch soundType
            case {'allOctaves','tritones'}
                if soundParams.freq > 0
                    s.freq=soundParams.freq;
                else
                    error('freq must be > 0')
                end
                
                if length(soundParams.amps) == 2 && all(soundParams.amps>=0)
                    s.amplitudes=soundParams.amps;
                else
                    error('require two stereo amplitudes and they must be >= 0')
                end
                s.soundType=soundType;
            case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
                if length(soundParams.amps) == 2 && all(soundParams.amps>=0)
                    s.amplitudes=soundParams.amps;
                else
                    error('require two stereo amplitudes and they must be >= 0')
                end
                s.soundType=soundType;
            case 'tone'
                error('stereoDiscrim: tone not implemented yet')
                s.soundType=soundType;
            otherwise
                error('stereoDiscrim: soundType not recognized')
        end
        
        s = class(s,'stereoDiscrim',stimManager(varargin{4},varargin{5},varargin{6},varargin{7}));
        
    otherwise
        error('Wrong number of input arguments')
end