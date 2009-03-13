function runRatTest(subID)

%setupEnvironment;

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

%r=setPermanentStorePath(r,'C:\Documents and Settings\rlab\Desktop\standAloneData');

bIDs = getBoxIDs(r);
b=getBoxIDForSubjectID(r,subID);
if b==0
    r = putSubjectInBox(r,subID,bIDs(1),'pmm');
end

try

    s=getSubjectFromID(r,subID);
    b=getBoxIDForSubjectID(r,getID(s));
    st=getStationsForBoxID(r,b);
    r=doTrials(st(1),r,0,[]); %0 means repeat forever
    
    cleanup(r,subID,b);

catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    cleanup(r,subID,b);
    rethrow(ex)
end

function cleanup(r,subID,b)
r=removeSubjectFromBox(r,subID,b,'done with test','pmm');
sca
ListenChar(0)