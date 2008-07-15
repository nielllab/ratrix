%this can be used to run a rat from upstairs.
%make sure this rat is not running on the other computer or on a station
%downstairs if using the same permanant store

if 0
    setupRig1(101,'B');
end

subjectID='162'% test_rig1b, 127, 164, 131, 162

%% get ratrix
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

%% setup
bIDs=getBoxIDs(r);
r=putSubjectInBox(r,subjectID,bIDs(1),'pmm')
s=getSubjectFromID(r,subjectID);
b=getBoxIDForSubjectID(r,getID(s));
st=getStationsForBoxID(r,b);

%% replicate data
rackID=101;
extraServerPermanentStore=getSubDirForRack(rackID); %for records, compiling, analysis, but not trialHistory used by ratrix

deleteOnSuccess = true;
recordInOracle = false;  %Implication: subject needs not be in oracle, only get history if trustOsRecordFiles
%the moment you record in Oracle you should use a unique subject name... upize(subjectIDs, 101)
trustOsRecordFiles = true; %don't do this unless the ratrix's permanentStore is local on this machine
replicateTrialRecords({getPermanentStorePath(r),extraServerPermanentStore},deleteOnSuccess,recordInOracle);

%% run
try
    r=doTrials(st(1),r,0,[],trustOsRecordFiles); %0 means repeat forever
    sca; ListenChar(0); ShowCursor(0); r=removeSubjectFromBox(r,subjectID,bIDs(1),'','pmm');
catch
    sca; ListenChar(0); ShowCursor(0); r=removeSubjectFromBox(r,subjectID,bIDs(1),'','pmm');
    lasterr; x=lasterror;
    x.stack.file
    x.stack.line
    rethrow(lasterror)
end

replicateTrialRecords({getPermanentStorePath(r),extraServerPermanentStore},deleteOnSuccess,recordInOracle);

if 0
%% analysis
    compileTrialRecords(101)
    d=getSmalls('127',[],101)
    figure; doPlotPercentCorrect(d)

    %doPlotPercentCorrect(d,[],25)
    figure; doPlot('plotTrialsPerDay',d)
    figure; doPlot('plotRatePerDay',d)
%%
end

