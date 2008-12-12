function s=nTrialsThenWait(varargin)
% NTRIALSTHENWAIT  class constructor.  
% s=nTrialsThenWait(possibleNumTrials,probOfNumTrials,possibleHoursBetweenSessions,probOfHoursBetweenSessions)
% s=nTrialsThenWait([200,300,500],[1/3,1/3,1/3],[5],[1])

switch nargin
    case 0
        % if no input arguments, create a default object
        s.possibleNumTrials=0;
        s.possibleHoursBetweenSessions=0;
        s.probOfNumTrials=0;
        s.probOfHoursBetweenSessions=0;
        s.numTrials=0;
        s.hoursBetweenSessions=0;
        s.isOn=0;
        s.lastCompletedSessionEndTime=0;
        s = class(s,'nTrialsThenWait',scheduler());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'nTrialsThenWait'))
            s = varargin{1};
        else
            error('Input argument is not a nTrialsThenWait object')
        end
    case 4
        if all(varargin{1}>=0) && all(varargin{3}>=0)
            %these are a list off possible values
            s.possibleNumTrials=varargin{1};
            s.possibleHoursBetweenSessions=varargin{3};
        else
            error('all values of possibleNumTrials and possibleHoursBetweenSessions must be >= 0')
        end
        
        if (sum(varargin{2})==1) && (sum(varargin{4})==1) && length(varargin{1})==length(varargin{2}) && length(varargin{3})==length(varargin{4})
            %these are the probability of each of the possible values
            s.probOfNumTrials=varargin{2};
            s.probOfHoursBetweenSessions=varargin{4};
        else
            varargin{1}
            varargin{2}
            varargin{3}
            varargin{4}
            error('probability values must sum to one a be the same length as the possible values')
        end
        
        s.numTrials=0;
        s.hoursBetweenSessions=0;
        s.isOn=1;
        s.lastCompletedSessionEndTime=0;
        
        s = class(s,'nTrialsThenWait',scheduler());
    otherwise
        error('Wrong number of input arguments')
end
        
        s = setNewHoursBetweenSession(s);
        s = setNewNumTrials(s);
        