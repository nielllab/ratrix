function z=zone(varargin)
% ZONE  class constructor.
% z = zone(rezSensorBit,reservoirValveBit,toStationsValveBit,fillRezValveBit,valveDelay,equalizeDelay)

z.rezSensorBit = {};
z.reservoirValveBit = {};
z.toStationsValveBit = {};
z.fillRezValveBit = {};
z.valveDelay = 0; % How long to wait after changing the valve state
z.equalizeDelay = 0; % How long to wait to equalize pressure

z.const.valveOff = int8(0);
z.const.valveOn = int8(1);
z.const.sensorBlocked = int8(0);%'0';

switch nargin
    case 0
        % if no input arguments, create a default object
        z = class(z,'zone');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'zone'))
            z = varargin{1};
        else
            error('Input argument is not a zone object')
        end

    case 6
        % create object using specified values
        
        checks={varargin{1},varargin{2},varargin{3},varargin{4}};
        if goodPins(checks)
            z.rezSensorBit = varargin{1};
            z.reservoirValveBit = varargin{2};
            z.toStationsValveBit = varargin{3};
            z.fillRezValveBit = varargin{4};
            
            if strcmp(getDirForPinNum(z.rezSensorBit{2}),'read')...
                    && strcmp(getDirForPinNum(z.reservoirValveBit{2}),'write')...
                    && strcmp(getDirForPinNum(z.toStationsValveBit{2}),'write')...
                    && strcmp(getDirForPinNum(z.fillRezValveBit{2}),'write')
                %ok
            else
                error('wrong direction on those pins')
            end
            
        else
            error('rezSensorBit, reservoirValveBit, toStationsValveBit, and fillRezValveBit must be unique {''hexPPortAddr'', int8 pin ID btw 1-17}')
        end        

        if all([varargin{5} varargin{6}]>=0) && all(isnumeric([varargin{5} varargin{6}])) && all(isreal([varargin{5} varargin{6}]))
            z.valveDelay = varargin{5};
            z.equalizeDelay = varargin{6};
        else
            error('valveDelay and equalizeDelay must be real numbers >= 0')
        end


        z = class(z,'zone');

    otherwise
        error('Wrong number of input arguments')
end
closeAllValves(z);