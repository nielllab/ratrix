function s=parameterThresholdCriterion(varargin)
% RATECRITERION  class constructor.  
% s=parameterThresholdCriterion(parameterLocation,operator,threshold)
% s=parameterThresholdCriterion('.stimDetails.targetContrast','<',0.1)
% s=parameterThresholdCriterion('.stimDetails.flankerContrast','==',1)

switch nargin
    case 0
        % if no input arguments, create a default object
        s.parameterLocation='';
        s.operator='';
        s.threshold=0;
        s = class(s,'parameterThresholdCriterion',criterion());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'parameterThresholdCriterion'))
            s = varargin{1};
        else
            error('Input argument is not a parameterThresholdCriterion object')
        end
    case 3
        if strcmp(class(varargin{1}),'char')
            s.parameterLocation=varargin{1};
        else
            error('parameterLocation must be a char that is the path to the parameter in the trialrecords')
        end
        
        if any(strcmp(varargin{2},{'<','>','>=','<=','=='}))
            s.operator=varargin{2};
        else
            error('threshold must be ''<'' ''>'' ''>='' ''<='' or ''=='' ')
        end
        
        if isnumeric(varargin{3}) & all(size(varargin{3}==1))
            s.threshold=varargin{3};
        else
            error('threshold must a single number')
        end
        
        s = class(s,'parameterThresholdCriterion',criterion());
    otherwise
        error('Wrong number of input arguments')
end