function s=filteredNoise(varargin)
% FILTEREDNOISE  class constructor.
% s = filteredNoise(in)
%
% in.orientations               cell of orientations, one for each correct answer port, in radians, 0 is vertical, positive is clockwise  ex: {-pi/4 [] pi/4}
% in.locationDistributions      cell of 2-d densities, one for each correct answer port, will be normalized to stim area  ex: {[2d] [] [2d]}
%
% in.distribution               'gaussian', 'binary', 'uniform', or a path to a file name (either .txt or .mat, extension omitted, .txt loadable via load(), and containing a single vector of numbers named 'noise')
% in.origHz                     only used if distribution is a file name, indicating sampling rate of filed
%
% in.background                 0-1, normalized
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area
%
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file instead of a random subset)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window
%
% in.maxWidth
% in.maxHeight
% in.scaleFactor
% in.interTrialLuminance

fieldNames={'orientations','locationDistributions','distribution','origHz','background','contrast','maskRadius','patchDims','patchHeight','patchWidth','kernelSize','kernelDuration','loopDuration','ratio','filterStrength','bound'};
for i=1:length(fieldNames)
    s.(fieldNames{i})=[];
end
s.cache=[];
s.seed={};
s.sha1=[];
s.hz=[];
s.inds=[];
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
                    for i=1:length(in.orientations)
                        if isreal(in.orientations{i}) && (isscalar(in.orientations{i}) || isempty(in.orientations{i}));
                            %pass
                        else
                            error('each orientation must be real scalar or empty')
                        end
                    end
                else
                    error('orientations must be a cell vector')
                end

                if isvector(in.locationDistributions) && iscell(in.locationDistributions) && length(in.locationDistributions) == length(in.orientations)
                    for i=1:length(in.locationDistributions)
                        if ~isempty(in.locationDistributions{i})
                            if length(size(in.locationDistributions{i}))==2 && isreal(in.locationDistributions{i}) && all(in.locationDistributions{i}(:)>=0) && sum(in.locationDistributions{i}(:))>0;
                                %pass
                            else
                                error('each locationDistribution must be 2d real and >=0 with at least one nonzero entry')
                            end
                        end
                    end
                else
                    error('locationDistributions must be cell vector of same length as orientations')
                end

                if ismember(in.distribution,{'uniform','gaussian','binary'})
                    %pass
                elseif isvector(in.distribution) && ischar(in.distribution) && any([exist([in.distribution '.txt'],'file') exist([in.distribution '.mat'],'file')]==2)
                    if isscalar(in.origHz) && in.origHz>0 && isreal(in.origHz)
                        %pass
                    else
                        error('if distribution is file, origHz must be real scalar > 0')
                    end
                else
                    error('distribution must be one of gaussian, uniform, binary, or a string containing a file name (either .txt or .mat, extension omitted, .txt loadable via load())');
                end

                if all(cellfun(@isempty,in.orientations)==cellfun(@isempty,in.locationDistributions)) %will barf if these vectors don't have same orientaiton :(
                    %pass
                else
                    error('orientations and locationDistributions must have same empty locations')
                end

                if all(size(in.patchDims)==[1 2]) && all(in.patchDims)>0 && strcmp(class(in.patchDims),'uint16')
                    %pass
                else
                    error('patchDims should be [height width] uint16 > 0')
                end

                norms={in.background in.patchHeight in.patchWidth in.kernelSize in.ratio};
                for i=1:length(norms)
                    if isscalar(norms{i}) && isreal(norms{i}) && norms{i}>0 && norms{i}<=1
                        %pass
                    else
                        if i==1 && in.background==0
                            %pass
                        elseif i==4 && in.kernelSize==0
                            %pass
                        else
                            error('background, patchHeight, patchWidth, kernelSize, and ratio must be 0<x<=1, real scalars (exception: background and kernelSize can be 0, zero kernelSize means no spatial extent beyond 1 pixel (may still have kernelDuration>0))')
                        end
                    end
                end

                pos={in.contrast in.maskRadius in.kernelDuration in.loopDuration in.filterStrength};
                for i=1:length(pos)
                    if isscalar(pos{i}) && isreal(pos{i}) && pos{i}>=0
                        %pass
                    else
                        error('contrast, maskRadius, kernelDuration, loopDuration and filterStrength must be real scalars >=0 (zero loopDuration means 1 static looped frame, except for file stims, where it means play the whole file instead of a subset)')
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