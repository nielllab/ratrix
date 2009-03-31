function s=filteredNoise(varargin)
% FILTEREDNOISE  class constructor.
% s = filteredNoise(in,maxWidth, maxHeight, scaleFactor, interTrialLuminance)
%
% in is a struct array with one entry for each correct answer port:
% in.port                       1x1 integer denoting correct port for the parameters specified in this entry ("column") in the struct array
%
% stim properties:
% in.distribution               'binary', 'uniform', or one of the following forms:
%                                   {'sinusoidalFlicker',[temporalFreqs],[contrasts],gapSecs} - each freq x contrast combo will be shown for equal time in random order, total time including gaps will be in.loopDuration
%                                   {'gaussian',clipPercent} - choose variance so that clipPercent of an infinite stim would be clipped (includes both low and hi)
%                                   {path, origHz, clipVal, clipType} - path is to a file (either .txt or .mat, extension omitted, .txt loadable via load()) containing a single vector of stim values named 'noise', with original sampling rate origHz.
%                                       clipType:
%                                       'normalized' will normalize whole file to clipVal (0-1), setting darkest val in file to 0 and values over clipVal to 1.
%                                       'ptile' will normalize just the contiguous part of the file you are using to 0-1, clipping top clipVal (0-1) proportion of vals (considering only the contiguous part of the file you are using)
% in.startFrame                 'randomize' or integer indicating fixed frame number to start with
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file)
%                               to make uniques and repeats, pass {numRepeats numUniques numCycles chunkSeconds} - chunk refers to one repeat/unique - distribution cannot be sinusoidalFlicker
% in.numLoops                   must be >0 or inf, fractional values ok (will be rounded to nearest frame)
%
% patch properties:
% in.locationDistribution       2-d density, will be normalized to stim area
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.background                 0-1, normalized (luminance outside patch)
%
% filter properties:
% in.orientation                filter orientation in radians, 0 is vertical, positive is clockwise
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window

