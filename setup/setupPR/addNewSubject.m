function r=addNewSubject(r,subjects)
% r = addNewSubject(r,subjects)
% add new subjects to ratrix object  
% r = ratrix object
% subjects = cell array of subjs such as: {'284','285'}
%
% Note: use setProtocolAndStep to set protocol for the new subjs
% Note: "auth" currently hardwired to pmm
% PR 9/13/08

for i=1:size(subjects,2)
    % only add a subject if its not already in ratrix object
    if any(strcmp(subjects{i}, getSubjectIDs(r))) % subject is in the ratrix object already
        warning('Subject %s already exists in ratrix. Not added.', subjects{i});

    else % really is a new subject
        s=createSubjectsFromDB(subjects(i)); % need to pass cell array not string?
        % gets the rat's data from oracle database and creates subject with
        %  id, species, strain, gender, dob, dateEntered, litterID,
        %  supplier
        r=addSubject(r,s,'pmm'); % auth should be an argument!
        sprintf('Added subject %s\n',subjects{i}); 
    end
end