function r=reinforcementManager(varargin)
% REINFORCEMENTMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% r=rewardManager(fractionOpenTimeSoundIsOn, fractionPenaltySoundIsOn)

%why would I need this?   Maybe this contains pump info one day -- but
%station might know that...

    %okay these don't actually get used... pmm
%         r.rewardSizeULorMS=0;
%         r.msPenalty=0;
        r.fractionOpenTimeSoundIsOn=0;
        r.fractionPenaltySoundIsOn=0;        
%         r.scalar=1;            
%         r.thisSessionIsCached=0;
 
        r.rewardStrategy='msOpenTime';
        r.unloggedRewardConvention='reset to 250mmHg';
        
switch nargin
    case 0
        % if no input arguments, create a default object
        
        r = class(r,'reinforcementManager',structable());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'reinforcementManager'))
            r = varargin{1};
        else
            error('Input argument is not a reinforcementManager object')
        end
    case 2  
       
        if varargin{1}>=0 && varargin{1}<=1
            r.fractionOpenTimeSoundIsOn=varargin{1};
        else
            error('fractionOpenTimeSoundIsOn must be >=0 and <=1')
        end
        
        if varargin{2}>=0 && varargin{2}<=1
            r.fractionPenaltySoundIsOn=varargin{2};
        else
            varargin{2}
            error('fractionPenaltySoundIsOn must be >=0 and <=1')
        end
        
        r.rewardStrategy='msOpenTime';
        r.unloggedRewardConvention='reset to 250mmHg';


        %         if varargin{xx}>=0
        %             t.msFlushDuration=varargin{xx};
        %         else
        %             error('msFlushDuration must be >=0')
        %         end

        %Custom discription not used by display
        %         if ischar(varargin{3))
        %             t.description=sprintf(['%s\n'...
        %                                    '\t\t\tmsFlushDuration:\t%d\n'...
        %                                    '\t\t\trewardSizeULorMS:\t%d\n'...
        %                                    '\t\t\tmsMinimumPokeDuration:\t%d\n'...
        %                                    '\t\t\tmsMinimumClearDuration:\t%d\n'...
        %                                    '\t\t\tmsPenalty:\t%d\n'...
        %                                    '\t\t\tmsRewardSoundDuration:\t%d'], ...
        %                 varargin{3},t.msFlushDuration,t.rewardSizeULorMS,t.msMinimumPokeDuration,t.msMinimumClearDuration,t.msPenalty,t.msRewardSoundDuration);
        %         else
        %             error('not a string')
        %         end


        r = class(r,'reinforcementManager',structable());

    otherwise
        error('Wrong number of input arguments')
end

r=setSuper(r,r.structable);