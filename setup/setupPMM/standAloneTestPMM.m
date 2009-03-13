function r=standAloneTestPMM()

%setupEnvironment;
subID='test';
sub = subject(subID, 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
auth='pmm';
machines={{'99A','000000000000',[1 1 1]}};
dataPath = fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
% serverDataPath = fullfile(dataPath, 'ServerData');
servePump = 0;
localMultiDisplaySetup=0;

r = createRatrixWithDefaultStations(machines, dataPath,servePump,localMultiDisplaySetup);
r=setPermanentStorePath(r,'C:\Documents and Settings\rlab\Desktop\standAloneData');

r = addSubject(r,sub,auth);

r = setShapingPMM(r,{subID}, 'goToRightDetection', '2_3');
%r= setShapingPMM(r,{subID}, 'tiltDiscrim', '2_0')
%r = setHeadFixProtocol(r,{subID})

% im=sampleStimFrame(getSubjectFromID(r,{subID}));
% figure; imagesc(im); colormap(gray)
% [p step]=getProtocolAndStep(getSubjectFromID(r,{subID}))

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

catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    cleanup;
    rethrow(ex)
end

function cleanup
diary
sca
ListenChar(0)
