function t=soundClip(varargin)
% SOUNDCLIP  class constructor.
% t = soundClip(name,type,[fundamentalFreqs],maxFreq)

% Set all attributes here, so they are all defined
t.sampleRate = 88200;
t.msLength = 500;
t.msMinSoundDuration = 100;
t.numSamples = t.sampleRate*t.msLength/1000;
t.amplitude = 1.0; % Not currently specified by default
t.fundamentalFreqs = [];
t.freq = [];
t.maxFreq = 0;
t.name = '';
t.clip = [];
t.description = '';
t.type = '';
t.leftSoundClip = [];
t.rightSoundClip = [];
t.leftAmplitude = 0.0;
t.rightAmplitude = 0.0;

switch nargin
    case 0
        % if no input arguments, create a default object
        t = class(t,'soundClip');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'soundClip'))
            t = varargin{1};
        else
            error('Input argument is not a soundClip object')
        end
    case 2
        if ismember(varargin{2},{'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'})
            t.fundamentalFreqs = [];
            t.maxFreq = 0;
            
            if ischar(varargin{1})
                t.name=varargin{1};
            else
                error('name wasn''t a string')
            end
            
            t.clip = [];
            t.description = varargin{2};
            
            t.type = varargin{2};
            
            
            t = class(t,'soundClip');
        else
            error('type for 2 args must be binaryWhiteNoise gaussianWhiteNoise uniformWhiteNoise empty')
        end
    case 3 %tone or CNMToneTrain or freeCNMToneTrain
        if ischar(varargin{1})
            t.name=varargin{1};
        else
            error('name wasn''t a string')
        end
        t.clip = [];
        % create object using specified values
        if ismember(varargin{2},{'tone', 'CNMToneTrain', 'freeCNMToneTrain','wmToneWN', 'wmReadWav', 'phonemeWav', 'warblestackWav','phonemeWavReversedReward'} ) 
            if ~all(varargin{3}>0) 
%                error('pass in Freq  > 0') %commented out to allow isi of 0 
            end 
            t.freq = varargin{3};
            switch(varargin{2})
                case 'tone'
                    t.description = ['pure tone ' num2str(t.freq) ' Hz'];
                    t.type = varargin{2};
                case 'CNMToneTrain'
                    t.description = ['CNMToneTrain, start: ' num2str(t.freq(1)) ' end: ' num2str(t.freq(2)) ' Hz, n=',num2str(t.freq(3)) ,' tones'];
                    t.type = varargin{2};
                case 'wmToneWN'
                    t.description = ['CNMToneTrain, start: ' num2str(t.freq(1)) ' end: ' num2str(t.freq(2)) ' Hz, n=',num2str(t.freq(3)) ,' tones'];
                    t.type = varargin{2};
                case 'freeCNMToneTrain'
                    t.description = ['freeCNMToneTrain, start: ' num2str(t.freq(1)) 'Hz, n=',num2str(t.freq(3)) ,' tones'];
                    t.type = varargin{2};    
                case 'wmReadWav'
                    t.description = ['wmReadWav'];
                    t.type = varargin{2};  
                case 'phonemeWav'
                    t.description = ['phonemeWav'];
                    t.type = varargin{2}; 
                case 'phonemeWavReversedReward'
                    t.description = ['phonemeWavReversedReward'];
                    t.type = varargin{2}; 
                case 'warblestackWav'
                    t.description = ['warblestackWav'];
                    t.type = varargin{2}; 
                otherwise
                    error('Should never happen!!: soundClip type already validated as tone')
            end
        else
            error('type for 3 args must be tone')
        end
        
        t = class(t,'soundClip');
        
    case 4
        if ischar(varargin{1})
            t.name=varargin{1};
        else
            error('name wasn''t a string')
        end
        t.clip = [];
        % create object using specified values
        if ismember(varargin{2},{'allOctaves','tritones'})
            if ~all(varargin{3}>0) || ~varargin{4}>0
                error('pass in [fundamentalFreqs] and maxFreq both > 0')
            end
            t.fundamentalFreqs = varargin{3};
            t.maxFreq = varargin{4};
            switch(varargin{2})
                case 'allOctaves'
                    t.description = ['all octaves of [' num2str(t.fundamentalFreqs) '] up to ' num2str(t.maxFreq)];
                    t.type = varargin{2};
                case 'tritones'
                    t.description = ['all tritones of [' num2str(t.fundamentalFreqs) '] up to ' num2str(t.maxFreq)];
                    t.type = varargin{2};
                otherwise
                    error('Should never happen!!: soundClip type already validated as allOctaves or tritones')
            end
        elseif ismember(varargin{2},{'dualChannel'})
            if ~iscell(varargin{3}) || ~iscell(varargin{4})
                error('Cell argument {soundClip,amplitude} expected for the two channels: left, right')
            end
            left = varargin{3};
            right = varargin{4};
            if ~isa(left{1},'soundClip') || ~isa(right{1},'soundClip')
                error('Cell argument {soundClip,amplitude} with soundClip an object of type @soundClip')
            end
            if left{2} <0 || right{2} <0
                error('Cell argument {soundClip,amplitude} with amplitude >= 0')
            end
            t.leftSoundClip = left{1};
            t.leftAmplitude = left{2};
            t.rightSoundClip = right{1};
            t.rightAmplitude = right{2};
            t.description = ['dualChannel soundclip with (Left: ''' getName(t.leftSoundClip) ''',[' t.leftAmplitude  ...
                ']; Right: ''' getName(t.leftSoundClip) ''',[' t.leftAmplitude  '])' ];
            t.type = varargin{2};
        else
            error('type for 4 args must be allOctaves, tritones, or dualChannel')
        end
        
        t = class(t,'soundClip');

                    
                    
                    
                    
    otherwise
        error('Wrong number of input arguments')
end