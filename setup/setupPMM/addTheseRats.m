function r=addTheseRats(r,subjects,p,persistTrainingSteps)
% add these rats and set per rat values
%NOT USED since 03/26/2008

if ~exist('persistTrainingSteps', 'var')
    persistTrainingSteps=1; %this is if you have to reset protocol... we'll give you the trainingStep from previous ratrix
end

for i=1:size(subjects,2)

    % only make and add a rat if its not there
    if ~any(strcmp(subjects{i}, getSubjectIDs(r)))
        s = subject(char(subjects(i)), 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories');
        r=addSubject(r,s,'pmm');
    else
        s = getSubjectFromID(r, subjects{i});
    end

    if persistTrainingSteps
        stepNum=getMiniDatabaseFact(getSubjectFromID(r,subjects{i}),'stepNumber',); %this is if you have to reinit...
    else
        stepNum=1;
    end

    stepNum
    subjects(i)
    [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'from pmm master Shaping','pmm');
    if persistTrainingSteps
        r=setCurrentShapedValueFromMiniDatabase(s,r);
    end
end