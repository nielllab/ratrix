function s=images(varargin)
% IMAGES  class constructor.
% s = images(directory,yPositionPercent,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,...
%   trialDistribution,imageSelectionMode,size,sizeyoked,rotation,rotationyoked[,drawingMode])
% yPositionPercent (0 <= value <= 1), in normalized units of the diagonal of the stim region
% trialDistribution in format { { {imagePrefixN imagePrefixP} .1}...
%                               { {imagePrefixP imagePrefixM} .9}...
%                             }
% first image listed for each trial is correct answer
% trial chosen according to probabilities provided (will be normalized)
% image names should not include path or extension
% images must reside in directory indicated and be .png's with alpha channels
% 
% imageSelectionMode is either 'normal' or 'deck' (deck means we make use of the deck-style card selection used in v0.8)
% size is a [2x1] vector that specifies a range from which to randomly select a size for the images (varies from 0-1)
% sizeyoked is a flag that indicates if all images have same size, or if to randomly draw a size for each image
% rotation is a [2x1] vector that specifies ar range from which to randomly select a rotation value for the images (in degrees!)
% rotationyoked is a flag that indicates if all images have same rotation, or if to randomly draw a rotation for each image
% drawingMode is an optional argument that specifies drawing in 'expert' versus 'static' mode (default is 'expert')

s.directory = '';
s.background=0;
s.yPositionPercent=0;
s.cache=[];
s.trialDistribution={};
s.imageSelectionMode=[];

% added 12/8/08 - size and rotation parameters
s.size=[];
% uniformly select on this range each trial,
% and scale the size of image by this factor 
s.rotation=[];
s.sizeyoked=[];
s.rotationyoked=[];
% if 1, the size of distractor is scaled by
% the same amount as the target; if 0,
% independently draw a scale factor for the distractor 
s.selectedSizes=[]; % not user-defined; this gets set by calcStim as the randomly drawn value from the size range
s.selectedRotations=[]; % not user-defined; this gets set by calcStim as the randomly drawn value from the rotation range
s.images=[]; % used for expert mode
s.drawingMode='expert';


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
    case {13 14}
        % create object using specified values

        if ischar(varargin{1})
            s.directory=varargin{1};
            try
                d=isdir(s.directory); % may fail due to windows networking/filesharing bug, but unlikely at construction time
            catch
                ex=lasterror;
                ple(ex)
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
            varargin{8}
            size(varargin{8})
            error('trialDistribution must be nonempty vector cell array')
        end
        
        %imageSelectionMode
        if ischar(varargin{9}) && (strcmp(varargin{9},'normal') || strcmp(varargin{9},'deck'))
            s.imageSelectionMode=varargin{9};
        else
            error('imageSelectionMode must be either ''normal'' or ''deck''');
        end
        
        %size
        if isvector(varargin{10}) && length(varargin{10})==2 && isnumeric(varargin{10}) && ...
                all(varargin{10}>0) && all(varargin{10}<=1) && varargin{10}(2)>=varargin{10}(1)
            s.size=varargin{10};
        else
            error('size must be a 2-element vector between 0 and 1');
        end
                
        %sizeyoked
        if islogical(varargin{11})
            s.sizeyoked=varargin{11};
        else
            error('sizeyoked must be a logical');
        end
        
        %rotation
        if isvector(varargin{12}) && length(varargin{12})==2 && isnumeric(varargin{12})
            s.rotation=varargin{12};
        else
            error('rotation must be a 2-element vector');
        end
        
        %rotationyoked
        if islogical(varargin{13})
            s.rotationyoked=varargin{13};
        else
            error('rotationyoked must be a logical');
        end
        
        %mode
        if nargin==14
            if ischar(varargin{14}) && (strcmp(varargin{14},'expert') || strcmp(varargin{14},'cache'))
                s.drawingMode=varargin{14};
            else
                error('drawingMode must be ''expert'' or ''cache''');
            end
        end

        s = class(s,'images',stimManager(varargin{4},varargin{5},varargin{6},varargin{7}));

        validateImages(s); %error if can't load images or bad format

    otherwise
        error('Wrong number of input arguments')
end