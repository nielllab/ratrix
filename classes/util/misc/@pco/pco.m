function p = pco(varargin)
% PCO class constructor.
% p=pco(addr, trig, busy, rate, n)
%   addr = hex address of parallel port
%   trig = pin num for trig
%   busy = pin num for busy
%   rate = hz for exposures
%   n = max num exposures

%copy this style for future object constructors

%default field values
p.addr = '0378';
p.trig = 7;
p.busy = 15;
p.rate = 30;
p.n    = 100;

pFields = fields(p);

switch nargin
    case 0
        % create a default object
    case 1
        if (isa(varargin{1},'pco'))
            p = varargin{1};
            return
        elseif isstruct(varargin{1})
            fs = fields(varargin{1});
            if ~all(ismember(fs,pFields))
                error('struct must only contain specified fields')
            end
            for i=1:length(fs) %any vectorized way to do this?
                f = fs{i};
                p.(f) = varargin{1}.(f);
            end
            cellfun(@(f)validate(p,f),pFields);
        else
            error('argument not a pco object or param struct')
        end
    otherwise
        nargin
        error('bad number of arguments')
end

%cross-field constraints
if p.trig == p.busy
    error('trig and busy must differ')
end

%conversion to internal representation
p.addr = hex2dec(p.addr);
p.trig = uint8(p.trig);
p.busy = uint8(p.busy);
p.rate = 1/p.rate;

%init
p.slowChecks = false;
p.record = [];
p.ind = [];

p = class(p,'pco');

    function validate(s,f)
        if ~isfield(s,f)
            f
            error('must have field')
        else
            v = s.(f);
        end
        
        switch f
            case 'addr'
                if bad(v,{@ischar @isvector @(x)size(x,1)==1})
                    error('addr must be single hex string')
                end
            case {'trig' 'busy'}
                checkPinNum(v);
                switch f
                    case 'trig'
                        dir = 'write';
                    case 'busy'
                        dir = 'read';
                    otherwise
                        error('huh')
                end
                if ~getDirForPinNum(v,dir)
                    error('bad pin dir')
                end
            case 'rate'
                if bad(v,{@isreal @isnumeric @isscalar @(x)~isnan(x) @(x)x>=0})
                    error('bad rate')
                end
            case 'n'
                if bad(v,{@isreal @isnumeric @isscalar @isfinite @(x)x>=0 @(x)mod(x,1)==0})
                    error('bad n')
                end
            otherwise
                error('huh')
        end
    end

    function checkPinNum(v)
        if bad(v,{@isreal @isnumeric @isscalar @(x)x>0 @(x)x<=17 @(x)mod(x,1)==0})
            error('bad pin num')
        end
    end

    function out = bad(in,check)
        out = ~all(cellfun(@(fn)fn(in),check));
    end
end