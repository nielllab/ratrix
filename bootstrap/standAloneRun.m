function standAloneRun(rx,subjectID)
%run a subject on the given ratrix object, exercising full use of the
%oracle db

if ~exist('subjectID','var')
    %if not specified, use the first one
    ids=getSubjectIDs(rx);
    subjectID=ids{1};
end

try
    deleteOnSuccess = true;
    recordInOracle = true;  %Implication: history is loaded in & subject needs be in oracle 
    replicateTrialRecords({getPermanentStorePath(rx)},deleteOnSuccess, recordInOracle);
    s=getSubjectFromID(rx,subjectID);
    b=getBoxIDForSubjectID(rx,getID(s));
    st=getStationsForBoxID(rx,b);
    rx=doTrials(st(1),rx,0,[]); %0 means repeat forever
    replicateTrialRecords({getPermanentStorePath(rx)},deleteOnSuccess, recordInOracle);
    cleanup;
catch
    lasterr
    x=lasterror
    x.stack.file
    x.stack.line
    cleanup;
    rethrow(lasterror)
end

function cleanup
sca
ListenChar(0)
ShowCursor(0)