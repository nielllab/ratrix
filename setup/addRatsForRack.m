function r=addRatsForRack(rackID,auth)

conn=dbConn('132.239.158.177','1521','dparks','pac3111');
heats=getHeats(conn);
ids={};
for i=1:length(heats)
    assignments=getAssignments(conn,rackID,heats{i}.name);
    for j=1:length(assignments)
        ids{end+1}=assignments{j}.subject_id;
    end
end

ids
s=getSubjects(conn,ids);
numSubjects=length(s)
closeConn(conn);

if length(s)~=length(unique({s.id}))
    length(s)
    length(unique({s.id}));
    [B,I,J] = unique({s.id},'first');
    [B2,I2,J2] = unique({s.id},'last');
    ({s.id})
    double=B(find(I2~=I))
    warning('multiply defined subjects?')
    s=s(I);
end

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

for i=1:length(s)


    s(i)

    switch s(i).gender
        case 'M'
            gender='male';
        case 'F'
            gender='female';
        case 'UNKNOWN'
            gender='unknown';
        otherwise
            error('bad gender')
    end


try
    dob=datestr(s(i).dob,'mm/dd/yyyy');  %definition changed yet again as we use dans database obj instead of matlabs pmm 080602
    dateEntered=datestr(s(i).date_entered,'mm/dd/yyyy');
    %dob=datestr(datenum(s(i).dob,'yyyy-mm-dd'),'mm/dd/yyyy');  
    %dateEntered=datestr(datenum(s(i).date_entered,'yyyy-mm-dd'),'mm/dd/yyyy');
    %did oracle change its convention? why did this change? -pmm 2008/04/17
    %     dob=datestr(s(i).dob,'mm/dd/yyyy');
    %     dateEntered=datestr(s(i).date_entered,'mm/dd/yyyy');
catch
    s(i).dob
%     keyboard
    error ('bad date')
end

    if strcmp(lower( s(i).litter),'unknown')
        litterID='unknown';
    elseif size(s(i).litter)==[1 1]
        litterID=[lower(s(i).litter) ' ' dob ];
    else
        s(i).litter
        error('bad litter')
    end
    subj=subject(s(i).id, s(i).species, s(i).strain, gender, dob , dateEntered, litterID, s(i).supplier);
    r=addSubject(r,subj,auth);
end


%eriks old code!  temporary,  deletble. keep until merge works or you are erik ---pmm

% litterID=subjects{i}{2};
%
% if strcmp(litterID,'unknown')  % wrong case
%     %nothing
% elseif ischar(litterID) && isscalar(litterID)
%     litterID = [litterID ' ' subjects{i}{3}];
% else
%     error('bad litter ID')
% end

%s=subject(subjects{i}{1}, species, strain, gender, subjects{i}{3}, receivedDate, litterID, supplier);

%need to add a db method that gets the following details for subjects:
% hey dan, can you add a getSubjects({ids}) db query for us?
% if {ids} is empty, return all defined subjects, otherwise just those for the ids given (strs in a cell array).
% output should be struct array with fields:
% species
% strain
% gender
% receivedDate
% supplier
% sibling group ("litterID")
% DOB
% date entered
% date exited
% exit status
% owner
%
% exact format of strings:
% species/strain: 'rat' (strain 'long-evans'), 'squirrel' (strain 'wild'), 'mouse' (strains 'c57bl/6j' 'dba/2j' 'B6D2F1/J'), 'degu' (strain 'none'), or 'human' (strain 'none')
% gender: 'male' or 'female'
% dates must be mm/dd/yyyy (receivedDate may be ''unknown'')
% supplier: 'wild caught' or 'Jackson Laboratories' or 'Harlan Sprague Dawley'
% litterID:  'unknown' or supplied as '[single lower case letter] DOB(mm/dd/yyyy -- must match DOB supplied)' -- ex: 'a 01/01/2007'
% exit status - string
% owner - string

% species='rat';
% strain='long-evans';
% gender='female';
% receivedDate='unknown';
% supplier='Harlan Sprague Dawley'; %http://www.harlan.com/models/longevans.asp
% switch date
%     case '02/02/08'
%         subjects={...
%             %subjectID  %sib grp	%bday
%             {'179'      'a'         '12/29/2007'},...
%             {'180'      'a'         '12/29/2007'},...
%             {'177'      'a'         '12/29/2007'},...
%             {'178'      'a'         '12/29/2007'},...
%             {'165'      'unknown'   '12/11/2007'},...
%             {'166'      'unknown'   '12/11/2007'},...
%             ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             {'159'      'unknown'   '10/19/2007'},...
%             {'160'      'unknown'   '10/19/2007'},...
%             {'173'      'unknown'   '12/11/2007'},...
%             {'174'      'unknown'   '12/11/2007'},...
%             {'175'      'unknown'   '12/11/2007'},...
%             {'176'      'unknown'   '12/11/2007'},...
%             ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             {'185'      'b'         '12/29/2007'},...
%             {'186'      'b'         '12/29/2007'},...
%             {'183'      'b'         '12/29/2007'},...
%             {'184'      'b'         '12/29/2007'},...
%             {'167'      'unknown'   '12/11/2007'},...
%             {'168'      'unknown'   '12/11/2007'},...
%             ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             {'161'      'unknown'   '10/19/2007'},...
%             {'162'      'unknown'   '10/19/2007'},...
%             {'181'      'a'         '12/29/2007'},...
%             {'182'      'a'         '12/29/2007'},...
%             {'187'      'b'         '12/29/2007'},...
%             {'188'      'b'         '12/29/2007'},...
%             ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             {'163'      'unknown'   '10/19/2007'},...
%             {'164'      'unknown'   '10/19/2007'},...
%             {'189'      'c'         '12/29/2007'},...
%             {'190'      'c'         '12/29/2007'},...
%             {'191'      'c'         '12/29/2007'},...
%             {'192'      'c'         '12/29/2007'},...
%             ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             {'169'      'unknown'	'12/11/2007'},... %mv
%             {'170'      'unknown'	'12/11/2007'},... %mv
%             {'171'      'unknown'	'12/11/2007'},... %edf
%             {'172'      'unknown'   '12/11/2007'},... %edf
%             {'193'      'c'         '12/29/2007'},... %edf
%             {'194'      'c'         '12/29/2007'}... %edf
%             };
%     case '02/08/08'
%         subjects={...
%             %subjectID  %sib grp	%bday
%             {'test1'    'unknown'	'02/08/2008'},...
%             {'test2'    'unknown'	'02/08/2008'},...
%             {'test3'    'unknown'	'02/08/2008'},...
%             {'test4'    'unknown'	'02/08/2008'},...
%             {'test5'    'unknown'	'02/08/2008'},...
%             {'test6'    'unknown'	'02/08/2008'},...
%             };
%     otherwise
%         error('unrecognized date')
% end
