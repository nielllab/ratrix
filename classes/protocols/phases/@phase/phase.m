function this=phase(varargin)
% PHASE  class constructor.
% this = phase(phaseStruct)
% phaseStruct fields:
% {stim,metaPixelSize,frameTimes,frameSounds,showScreenLabel,displayText,window,maxDurationSecs,timeoutKillLevel,requestOptions,responseOptions,failOnEarlyResponse,completeEachInFull,advanceOnRequestEnd,loopPhase}

if nargin==1 && isa(varargin{1},'phase')
    % if single argument of this class type, return it
    this=varargin{1};
else
    this.stim=[];
    this.metaPixelSize=[];
    this.frameTimes=[];
    this.frameSounds={};
    this.showScreenLabel=[];
    this.displayText=[];
    this.window=[];
    this.maxDurationSecs=[];
    this.timeoutKillLevel='';
    this.destRect=[];
    this.requestOptions=[];
    this.responseOptions=[];
    this.failOnEarlyResponse=[];
    this.completeEachInFull=[];
    this.advanceOnRequestEnd=[];
    this.loopPhase=[];

    switch nargin
        case 0
            % if no input arguments, create a default object
        case 1

            fieldNames={'stim','metaPixelSize','frameTimes','frameSounds','maxDurationSecs','timeoutKillLevel','showScreenLabel','displayText','window',...
                'requestOptions','responseOptions','failOnEarlyResponse','completeEachInFull','advanceOnRequestEnd','loopPhase'};
            if isstruct(varargin{1}) && length(fieldNames)==length(fields(varargin{1})) && all(strcmp(sort(fieldNames),sort(fields(varargin{1})))) && isvector(varargin{1})

                for i=1:length(varargin{1})
                    this(i)=makeAtomicPhase(varargin{1}(i),fieldNames);
                end

            else
                error('phaseStruct must be vector struct array with exactly the fields %s',prettyCat(fieldNames))
            end
        otherwise
            error('wrong number of input arguments')
    end

    this = class(this,'phase');
end


function this=makeAtomicPhase(phaseStruct,fieldNames)

for i=1:length(fieldNames)

    if ~strcmp(fieldNames{i},'stim')
        this.(fieldNames{i})=phaseStruct.(fieldNames{i});

        switch fieldNames{i}

            case 'metaPixelSize'
                if ~isreal(this.metaPixelSize) || ~isvector(this.metaPixelSize) || length(this.metaPixelSize)>2 || any(this.metaPixelSize<=0)
                    error('metaPixelSize must be real vector, length 0-2, elements > 0, (empty means fill full screen, destroying aspect ratio, length 1 means square, length 2 is [height width])')
                end
            case 'frameTimes'
                if ~isinteger(this.frameTimes) || ~isreal(this.frameTimes) || ~isvector(this.frameTimes) || ~length(this.frameTimes)==size(phaseStruct.stim,3) || any(this.frameTimes<0)
                    error('bad frameTimes -- must be integer real vector, elements >=0, same length as number of frames in stim')
                end
            case 'frameSounds'
                %list of sound names to play during each frame (this is in addition to fixed sounds, such as those caused by licks/pokes)
                %check that these sounds are available
                %check its the right length
            case 'showScreenLabel'
                if ~isboolean(this.showScreenLabel)
                    error('showScreenLabel must be boolean')
                end
            case 'displayText'
                if ~ischar(this.displayText) || ~isvector(this.displayText)
                    error('displayText must be a string')
                end
            case 'window'
                if ~ismember(this.window,Screen('Windows'))
                    error('that window isn''t open')
                end
            case 'maxDurationSecs'
                if ~isreal(this.maxDurationSecs) || ~isscalar(this.maxDurationSecs) || this.maxDurationSecs<0
                    error('maxDurationSecs must be real scalar, values <0 indicate no limit')
                end
            case 'timeoutKillLevel'
                if ~ismember(this.timeoutKillLevel,{'phase','trial','session'})
                    error('timeoutKillLevel must be one of ''phase'', ''trial'', or ''session''')
                end
            case {'requestOptions','responseOptions'}
                if ~isboolean(this.(fieldNames{i})) || ~isvector(this.(fieldNames{i})) || length(this.(fieldNames{i}))~=getNumPorts(station)
                    error('request and response options must be boolean vectors the same length as the number of ports in the station')
                end
            case 'failOnEarlyResponse'
                if ~isboolean(this.failOnEarlyResponse) || ~isscalar(this.failOnEarlyResponse)
                    error('failOnEarlyResponse must be scalar boolean')
                end
            case 'completeEachInFull'
                if ~isboolean(this.completeEachInFull) || ~isscalar(this.completeEachInFull)
                    error('completeEachInFull must be scalar boolean')
                end
            case 'advanceOnRequestEnd'
                if ~isboolean(this.advanceOnRequestEnd) || ~isscalar(this.advanceOnRequestEnd)
                    error('advanceOnRequestEnd must be scalar boolean')
                end
            case 'loopPhase'
                if ~isboolean(this.loopPhase) || ~isscalar(this.loopPhase)
                    error('loopPhase must be scalar boolean')
                end
            otherwise
                error('should never happen')
        end
    end
