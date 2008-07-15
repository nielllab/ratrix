function removeSubjectFromPmeierRatrix(subjectID)
%removes all possible subjects in the station

%paths:
rootPath='C:\pmeier\Ratrix\';
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath(fullfile(rootPath,'classes')));
warning('on','MATLAB:dispatcher:nameConflict')

%get ratrix:
r=ratrix(fullfile(rootPath,'ServerData',filesep),0);

if ~exist('subjectID','var')
    possibleSubjects=getSubjectIDsForBoxID(r,1)
else
    possibleSubjects={subjectID};
end

forceRemove=1;
%removes whoever is in
for i=1:size(possibleSubjects,2)
    isIn=subjectIDRunning(r,possibleSubjects(i)); % this might indicate "running" not "in box"
    if isIn || forceRemove
        disp(['trying to remove: ' possibleSubjects(i)])
        s=getSubjectFromID(r,possibleSubjects(i));
        b=getBoxIDForSubjectID(r,getID(s));
        r=removeSubjectFromBox(r,char(possibleSubjects(i)),b,'remover function','pmm')
    end
end

disp('done removing all possible subjects')