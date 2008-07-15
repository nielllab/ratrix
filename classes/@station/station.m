function s=station(varargin)
% STATION  class constructor.
% s = station(id,width,height,path,screenNum,,soundOn,rewardMethod,MACaddress,physicalLocation([rackID shelf position] -- upperleft is 1,1),numPorts)
% if using parallel port for responses/rewards, replace 'numports' above with arguments: (parallelPortAddress,responseMethod,valvePins,sensorPins,framePulsePins,eyePuffPins)
% if set rewardMethod to 'localPump', valvePins should be
% {int8([valvePins]),localPump object}

s.id=0;
s.width=0;
s.height=0;
s.path='';
s.screenNum=0;
s.soundOn=0;
s.rewardMethod='';
s.MACaddress='';
s.physicalLocation=[];
s.numPorts=0;

%s.parallelPortAddress='';
s.responseMethod='';
%s.valveOpenCodes=[];
%s.portCodes=[];
%s.framePulseCodes=[];
%s.eyepuffPin=[];

%new fast way
s.decPPortAddr='';
s.valvePins=[];
s.sensorPins=[];
s.framePulsePins=[];
s.eyePuffPins=[];

s.localPump=[];
s.localPumpInited=false;

needToInit=false;
usingPport=false;



switch nargin
    case 0
        % if no input arguments, create a default object

        s = class(s,'station');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'station'))
            s = varargin{1};
        else
            error('Input argument is not a station object')
        end

    case 10 %no parallel port
        s.responseMethod='keyboard';
        s.numPorts=varargin{10};

        if isinteger(s.numPorts) && isscalar(s.numPorts) && s.numPorts>0
            %pass
        else
            error('numPorts must be scalar integer >0')
        end

        needToInit=true;

    case 15 %with parallel port
        s.decPPortAddr=hex2dec(varargin{10});
        s.responseMethod=varargin{11};

        if iscell(varargin{12}) && isvector(varargin{12}) && length(varargin{12})==2 && ((isvector(varargin{12}{1}) && isinteger(varargin{12}{1})) || isempty(varargin{12}{1}))
            s.valvePins=varargin{12}{1};
            s.localPump=varargin{12}{2};
        elseif (isvector(varargin{12}) && isinteger(varargin{12})) || isempty(varargin{12})
            s.valvePins=varargin{12};
        else
            error('valvePins malformed')
        end

        if isvector(varargin{13}) && isinteger(varargin{13})
            s.sensorPins=varargin{13};
        else
            error('sensorPins must be vector of integers')
        end

        if isvector(varargin{14}) && isinteger(varargin{14})
            s.framePulsePins=varargin{14};
        else
            error('framePulsePins must be vector of integers')
        end

        if isvector(varargin{15}) && isinteger(varargin{15})
            s.eyePuffPins=varargin{15};
        else
            error('eyePuffPins must be vector of integers')
        end

        usingPport=true;
        needToInit=true;

    otherwise
        error('Wrong number of input arguments')
end

if usingPport
    if strcmp(s.responseMethod,'keyboard') || strcmp(s.responseMethod,'parallelPort')
        %pass
    else
        error('responseMethod must be keyboard or parallelPort')
    end

    if ismember(s.decPPortAddr,hex2dec({'B888','0378','FFF8'}))
        %pass
    else
        error('need a parallel port base address (should be ''0378'' (built-in) ''B888'' (pci) or ''FFF8'' (pcmcia)) -- under LPT ports in device manager, resources tab, I/O Range (first number is base address).');
        %base address is DATA register -- output -- pins 2-9
        %add 1 for STATUS register -- input -- pins 10,11(inverted),12,13,15
        %add 2 for CONTROL register -- bidirectional -- pins 1(inverted),14(inverted),16,17(inverted)
    end

    if ~strcmp(s.responseMethod,'parallelPort') && isinteger(s.sensorPins) && isscalar(s.sensorPins) && s.sensorPins>0
        s.numPorts=s.sensorPins;
        if length(s.valvePins)==s.numPorts || isempty(s.valvePins)
            %pass
        else
            error('if response method is not parallel port, sensorPins should be integer >0 that is number of ports, and valvePins should either be empty or have that number of elements')
        end
    elseif strcmp(s.responseMethod,'parallelPort') && (length(s.valvePins)==length(s.sensorPins) || isempty(s.valvePins)) && length(s.sensorPins)>0
        s.numPorts=length(s.sensorPins);
        s.sensorPins=assignPins(s.sensorPins,'read',s.decPPortAddr,[]);
    else
        error('if responseMethod is parallelPort, sensorPins and valvePins must be same length and have at least one element (or valvePins can be empty).  if responseMethod is not parallelPort, sensorPins must be scalar integer >0 that is number of ports.')
    end

    s.valvePins=assignPins(s.valvePins,'write',s.decPPortAddr,[s.sensorPins.pin]);

    s.framePulsePins=assignPins(s.framePulsePins,'write',s.decPPortAddr,[[s.sensorPins.pin] [s.valvePins.pin]]);

    s.eyePuffPins=assignPins(s.eyePuffPins,'write',s.decPPortAddr,[[s.sensorPins.pin] [s.valvePins.pin] [s.framePulsePins.pin]]);

