function s=pumpSystem(varargin)
% PUMPSYSTEM  class constructor.
% s = pumpSystem(pump,{cell array of zones})

if ~ispc
    error('pump systems only supported on pc')
end

s.pump=[];
s.zones={};
s.lastZone=0;
s.needsAntiRock=true;

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'pumpSystem');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'pumpSystem'))
            s = varargin{1};
        else
            error('Input argument is not a pumpSystem object')
        end

    case 2
        % create object using specified values

        if isa(varargin{1},'pump')
            s.pump=varargin{1};
        else
            error('pump must be a pump')
        end

        bits=getBits(s.pump);
        putativeZones=varargin{2};
        for i=1:length(putativeZones)
            if ~isa(putativeZones{i},'zone')
                error('all zones must be zones')
            else
                s.zones{i}=putativeZones{i};
                newBits=getBits(s.zones{i});
                for j=1:length(newBits)
                    bits{end+1}=newBits{j};
                end
            end

        end

        if ~goodPins(bits)
            error('zones and pump must not contain any identical valve or sensor bits')
        end

        s = class(s,'pumpSystem');

    otherwise
        error('Wrong number of input arguments')
end

closeAllValves(s);