function s=ball(varargin)
% BALL  class constructor.
% s = ball(in, maxWidth, maxHeight, scaleFactor, interTrialLuminance)

s.initialPos=nan;
s.mouseIndices=nan;

switch nargin
    case 0  % if no input arguments, create a default object
        s = class(s,'ball',stimManager());
    case 1
        if (isa(varargin{1},'ball'))	% if single argument of this class type, return it
            s = varargin{1};
        else
            error('Input argument is not a ball object')
        end
    case 5
        %s = varargin{1};
        
        s = class(s,'ball',stimManager(varargin{2},varargin{3},varargin{4},varargin{5}));
    otherwise
        error('Wrong number of input arguments')
end