end

if needToInit
    s.id=varargin{1};
    s.width=varargin{2};
    s.height=varargin{3};
    s.path=varargin{4};
    s.screenNum=varargin{5};
    s.soundOn=varargin{6};
    s.rewardMethod=varargin{7};
    s.MACaddress=varargin{8};
    s.physicalLocation=varargin{9};

    if strcmp(class(s.id),'char') 
        parse = textscan(s.id, '%d%s','expChars','');
        if iscell(parse) && all(size(parse)==[1 2]) && ~isempty(parse{1}) && ~isempty(parse{2}) 
            %pass
        else
            s.id
            class(s.id)
            error('textscan failed on id')
        end
    else
        class(s.id)
        s.id
        error('id must be a string of format <rack num><rack letter>, example ''2C''')
    end

    if s.width>0 && s.height>0
        %pass
    else
        error('width and height must be greater than zero')
    end

    if checkPath(s.path)
        %pass
    else
        error('path check failed.  must provide fully resolved path to the station.')
    end

    if s.screenNum>=0 && isinteger(s.screenNum)
        s.screenNum=double(s.screenNum);
        %pass
    else
        error('screen num should be integer >=0')
    end

    if islogical(s.soundOn)
        %pass
    else
        error('sound on should be logical')
    end

    if ~isempty(s.localPump)
        if isa(s.localPump,'localPump') && strcmp(s.rewardMethod,'localPump')
            %pass
        else
            error('bad local pump or rewardMethod not ''localPump''')
        end
    else
        if ~strcmp(s.rewardMethod,'localPump')
            %pass
        else
            error('need a local pump for rewardMethod ''localPump''')
        end
    end

    if (ismember(s.rewardMethod,{'serverPump','localPump'}) && usingPport && ~isempty(s.valvePins)) || strcmp(s.rewardMethod,'localTimed')
        %pass
    else
        error('rewardMethod must be localTimed, localPump, or serverPump (pumps currently only work with pport rewards, so valvePins must not be empty)')
    end

    if isMACaddress(s.MACaddress)
        %pass
    else
        error('mac address must be a 12 character hex string')
    end

    if isvector(s.physicalLocation) && isinteger(s.physicalLocation) && length(s.physicalLocation)==3 && all(s.physicalLocation>0)
        %pass
    else
        s.physicalLocation
        error('location must be vector of 3 integers [rackID shelf position], upper left is 1,1')
    end

    s = class(s,'station');
end

[s.valvePins.pin]
[s.valvePins.decAddr]
[s.valvePins.inv]
[s.valvePins.bitLoc]

[s.sensorPins.pin]
[s.sensorPins.decAddr]
[s.sensorPins.inv]
[s.sensorPins.bitLoc]

[s.framePulsePins.pin]
[s.framePulsePins.decAddr]
[s.framePulsePins.inv]
[s.framePulsePins.bitLoc]

[s.eyePuffPins.pin]
[s.eyePuffPins.decAddr]
[s.eyePuffPins.inv]
[s.eyePuffPins.bitLoc]

function out=assignPins(pins,dir,baseAddr,dontMatch)
out=[];
checks={};
for cNum=1:length(pins)
    checks{end+1}={dec2hex(baseAddr),pins(cNum)};
end

if all(goodPins(checks)) && length(unique(pins))==length(pins)

    for cNum=1:length(pins)
        if getDirForPinNum(pins(cNum),dir)
            spec=getBitSpecForPinNum(pins(cNum));

            out(cNum).pin=pins(cNum);
            out(cNum).decAddr=baseAddr+double(spec(2));
            out(cNum).bitLoc=spec(1);
            out(cNum).inv=spec(3);
        else
            error('pin not available for that dir')
        end
    end

else
    error('pins must be unique integers that represent parallel port pins')
end

for cNum=1:length(out)
    if ismember(out(cNum).pin,dontMatch)
        error('pin matches an already assigned pin')
    end
end