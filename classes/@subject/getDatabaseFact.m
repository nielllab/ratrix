function out=getDatabaseFact(subject,factType)

%1   2   3   4       5          6        7      8          9          10          11
%{fd1,fd2,fd3,easy,centerOff,linearized,thinner,smaller,dimFlankers,fullFlankers,varyPosition}

error('defunct code')

whichDatabase = 'xxx'; % one day this will be Dan's Oracle Database: 'database'
out = [];
switch whichDatabase
    case 'miniDatabase'
% this is an access function not defined for the subject but moved to 'setup/setupPMM'
%         database = getMiniDatabase(subject);
% 
%         f=fields(database.subject{1}); %this should really be for the specific subject, but it is the first subject in a whole list of subjects in the miniDatabase
%         if any(strcmp(f,factType))
%             %okay
%         else
%             f
%             factType
%             error ('requested fact is not in database')
%         end
%         numSubjects=size(database.subject,2);
%         for i=1:numSubjects
%             if all(strcmp(database.subject{i}.subjectID, getID(subject)))
%                     command=sprintf('out=database.subject{i}.%s;',factType);
%                 try
%                     eval(command);
%                 catch
%                     disp(command);
%                     error ('bad command')
%                 end
%             end
%         end
    case 'database'
        % this should call Dan's oracle database
    otherwise
        error('bad database location or type')
end