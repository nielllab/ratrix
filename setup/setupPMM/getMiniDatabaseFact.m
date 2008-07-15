function out=getMiniDatabaseFact(subject,factType,miniDatabasePath)

%1   2   3   4       5          6        7      8          9          10          11
%{fd1,fd2,fd3,easy,centerOff,linearized,thinner,smaller,dimFlankers,fullFlankers,varyPosition}

whichDatabase = 'miniDatabase'; % one day this will be Dan's Oracle Database: 'database'


if ~exist('miniDatabasePath', 'var') % don't use this default unless you are Philip
    %miniDatabasePath = 'C:\pmeier\Ratrix\analysis\miniDatabase';  % old testing
    %miniDatabasePath = '\\192.168.0.1\c\pmeier\RSTools\miniDatabase'; %old server address
    miniDatabasePath = fullfile(getRatrixPath, 'setup','setupPMM');
end

out = 'noValueYet';
switch whichDatabase
    case 'miniDatabase'

        database = getMiniDatabase(miniDatabasePath);
        numSubjects=size(database.subject,2);

        for i=1:numSubjects

            if all(strcmp(database.subject{i}.subjectID, getID(subject)))
                f=fields(database.subject{i});

                if ~any(strcmp(f,factType))
                    f
                    factType= factType
                    miniDatabasePath=miniDatabasePath
                    usedID=getID(subject)
                    error ('requested fact is not in database')
                end

                command=sprintf('out=database.subject{i}.%s;',factType);
                try
                    eval(command);
                catch
                    disp(command);
                    error ('bad command')
                end
            end
        end
    case 'database'
        % this should call Dan's oracle database
end

if strcmp(out, 'noValueYet')
    factType= factType
    miniDatabasePath=miniDatabasePath
    database=database
    usedID=getID(subject)
    error('did not get a value from the miniDatabase');
end


