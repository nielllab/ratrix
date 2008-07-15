function r=rewardNcorrectInARow(varargin)
% ||rewardNcorrectInARow||  class constructor.
% r=rewardNcorrectInARow(rewardNthCorrect,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar)

switch nargin
    case 0
        % if no input arguments, create a default object
        r.rewardNthCorrect=[0]; %this is a vector of the rewardSizeULorMSs for the Nth trial correct in a row
        r.msPenalty=0;
        r.scalar = 0;
        
        r = class(r,'rewardNcorrectInARow',reinforcementManager());  
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'rewardNcorrectInARow'))
            r = varargin{1};
        else
            error('Input argument is not a rewardNcorrectInARow object')
        end
    case 5

        if all(varargin{1})>=0
            r.rewardNthCorrect=varargin{1};
        else
            error('all the rewardSizeULorMSs must be >=0')
        end
        
        if varargin{2}>=0
            r.msPenalty=varargin{2};
        else
            error('msPenalty must be >=0')
        end
        
      
        if varargin{5}>=0 && varargin{5}<=100
            r.scalar=varargin{5};            
        else
            error('scalar must be >=0 and <=100')
        end
     
        r = class(r,'rewardNcorrectInARow',reinforcementManager(varargin{3}, varargin{4}));

    otherwise
        error('Wrong number of input arguments')
end

r=setSuper(r,r.reinforcementManager);


