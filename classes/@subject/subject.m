function s=subject(varargin)
% SUBJECT  class constructor.
% s = subject(id,species,strain,gender,birthDate,receivedDate,litterID,supplier)

s.id='';
s.species='';
s.strain='';
s.gender='';
s.birthDate=[];
s.receivedDate=[];
s.litterID='';
s.supplier='';
s.protocol=[];
s.trainingStepNum=0;
s.protocolVersion.manualVersion=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'subject');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'subject'))
            s = varargin{1};
        else
            error('Input argument is not a subject object')
        end
    case 8
        % create object using specified values

        s.id=lower(varargin{1});
        if (strcmp(varargin{2},'rat') && strcmp(varargin{3},'long-evans')) || ...
                (strcmp(varargin{2},'squirrel') && strcmp(varargin{3},'wild caught')) || ...
                (strcmp(varargin{2},'mouse') && (strcmp(varargin{3},'c57bl/6j') || strcmp(varargin{3},'dba/2j') || strcmp(varargin{3},'b6d2f1/j') )) || ...
                (strcmp(varargin{2},'degu') && strcmp(varargin{3},'none')) || ...
                (strcmp(varargin{2},'human') && strcmp(varargin{3},'none'))
            s.species=varargin{2};
            s.strain=varargin{3};
        else
            error('species must be ''rat'' (strain ''long-evans''), ''squirrel'' (strain ''wild''), ''mouse'' (strains ''c57bl/6j'' ''dba/2j'' ''B6D2F1/J''), ''degu'' (strain ''none''), or ''human'' (strain ''none'')')
        end

        if strcmp(varargin{4},'male') || strcmp(varargin{4},'female')
            s.gender=varargin{4};
        else
            error('gender must be male or female')
        end

        dtb = datevec(varargin{5},'mm/dd/yyyy');
        if ~strcmp(varargin{6},'unknown')
            dtr = datevec(varargin{6},'mm/dd/yyyy');
        else
            dtr=varargin{6};
        end
        if dtb(1)>=2005 && dtb(4) == 0 && dtb(5) == 0 && dtb(6) == 0 && (strcmp(dtr,'unknown') || (dtr(1)>=2005 && dtr(4) == 0 && dtr(5) == 0 && dtr(6) == 0))
            s.birthDate=dtb;
            s.receivedDate=dtr;
        else
            error('dates must be supplied as mm/dd/yyyy and no earlier than 2005 (acq date may be ''unknown'')')
        end

        s.litterID=varargin{7};
        if strcmp(s.litterID,'unknown') || (isstrprop(s.litterID(1), 'alpha') && isstrprop(s.litterID(1), 'lower') && s.litterID(2)==' ' && all(varargin{5}==s.litterID(3:end)))
            %nothing
        else
            ['''' s.litterID '''']
            error('litterID must be ''unknown'' or supplied as ''[single lower case letter] DOB(mm/dd/yyyy -- must match DOB supplied)'' -- ex: ''a 01/01/2007''')
        end

        if ismember(varargin{8},{'wild caught','Jackson Laboratories','Harlan Sprague Dawley'})
            s.supplier=varargin{8};
        else
            error('supplier must be ''wild caught'' or ''Jackson Laboratories'' or ''Harlan Sprague Dawley''')
        end

%         s.protocol=[];
%         s.trainingStepNum=0;
%         s.protocolVersion.manualVersion=0;
        s = class(s,'subject');

    otherwise
        error('Wrong number of input arguments')
end
