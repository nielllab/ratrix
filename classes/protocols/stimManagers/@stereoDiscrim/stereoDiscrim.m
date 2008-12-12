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
        
    if varargin{2} > 0
        s.freq=varargin{2};
    else
        error('freq must be > 0')
    end
    
    if length(varargin{3}) == 2 && all(varargin{3}>=0) 
        s.amplitudes=varargin{3};
    else
        error('require two stereo amplitudes and they must be >= 0')
    end

    s = class(s,'stereoDiscrim',stimManager(varargin{4},varargin{5},varargin{6},varargin{7}));   
    
otherwise
    error('Wrong number of input arguments')
end