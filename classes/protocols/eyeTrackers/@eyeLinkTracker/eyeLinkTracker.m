function et=eyeLinkTracker(varargin)
% EYETRACKER claess constructor. ABSTRACT CLASS -- DO NOT INSTANTIATE
% et = eyeLinkTracker()

et.eyeLinkDLL=which('eyeLink'); %not used, just for record keeping
switch nargin
    case 0
        % if no input arguments, create a default object

        et.eyeUsed=[];  %this is a variable that says which eye channel EyeLink is using in software
        %it tends to be left, but is meaningless for our data;  don't want to save it b/c its confusing. 
        
        et = class(et,'eyeLinkTracker',eyeTracker());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'eyeLinkTracker'))
            et = varargin{1};
        elseif islogical(varargin{1})
            et.eyeUsed=[];
            et = class(et,'eyeLinkTracker',eyeTracker(varargin{1}));
        else
            error('Input argument is not a eyeLinkTracker object')
        end
%   case 3
       
    otherwise
        error('Wrong number of input arguments')
end

et=setSuper(et,et.eyeTracker);