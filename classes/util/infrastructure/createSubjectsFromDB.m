function subs=createSubjectsFromDB(subIDs)

subs=[];

conn=dbConn;


subIDs
s=getSubjects(conn,subIDs);
numSubjects=length(s)
closeConn(conn);

if ~isempty(s) && length(s)~=length(unique({s.id}))
    length(s)
    length(unique({s.id}));
    [B,I,J] = unique({s.id},'first');
    [B2,I2,J2] = unique({s.id},'last');
    ({s.id})
    double=B(find(I2~=I))
    warning('multiply defined subjects?')
    s=s(I);
end

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
        dob=datestr(s(i).dob,'mm/dd/yyyy');
        dateEntered=datestr(s(i).date_entered,'mm/dd/yyyy');
    catch
        s(i).dob
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
    if isempty(subs)
        clear subs %ugh!
    end
    subs(i)=subject(s(i).id, s(i).species, s(i).strain, gender, dob , dateEntered, litterID, s(i).supplier);
    
end
