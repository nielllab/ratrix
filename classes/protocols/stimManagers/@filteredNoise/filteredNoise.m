function s=filteredNoise(varargin)
% FILTEREDNOISE  class constructor.
% s = filteredNoise(in,maxWidth, maxHeight, scaleFactor, interTrialLuminance)
%
% in is a struct array with one entry for each correct answer port:
% in.port                       1x1 integer denoting correct port for the parameters specified in this entry ("column") in the struct array
%
% stim properties:
% in.distribution               'gaussian', 'binary', 'uniform', or a path to a file name (either .txt or .mat, extension omitted, .txt loadable via load(), and containing a single vector of numbers named 'noise')
%                               distribution can also be cell array of following form: {'sinusoidalFlicker',[temporalFreqs],[contrasts],gapSecs} - each freq x contrast combo will be shown for equal time in random order, total time including gaps will be in.loopDuration
% in.origHz                     only used if distribution is a file name, indicating sampling rate of file
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.startFrame                 'randomize' or integer indicating fixed frame number to start with
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file)
%                               to make uniques and repeats, pass {numRepeatsPerUnique numCycles cycleDurSeconds} - a cycle is a whole set of repeats and one unique - distribution cannot be sinusoidalFlicker 
%
% patch properties:
% in.locationDistribution       2-d density, will be normalized to stim area
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.background                 0-1, normalized
%
% filter properties:
% in.orientation                filter orientation in radians, 0 is vertical, positive is clockwise
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window

fieldNames={'port','distribution','origHz','contrast','startFrame','loopDuration','locationDistribution','maskRadius','patchDims','patchHeight','patchWidth','background','orientation','kernelSize','kernelDuration','ratio','filterStrength','bound'};
for i=1:length(fieldNames)
    s.(fieldNames{i})=[];
end
s.cache={};
s.seed={};
s.sha1={};
s.hz=[];
s.inds={};

