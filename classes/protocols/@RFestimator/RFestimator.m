function RFe = RFestimator(varargin)
% RFestimator constructor
%
% RFe = RFestimator(centerParams,boundaryParams,eyeParams,dataSource,dateRange)
%
% centerParams - a cell array of {stimClass,method,params} used by getCenter
% boundaryParams - a cell array of {stimClass,method,params} used by getBoundary
%
% stimClass - the type of stimulus used to induce a RF (eg 'whiteNoise')
% method - method for estimating the receptive field (eg 'centerOfMass', 'significantCoherence', 'fitGaussian')
% params - method-specific estimation parameters as a cell array
% eyeParams - cell array of eye parameters, empty for now
% dataSource - the path to the analysis files (always set to datanet_storage/) - this should not include ...demo1/analysis
%(pmm: b/c we have to adapt to different subjects!) (fan:because we look there in the call to getNeuralAnalysis)
% dateRange - range of dates within which to look for analysis results
%
% from phil:
% always gets the most recent analysis result within RFestimator.dateRange
% phys setup will choose dateRange=[floor(now) Inf] to specify today
% centerDataSource='whiteNoise'; (%could be other stuff)
%
% centerParameters= {dataSource,method,params}
% ie. {'whiteNoise','centerOfMass',{
% alphaSignificantPixels medianFilter}}
% boundaryParameters=  {dataSource,method,params}
% ie. {'gratings','significantCoherence',alpha}
% or {'gratings','ttestF1',pThresh}
% or {'whiteNoise','fitGaussian',{medianFilter nStd2Bound}}
% eyeParameters= []; % for now
% methods: getCenter and getOuterRadiusBound
% if fitGaussian, use the tools i started to prototype in fitRF=0 in the ifFeature calcStim, but these are not the final methods at all. lets review choices once its functional.  feel free to make changes & explain why.
%
%
% if there is no RF estimate available in that range, error.
% %how can we do this more gracefully...? its a costly and plausible mistake...
%
% set gratings to accept RFestimator object instead of  position
% (then call getCenter on the object once on first trial to cache the values)
% function: sweep multiple anuli over center of RF
%
% set gratings to accept RFestimator object instead of annulus radius, and call getOuterRadiusBound to cache it
%
%example test use:
%path='\\132.239.158.183\rlab_storage\pmeier\backup\devNeuralData_090310\'
% rf=RFestimator({'whiteNoise','fitGaussian',{2}},{'gratings','ttestF1',{0.03,'fft'}},[],path,[now-100 Inf]); x=getCenter(rf,'g')

RFe.centerParams=[];
RFe.boundaryParams=[];
RFe.eyeParams=[];
RFe.dataSource=[];
RFe.dateRange=[];

RFe.cache=[];

