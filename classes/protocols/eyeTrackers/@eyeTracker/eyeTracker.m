function et=eyeTracker(varargin)
% EYETRACKER claess constructor. ABSTRACT CLASS -- DO NOT INSTANTIATE
% et = eyeTracker(requiresCalibration, isCalibrated, isTracking)
switch nargin
    case 0
        % if no input arguments, create a default object
        et.requiresCalibration=[];
        et.isCalibrated=[];
        et.isTracking=[];
        et.eyeDataPath=[];
        et.sessionFileName=[];
        et = class(et,'eyeTracker',structable());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'eyeTracker'))
            et = varargin{1};
        elseif islogical(varargin{1})
            et.requiresCalibration=varargin{1};
            %             else
            %                 error('must be logical');
            %             end

            if et.requiresCalibration
                et.isCalibrated=false;
            else
                et.isCalibrated=true;
            end

            et.isTracking=false;
            et.eyeDataPath=[];     %this is set at run-time by initialize
            et.sessionFileName=[]; %this is set at run-time by start
            et = class(et,'eyeTracker',structable());
        else
            error('Input argument is not a eyeTracker object')
        end
        %     case 3


    otherwise
        error('Wrong number of input arguments')
end

et=setSuper(et,et.structable);