fieldNames={'port','distribution','startFrame','loopDuration','numLoops','locationDistribution','maskRadius','patchDims','patchHeight','patchWidth','background','orientation','kernelSize','kernelDuration','ratio','filterStrength','bound'};
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
                if isvector(in.distribution) && ischar(in.distribution) && ismember(in.distribution,{'uniform','binary'})
                    %pass
                elseif iscell(in.distribution)
                    tmp.special=in.distribution{1};
                    if all(size(in.distribution)==[1 4]) && strcmp(tmp.special,'sinusoidalFlicker')
                        tmp.freqs=in.distribution{2};
                        tmp.contrasts=in.distribution{3};
                        tmp.gapSecs=in.distribution{4};
                        if isvector(tmp.freqs) && isreal(tmp.freqs) && isnumeric(tmp.freqs) && all(tmp.freqs>=0) && ...
                                isvector(tmp.contrasts) && isreal(tmp.contrasts) && isnumeric(tmp.contrasts) && all(tmp.contrasts>=0) && all(tmp.contrasts<=1) && ...
                                isscalar(tmp.gapSecs) && isreal(tmp.gapSecs) && isnumeric(tmp.gapSecs) && tmp.gapSecs>=0
                            isSinusoidalFlicker=true;
                        else
                            error('temporalFreqs and contrasts must be real numeric vectors >=0, contrasts must be <=1, gapSecs must be real numeric scalar >=0')
                        end
                    elseif all(size(in.distribution)==[1 2]) && strcmp(tmp.special,'gaussian')
                        tmp.clipPercent=in.distribution{2};
                        
                        if isscalar(tmp.clipPercent) && tmp.clipPercent>=0 && tmp.clipPercent<=1 && isreal(tmp.clipPercent)
                            %pass
                        else
                            error('clipPercent must be real scalar 0<=x<=1')
                        end

                    elseif all(size(in.distribution)==[1 4]) && ismember(in.distribution{4},{'ptile','normalized'}) && any([exist([tmp.special '.txt'],'file') exist([tmp.special '.mat'],'file')]==2)
                        tmp.origHz=in.distribution{2};
                        tmp.clipVal=in.distribution{3};
                        tmp.clipType=in.distribution{4};
                                                
                        if isscalar(tmp.origHz) && tmp.origHz>0 && isreal(tmp.origHz) && isfloat(tmp.origHz)
                            %pass
                        else
                            error('origHz must be real float scalar > 0')
                        end
                        
                        if isscalar(tmp.clipVal) && tmp.clipVal>=0 && tmp.clipVal<=1 && isreal(tmp.clipVal)
                            %pass
                        else
                            error('clipVal must be real scalar 0<=x<=1')
                        end
                    else
                        error('cell vector distribution must be one of {''gaussian'',clipPercent},  {''sinusoidalFlicker'',[temporalFreqs],[contrasts],gapSecs}, {filePath, origHz, clipVal, clipType} (filePath a string containing a file name (either .txt or .mat, extension omitted, .txt loadable via load()), clipType in {''ptile'',''normalized''}')
                    end
                    varargin{1}(j).distribution=tmp;
                else
                    in.distribution
                    error('distribution must be one of ''uniform'', ''binary'', or a cell vector')
                end

                if isscalar(in.loopDuration) && isreal(in.loopDuration) && in.loopDuration>=0
                    %pass
                elseif iscell(in.loopDuration) && isvector(in.loopDuration) && all(size(in.loopDuration)==[1 4]) && ~isSinusoidalFlicker
                    tmp.numRepeats = in.loopDuration{1};
                    tmp.numUniques = in.loopDuration{2};
                    tmp.numCycles =  in.loopDuration{3};
                    tmp.chunkSeconds =  in.loopDuration{4};
                    if isscalar(tmp.numRepeats) && isinteger(tmp.numRepeats) && tmp.numRepeats>=0 && ...
                            isscalar(tmp.numUniques) && isinteger(tmp.numUniques) && tmp.numUniques>=0 && ...
                            isscalar(tmp.numCycles) && isinteger(tmp.numCycles) && tmp.numCycles>0 && ...
                            isscalar(tmp.chunkSeconds) && isreal(tmp.chunkSeconds) && isnumeric(tmp.chunkSeconds) && tmp.chunkSeconds>0
                        %convert to doubles to avoid int overflow issues when used in computeFilteredNoise
                        tmp.numRepeats = double(tmp.numRepeats);
                        tmp.numUniques = double(tmp.numUniques);
                        tmp.numCycles =  double(tmp.numCycles);
                        tmp.chunkSeconds =  double(tmp.chunkSeconds);
                        varargin{1}(j).loopDuration=tmp;
                    else
                        error('numRepeats and numUniques must be scalar integers >=0, numCycles must be scalar integer >0, and chunkSeconds must be scalar numeric real >0')
                    end
                else
                    error('loopDuration must be real scalar >=0, zero loopDuration means 1 static looped frame, except for file stims, where it means play the whole file instead of a subset. to make uniques and repeats, pass {numRepeats numUniques numCycles chunkSeconds} - chunk refers to one repeat/unique - distribution cannot be sinusoidalFlicker')
                end

                if in.numLoops>0 && isscalar(in.numLoops) && isreal(in.numLoops)
                    %pass
                else
                    error('numLoops must be >0 real scalar or inf')
                end
                
                if isreal(in.maskRadius) && isscalar(in.maskRadius)
                    %pass
                else
                    error('maskRadius must be real scalar')
                end
                
                pos={in.kernelDuration in.filterStrength};
                for i=1:length(pos)
                    if isscalar(pos{i}) && isreal(pos{i}) && pos{i}>=0
                        %pass
                    else
                        error('kernelDuration and filterStrength must be real scalars >=0')
                    end
                end


                norms={in.background in.patchHeight in.patchWidth in.kernelSize in.ratio};
                goodNorms=true;
                for i=1:length(norms)
                    if isscalar(norms{i}) && isreal(norms{i}) && norms{i}<=1
                        if norms{i}>0
                            %pass
                        else
                            if i==1 && in.background==0
                                %pass
                            elseif i==4 && in.kernelSize==0
                                %pass
                            else
                                goodNorms=false;
                            end
                        end
                    else
                        goodNorms=false;
                    end
                end
                if ~goodNorms
                    error('background, patchHeight, patchWidth, kernelSize, and ratio must be 0<x<=1, real scalars (exception: background and kernelSize can be 0, zero kernelSize means no spatial extent beyond 1 pixel (may still have kernelDuration>0))')
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
            required=fieldNames'
            have=fields(varargin{1})
            setdiff(required,have)
            error('input must be struct with all of the above fields')

        end
    otherwise
        error('Wrong number of input arguments')
end