switch nargin
    case 0
        error('default object construction not allowed for RFestimator');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'RFestimator'))
            RFe = varargin{1};
        else
            error('single argument must be a RFestimator object');
        end
    case 5
        % centerParams
        if iscell(varargin{1}) && length(varargin{1})==3
            RFe.centerParams=varargin{1};
        else
            error('centerParams must be a cell array of length 3');
        end
        % boundaryParams
        if iscell(varargin{2}) && length(varargin{2})==3
            RFe.boundaryParams=varargin{2};
        else
            error('boundaryParams must be a cell array of length 3');
        end
        
        % check centerParams
        if ~ischar(RFe.centerParams{1})
            error('centerParams stimClass must be a string');
        end
        if ~iscell(RFe.centerParams{3}) && ~isempty(RFe.centerParams{3})
            error('centerParams params must be a cell array or empty');
        else
            p=RFe.centerParams{3}; % dynamic params
        end
        
        switch RFe.centerParams{1}
            case 'whiteNoise'
                switch RFe.centerParams{2}
                    case 'centerOfMass'
                        if ~isempty(p)
                            error('no parameters for centerOfMass, use empty set')
                        end
                    case 'fitGaussian'
                        if ~(length(p)==1 & p{1}>0 & p{1}<10)
                            error('first parameter must be a std threshold between 0 and 10')
                        end
                    case 'fitGaussianSigEnvelope'
                        isMedianFilter=( (all(size(p{3})==[3 3]) && islogical(p{3})) || (ischar(p{3}) && ismember(p{3},{'box','cross'})));
                        if ~(length(p)==3 & p{1}>0 & p{1}<10 & p{2}>0 & p{2}<1 & isMedianFilter)
                            p
                            std=p{1}
                            alpha=p{2}
                            medianFilter=p{3}
                            isMedianFilter
                            error('first parameter must be a std threshold between 0 and 10, second parameter must be an alpha between 0 and 1, third parameter must be a median filter: either a size 3 logical or ''box'' or ''cross''')
                        end
                    otherwise
                        error(sprintf('%s is a bad method for %s',RFe.centerParams{2},RFe.centerParams{1}))
                end
            case 'gratings'
                error('no gratings center method exists')
        end
        
        
        % check boundaryParams
        if ~ischar(RFe.boundaryParams{1})
            error('boundaryParams stimClass must be a string');
        end
        if ~iscell(RFe.boundaryParams{3}) && ~isempty(RFe.boundaryParams{3})
            error('boundaryParams params must be a cell array or empty');
        else
            p=RFe.boundaryParams{3}; % dynamic params
        end
        
        switch RFe.boundaryParams{1}
            case 'whiteNoise'
                switch RFe.boundaryParams{2}
                    case 'centerOfMass'
                        error('not allowed for the boundary method')
                    case 'fitGaussian'
                        if ~(length(p)==1 & p{1}>0 & p{1}<10)
                            error('first parameter must be a std threshold between 0 and 10')
                        end
                    case 'fitGaussianSigEnvelope'
                        isMedianFilter=( (all(size(p{3})==[3 3]) && islogical(p{3})) || (ischar(p{3}) && ismember(p{3},{'box','cross'})))
                        if ~(length(p)==3 & p{1}>0 & p{1}<10 & p{2}>0 & p{2}<1 & isMedianFilter)
                            p
                            std=p{1}
                            alpha=p{2}
                            medianFilter=p{3}
                            isMedianFilter
                            error('first parameter must be a std threshold between 0 and 10, second parameter must be an alpha between 0 and 10, third parameter must be a median filter: either a size 3 logical or ''box'' or ''cross''')
                        end
                    otherwise
                        error(sprintf('%s is a bad method for %s',RFe.centerParams{2},RFe.centerParams{1}))
                end
            case 'gratings'
                switch RFe.boundaryParams{2}
                    case 'significantCoherence'
                        error('not yet')
                    case 'ttestF1'
                        if ~(p{1}>0 && p{1}<1)
                            p{1}
                            error('must be alpha between 0 and 1')
                        end
                        switch p{2}
                            case 'fft'
                            otherwise
                                p{2}
                                error('must choose frequency estimation method')
                        end
                    otherwise
                        error(sprintf('%s is a bad method for %s',RFe.centerParams{2},RFe.centerParams{1}))
                end
        end
        
        % eyeParams
        if iscell(varargin{3}) || isempty(varargin{3})
            RFe.eyeParams=varargin{3};
        else
            error('eyeParams must be a cell array or empty');
        end
        
        if ~isempty(varargin{4}) && ischar(varargin{4}) && isdir(varargin{4})
            RFe.dataSource=varargin{4};
        else
            error('dataSource must be a valid directory path');
        end
        % dateRange
        if isvector(varargin{5}) && isnumeric(varargin{5}) && length(varargin{5})==2 && varargin{5}(1)<=varargin{5}(2)
            RFe.dateRange=varargin{5};
        else
            error('dateRange must be a 2-element vector specifying a valid range')
        end
        
        RFe=class(RFe,'RFestimator');
        
    otherwise
        error('unsupported number of input arguments');
end

end % end function

