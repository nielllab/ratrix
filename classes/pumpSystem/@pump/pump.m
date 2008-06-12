function p=pump(varargin)
% PUMP  class constructor.
% p = pump(serPortAddr mmDiam mlPerHr doVolChks   motorRunningBit infTooFarBit  wdrTooFarBit  mlMaxSinglePump mlMaxPos mlOpportunisticRefill mlAntiRock)

p.serialPortAddress='';
p.mmDiameter=0.0;
p.mlPerHour=0.0;
p.doVolChecks=logical(0);
p.motorRunningBit={};
p.infTooFarBit={};
p.wdrTooFarBit={};
p.mlMaxSinglePump=0.0;
p.maxPosition=0.0;
p.mlOpportunisticRefill=0.0;
p.mlAntiRock=0.0;

p.units='';
p.volumeScaler=0.0;
p.serialPort=[];
p.pumpOpen=logical(0);
p.currentPosition=0.0;
p.minPosition=0.0;

p.const.motorRunning=int8(1);%'1';


switch nargin
    case 0
        % if no input arguments, create a default object
        p = class(p,'pump');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'pump'))
            p = varargin{1};
        else
            error('Input argument is not a pump object')
        end

    case 11
        % create object using specified values

        if ischar(varargin{1})>0
            p.serialPortAddress=varargin{1};
        else
            error('serialPortAddress must be a string')
        end

        checks=[varargin{2} varargin{3} varargin{8} varargin{9} varargin{10} varargin{11}];
        if all(isnumeric(checks)) && all(isreal(checks)) && all(checks>0) && length(checks)==6 %this verifies they are each scalar
            p.mmDiameter=varargin{2};
            p.mlPerHour=varargin{3};
            p.maxPosition=varargin{9};

            if varargin{11}<= varargin{8} && varargin{11}<= varargin{8} && varargin{8}<= p.maxPosition
                p.mlMaxSinglePump=varargin{8};
                p.mlOpportunisticRefill=varargin{10};
                p.mlAntiRock=varargin{11};
            else
                error('mlAntiRock and mlOpportunisticRefill must be <= mlMaxSinglePump and mlMaxSinglePump must be <= maxPosition')
            end

            if p.mmDiameter<=14.0
                p.volumeScaler=1000;
                p.units='UL';
            else
                p.units='ML';
                p.volumeScaler=1;
            end

        else
            error('mmDiameter, mlPerHour, mlMaxSinglePump, and mlMaxPosition must be strictly positive real numbers')
        end

        if islogical(varargin{4})
            p.doVolChecks=varargin{4};
        else
            error('doVolChecks must be a logical')
        end


        checks={varargin{5},varargin{6},varargin{7}};
        if goodPins(checks)
            p.motorRunningBit = varargin{5};
            p.infTooFarBit = varargin{6};
            p.wdrTooFarBit = varargin{7};
            
            if getDirForPinNum(p.motorRunningBit{2},'read')...
                    && getDirForPinNum(p.infTooFarBit{2},'read')...
                    && getDirForPinNum(p.wdrTooFarBit{2},'read')
                %ok
            else
                error('wrong direction on those pins')
            end            
            
            
        else
            error('motorRunningBit, infTooFarBit, and wdrTooFarBit must be unique {''hexPPortAddr'', int8 pin ID btw 1-17}')
        end

        p = class(p,'pump');

    otherwise
        error('Wrong number of input arguments')
end

ensurePumpStopped(p);
% 
% while 1
%     [infTooFar(p) wdrTooFar(p)]
%     in=input('test\n')
%     if isempty(in)
%         break
%     end
% end