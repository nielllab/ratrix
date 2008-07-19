function r=standAloneTestPMM()

%setupEnvironment;
subID='test1';
sub = subject(subID, 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
auth='pmm';
machines={{'99A','000000000000',[1 1 1]}};
dataPath = fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
% serverDataPath = fullfile(dataPath, 'ServerData');
servePump = 0;
localMultiDisplaySetup=true;

r = createRatrixWithDefaultStations(machines, dataPath,servePump,localMultiDisplaySetup);
r=setPermanentStorePath(r,'C:\Documents and Settings\rlab\Desktop\standAloneData');

r = addSubject(r,sub,auth);

%r = setShapingPMM(r,{subID}, 'goToLeftDetection', '1_9');
r= setShapingPMM(r,{subID}, 'goToLeftDetection', '2_1')
%r = setHeadFixProtocol(r,{subID})
     

bIDs = getBoxIDs(r);
r = putSubjectInBox(r,getID(sub),bIDs(1),auth);

name='C:\Documents and Settings\rlab\Desktop\Diary.txt';
diary(name)
try

    ids=getSubjectIDs(r);
    s=getSubjectFromID(r,ids{1});
    b=getBoxIDForSubjectID(r,getID(s));
    st=getStationsForBoxID(r,b);
    r=doTrials(st(1),r,0,[]); %0 means repeat forever
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
diary
sca
ListenChar(0)