end

if any(and(this.requestOptions,this.responseOptions)) %can't do this til after the loop above cuz don't know when both will be defined
    error('request and response options must not overlap')
end

if length(size(phaseStruct.stim))~=3 || ~isreal(phaseStruct.stim)
    error('stim must be 3D reals (monochromatic height x width x frameNum) (4D RGB not yet supported)')
end

floatprecision=0; %tells maketexture what dynamic range to use
%                 %0 is 8bpc, 0-255 (default)
%                 %1 is 16bpc, 0.0-1.0
%                 %2 is 32bpc, 0.0-1.0
switch class(phaseStruct.stim)
    %need to check into how high dynamic range
    %textures interact with the clut -- does
    %the clut need to be HDR?

    case {'double','single'}
        if any(phaseStruct.stim(:)>1) || any(phaseStruct.stim(:)<0)
            error('double or single stim must normalize elements to 0-1')
        else
            floatprecision=2;%want 32pbc to preserve precision of 32 bit singles, but should check for running low on VRAM and knock this down to 16bpc if necessary
        end
    case 'uint8'
        %do nothing
    case {'uint16','uint32','uint64'}
        switch class(phaseStruct.stim)
            case 'uint16'
                floatprecision=1;
            case {'uint32','uint64'}
                floatprecision=2;
            otherwise
                error('should never happen')
        end
        phaseStruct.stim=double(phaseStruct.stim)/double(intmax(class(phaseStruct.stim))); %doubles are 8 bytes, should check for out of memory error and be willing to switch to singles (losing precision) in this case
    case 'logical'
        phaseStruct.stim=uint8(phaseStruct.stim)*intmax('uint8'); %force to 8 bit
    otherwise
        error('stim classes currently supported: {uint8 (range 0-255) or logical, treated as 8bpc)}, {uint16 (range 0-65,535), treated as 16bpc}, {single or double (range 0.0-1.0), uint32 (range 0-4,294,967,295), uint64 (range 0-18,446,744,073,709,551,615), treated as 32bpc)}')
end

%we do NOT want to store this ginormous beast, but only send to VRAM and keep a texture pointer
this.stim=zeros(1,size(phaseStruct.stim,3));
for i=1:size(phaseStruct.stim,3)
    this.stim(i)=Screen('MakeTexture', this.window, squeeze(phaseStruct.stim(:,:,i)),0,0,floatprecision);
end


%apply metaPixelSize (cache it out as destRect)
[scrWidth scrHeight]=Screen('WindowSize',this.window);

switch length(this.metaPixelSize)
    case 0 %fill full screen, destroying aspect ratio
        scaleFactor = [scrHeight scrWidth]./[size(phaseStruct.stim,1) size(phaseStruct.stim,2)];
    case 1
        scaleFactor = ones(1,2)*this.metaPixelSize;
    case 2
        scaleFactor = this.metaPixelSize;
    otherwise
        error('should never happen')
end

if any(scaleFactor.*[size(phaseStruct.stim,1) size(phaseStruct.stim,2)]>[scrHeight scrWidth])
    error('metaPixelSize argument too big')
end

height = scaleFactor(1)*size(phaseStruct.stim,1);
width = scaleFactor(2)*size(phaseStruct.stim,2);

scrRect = Screen('Rect', this.window);
scrLeft = scrRect(1); %am i retarted?  (sic :)  why isn't [scrLeft scrTop scrRight scrBottom]=Screen('Rect', window); working?  deal doesn't work
scrTop = scrRect(2);
scrRight = scrRect(3);
scrBottom = scrRect(4);

this.destRect = round([scrRight-scrLeft scrBottom-scrTop scrRight-scrLeft scrBottom-scrTop]/2 + [-width -height width height]/2); %[left top right bottom]

