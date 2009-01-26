function et=eyeLinkTracker(varargin)
% EYETRACKER claess constructor. ABSTRACT CLASS -- DO NOT INSTANTIATE
% et = eyeLinkTracker()

%all verisons and defaults init same fields

et.eyeLinkDLL=which('eyeLink'); %not used, just for record keeping
et.eyeUsed=[];  %this is a variable that says which eye channel EyeLink is using in software
%it tends to be left, but is meaningless for our data;  don't want to save it b/c its confusing.

switch nargin
    case 0
        % if no input arguments, create a default object  
        et = class(et,'eyeLinkTracker',eyeTracker());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'eyeLinkTracker'))
            et = varargin{1};
        else
            error('Input argument is not a eyeLinkTracker object')
        end
   case 2
        et = class(et,'eyeLinkTracker',eyeTracker(varargin{1},varargin{2}));
    otherwise
        error('Wrong number of input arguments')
end
