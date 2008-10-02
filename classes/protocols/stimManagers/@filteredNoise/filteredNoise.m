function s=filteredNoise(varargin)
% FILTEREDNOISE  class constructor.
% s = filteredNoise(in)
%
% in.orientations               cell of orientations, one for each correct answer port, in radians, 0 is vertical, positive is clockwise  ex: {-pi/4 [] pi/4}
% in.locationDistributions      cell of 2-d densities, one for each correct answer port, will be normalized to stim area  ex: {[2d] [] [2d]}
%
% in.background                 0-1, normalized
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area
%
% in.patchHeight                0-1, normalized to diagonal of stim area
% in.patchWidth                 0-1, normalized to diagonal of stim area
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window
%
% in.maxWidth
% in.maxHeight
% in.scaleFactor
% in.interTrialLuminance

fieldNames={'orientations','locationDistributions','background','contrast','maskRadius','patchHeight','patchWidth','kernelSize','kernelDuration','loopDuration','ratio','filterStrength','bound'};
for i=1:length(fieldNames)
    s.(fieldNames{i})=[];
end
s.cache=[];
reqNames=union(fieldNames,{'maxWidth','maxHeight','scaleFactor','interTrialLuminance'});

switch nargin
    case 0  % if no input arguments, create a default object
        s = class(s,'filteredNoise',stimManager());
    case 1
        if (isa(varargin{1},'filteredNoise'))	% if single argument of this class type, return it
            s = varargin{1};
        elseif isstruct(varargin{1})    % create object using specified values
            if all(ismember(reqNames,fields(varargin{1})))
                in=varargin{1};

                if isvector(in.orientations) && iscell(in.orientations)
                    pass=true;
                    for i=1:length(in.orientations)
                        pass = pass && isreal(in.orientations{i}) && (isscalar(in.orientations{i}) || isempty(in.orientations{i}));
                    end
                    if ~pass
                        error('each orientation must be real scalar or empty')
                    end
                else
                    error('orientations must be a cell vector')
                end

                if isvector(in.locationDistributions) && iscell(in.locationDistributions) && length(in.locationDistributions) == length(in.orientations)
                    pass=true;
                    for i=1:length(in.locationDistributions)
                        pass=pass && length(size(in.locationDistributions{i}))==2 && isreal(in.locationDistributions{i}) && all(in.locationDistributions{i}(:)>=0);
                    end
                    if ~pass
                        error('each locationDistribution must be 2d real and >=0')
                    end
                else
                    error('locationDistributions must be cell vector of same length as orientations')
                end
                
                if all(cellfun(@isempty,in.orientations)==cellfun(@isempty,in.locationDistributions)) %will barf if these vectors don't have same orientaiton :(
                    %pass
                else
                    error('orientations and locationDistributions must have same empty locations')
                end
                
                norms={in.background in.patchHeight in.patchWidth in.kernelSize in.ratio};
                for i=1:length(norms)
                    if isscalar(norms{i}) && isreal(norms{i}) && norms{i}>=0 && norms{i}<=1
                        %pass
                    else
                        error('background, patchHeight, patchWidth, kernelSize, and ratio must be 0<=x<=1, real scalars') %all but background really want to be strictly >0
                    end
                end

                pos={in.contrast in.maskRadius in.kernelDuration in.loopDuration in.filterStrength};
                for i=1:length(pos)
                    if isscalar(pos{i}) && isreal(pos{i}) && pos{i}>=0
                        %pass
                    else
                        error('contrast, maskRadius, kernelDuration, loopDuration and filterStrength must be real scalars >=0')
                    end
                end
                
                if ~isreal(in.bound) || ~isscalar(in.bound) || in.bound<=.5 || in.bound>=1
                    error('bound must be real scalar .5<x<1')
                end

                for i=1:length(fieldNames)
                    s.(fieldNames{i})=in.(fieldNames{i});
                end
                
                s = class(s,'filteredNoise',stimManager(in.maxWidth,in.maxHeight,in.scaleFactor,in.interTrialLuminance));
            else
                reqNames
                error('input must be struct with all of the above fields')
            end
        else
            error('Input argument is not a filteredNoise object or struct')
        end
    otherwise
        error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);