switch nargin
    case 0  % if no input arguments, create a default object
        s = class(s,'filteredNoise',stimManager());
    case 1
        if (isa(varargin{1},'filteredNoise'))	% if single argument of this class type, return it
            s = varargin{1};
        else
            error('Input argument is not a filteredNoise object')
        end
    case 5
        if isstruct(varargin{1})  &&   all(ismember(fieldNames,fields(varargin{1})))  % create object using specified values

            for j=1:length(varargin{1})
                in=varargin{1}(j);

                if isinteger(in.port) && in.port>0 && isscalar(in.port)
                    %pass
                else
                    error('port must be scalar positive integer')
                end


                if isreal(in.orientation) && isscalar(in.orientation)
                    %pass
                else
                    error('orientation must be real scalar')
                end

                if (isscalar(in.startFrame) && isinteger(in.startFrame) && in.startFrame>0)
                    varargin{1}(j).startFrame=uint32(in.startFrame); %otherwise our frame indices can't exceed the max of the datatype of the startframe, and there's no colon operator on uint64...
                elseif strcmp(in.startFrame,'randomize')
                    %pass
                else
                    error('start frame must be scalar integer >0 or ''randomize''')
                end
                
                isSinusoidalFlicker=false;
                if isvector(in.distribution) && ischar(in.distribution)
                    if ismember(in.distribution,{'uniform','gaussian','binary'})
                        %pass
                    elseif any([exist([in.distribution '.txt'],'file') exist([in.distribution '.mat'],'file')]==2)
                        if isscalar(in.origHz) && in.origHz>0 && isreal(in.origHz)
                            %pass
                        else
                            error('if distribution is file, origHz must be real scalar > 0')
                        end
                    end
                elseif iscell(in.distribution) && all(size(in.distribution)==[1 4]) && strcmp(in.distribution{1},'sinusoidalFlicker')
                    tmp.special=in.distribution{1};
                    tmp.freqs=in.distribution{2};
                    tmp.contrasts=in.distribution{3};
                    tmp.gapSecs=in.distribution{4};
                    if isvector(tmp.freqs) && isreal(tmp.freqs) && isnumeric(tmp.freqs) && all(tmp.freqs>=0) && ...
                            isvector(tmp.contrasts) && isreal(tmp.contrasts) && isnumeric(tmp.contrasts) && all(tmp.contrasts>=0) && all(tmp.contrasts<=1) && ...
                            isscalar(tmp.gapSecs) && isreal(tmp.gapSecs) && isnumeric(tmp.gapSecs) && tmp.gapSecs>=0
                        varargin{1}(j).distribution=tmp;
                        isSinusoidalFlicker=true;
                    else
                        error('temporalFreqs and contrasts must be real numeric vectors >=0, contrasts must be <=1, gapSecs must be real numeric scalar >=0')
                    end
                else
                    error('distribution must be one of gaussian, uniform, binary, or a string containing a file name (either .txt or .mat, extension omitted, .txt loadable via load()), or  {''sinusoidalFlicker'',[temporalFreqs],[contrasts],gapSecs}');
                end

                
                
                if isscalar(in.loopDuration) && isreal(in.loopDuration) && in.loopDuration>=0
                    %pass
                elseif iscell(in.loopDuration) && isvector(in.loopDuration) && all(size(in.loopDuration)==[1 3]) && ~isSinusoidalFlicker
                    tmp.numRepeatsPerUnique = in.loopDuration{1};
                    tmp.numCycles =  in.loopDuration{2};
                    tmp.cycleDurSeconds =  in.loopDuration{3};
                    if isscalar(tmp.numRepeatsPerUnique) && isinteger(tmp.numRepeatsPerUnique) && tmp.numRepeatsPerUnique>=0 && ...
                            isscalar(tmp.numCycles) && isinteger(tmp.numCycles) && tmp.numCycles>0 && ...
                            isscalar(tmp.cycleDurSeconds) && isreal(tmp.cycleDurSeconds) && isnumeric(tmp.cycleDurSeconds) && tmp.cycleDurSeconds>0
                        varargin{1}(j).loopDuration=tmp;
                    else
                        error('numRepeatsPerUnique must be scalar integer >=0, numCycles must be scalar integer >0, and cycleDurSeconds must be scalar numeric real >0')
                    end
                else
                    error('loopDuration must be real scalar >=0, zero loopDuration means 1 static looped frame, except for file stims, where it means play the whole file instead of a subset.  to make uniques and repeats, pass {numRepeatsPerUnique numCycles cycleDurSeconds} - a cycle is a whole set of repeats and one unique - distribution cannot be sinusoidalFlicker')
                end
                
                pos={in.contrast in.maskRadius in.kernelDuration in.filterStrength};
                for i=1:length(pos)
                    if isscalar(pos{i}) && isreal(pos{i}) && pos{i}>=0
                        %pass
                    else
                        error('contrast, maskRadius, kernelDuration, and filterStrength must be real scalars >=0')
                    end
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


                if length(size(in.locationDistribution))==2 && isreal(in.locationDistribution) && all(in.locationDistribution(:)>=0) && sum(in.locationDistribution(:))>0
                    %pass
                else
                    error('locationDistribution must be 2d real and >=0 with at least one nonzero entry')
                end


                if all(size(in.patchDims)==[1 2]) && all(in.patchDims)>0 && strcmp(class(in.patchDims),'uint16')
                    %pass
                else
                    error('patchDims should be [height width] uint16 > 0')
                end


                if ~isreal(in.bound) || ~isscalar(in.bound) || in.bound<=.5 || in.bound>=1
                    error('bound must be real scalar .5<x<1')
                end


            end

            in=varargin{1};

            for i=1:length(fieldNames)
                s.(fieldNames{i})={in.(fieldNames{i})};
            end

            s = class(s,'filteredNoise',stimManager(varargin{2},varargin{3},varargin{4},varargin{5}));
        else
            fieldNames
            error('input must be struct with all of the above fields')

        end
    otherwise
        error('Wrong number of input arguments')
end