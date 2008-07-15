function r=addTestRats(subjects,auth)

if isnumeric(subjects) && all(size(subjects))==[1 1]
    numSubjects=subjects;
    for j=1:numSubjects
        subjects{j}=sprintf('%s%d','test',j);
    end
else
    numSubjects=length(subjects)
end

conn=dbConn;
s=getSubjects(conn,{'r'}); % make this the test object one day!
closeConn(conn);

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

for j=1:numSubjects
    i=1;

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

    dob=datestr(datenum(s(i).dob,'yyyy-mm-dd'),'mm/dd/yyyy');
    dateEntered=datestr(datenum(s(i).date_entered,'yyyy-mm-dd'),'mm/dd/yyyy');

    subj=subject(subjects{j}, s(i).species, s(i).strain, gender, dob , dateEntered, lower(s(i).litter), s(i).supplier);
    r=addSubject(r,subj,auth);
end
