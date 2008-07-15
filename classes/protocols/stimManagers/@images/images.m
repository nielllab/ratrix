function s=images(varargin)
% IMAGES  class constructor.
% s = images(directory,yPositionPercent,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution)
% yPositionPercent (0 <= value <= 1), in normalized units of the diagonal of the stim region
% trialDistribution in format { { {imagePrefixN imagePrefixP} .1}...
%                               { {imagePrefixP imagePrefixM} .9}...
%                             }
% first image listed for each trial is correct answer
% trial chosen according to probabilities provided (will be normalized)
% image names should not include path or extension
% images must reside in directory indicated and be .png's with alpha channels

s.directory = '';
s.background=0;
s.yPositionPercent=0;
s.cache=[];
s.trialDistribution={};

switch nargin
    case 0
        % if no input arguments, create a default object

        s = class(s,'images',stimManager());

    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'images'))
            s = varargin{1};
        else
            error('Input argument is not an images object')
        end
    case 8
        % create object using specified values

        if ischar(varargin{1})
            s.directory=varargin{1};
            try
                d=isdir(s.directory); % may fail due to windows networking/filesharing bug, but unlikely at construction time
            catch
                error('can''t load that directory')
            end
        else
            error('directory must be fully resolved string')
        end

        if isreal(varargin{2}) && isscalar(varargin{2}) && varargin{2}>=0 && varargin{2}<=1
            s.yPositionPercent=varargin{2};
        else
            error('yPositionPercent must be real scalar 0<=yPositionPercent<=1')
        end

        if isreal(varargin{3}) && isscalar(varargin{3}) && varargin{3}>=0 && varargin{3}<=1
            s.background=varargin{3};
        else
            error('background must be real scalar 0<=background<=1')
        end

        if iscell(varargin{8}) && isvector(varargin{8}) && ~isempty(varargin{8})
            valid=true;
            for i=1:length(varargin{8})
                entry=varargin{8}{i};
                if ~all(size(entry)==[1 2]) || ~iscell(entry) || ~iscell(entry{1}) || ~isvector(entry{1}) ...
                        || ~all(cellfun(@ischar,entry{1})) ||~all(cellfun(@isvector,entry{1})) ...
                        || ~isscalar(entry{2}) || ~isreal(entry{2}) || ~(entry{2}>=0)

                    entry
                    entry{1}
                    entry{2}

                    valid=false;
                    break
                end
            end

            if valid
                s.trialDistribution=varargin{8};
            else
                error('cell entries in trialDistribution must be 1x2 cells of format {imagePrefixN imagePrefixP} prob}')
            end
        else
            error('trialDistribution must be nonempty vector cell array')
        end

        s = class(s,'images',stimManager(varargin{4},varargin{5},varargin{6},varargin{7}));

        validateImages(s); %error if can't load images or bad format

    otherwise
        error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);