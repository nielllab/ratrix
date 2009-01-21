function s=receptiveFieldCriterion(varargin)
% RECEPTIVEFIELDCRITERION  class constructor.  
% s=receptiveFieldCriterion(alpha,dataRecordsPath,numberSpotsAllowed)
%   alpha - confidence bounds for receptive field
%   dataRecordsPath - path for spikeRecords and stimRecords files
%   numberSpotsAllowed - number of spots allowed on the denoised receptive field to be eligible for graduation

switch nargin
    case 0
        % if no input arguments, create a default object
        s.alpha = 0.05;
        s.dataRecordsPath = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\Fan\datanet';
        s.numberSpotsAllowed = 1;
        s = class(s,'receptiveFieldCriterion',criterion());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'receptiveFieldCriterion'))
            s = varargin{1};
        else
            error('Input argument is not a receptiveFieldCriterion object')
        end
    case 2
        % alpha
        if isscalar(varargin{1})
            s.alpha = varargin{1};
        else
            error('alpha must be a scalar');
        end
        % dataRecordsPath
        if ischar(varargin{2}) && isdir(varargin{2})
            s.dataRecordsPath = varargin{2};
        else
            error('dataRecordsPath must be a valid directory');
        end
        % numberSpotsAllowed
        if isscalar(varargin{3})
            s.numberSpotsAllowed = varargin{3};
        else
            error('numberSpotsAllowed must be a scalar');
        end
    otherwise
        error('Wrong number of input arguments')
end
