function ratSubjectSession(subjectID)
%ratSubjectSession('test')
%choose which rat: 'test','rat_107', 'edf' ,'rat_v' , 'rat_114-115'

if ~exist('subjectID','var')
subjectID='test'
end

ifStartInit=0;
if ifStartInit
    RatSubjectInit
end


%% getPaths
rootPath='C:\pmeier\Ratrix\'; 
warning('off','MATLAB:dispatcher:nameConflict')
%addpath(genpath([rootPath 'Server' pathSep]));  pathSep='\';
addpath(genpath(fullfile(rootPath,'classes')));
addpath(genpath(fullfile(rootPath,'analysis')));
rmpath(fullfile(rootPath,'analysis','miniDatabase'));  %makeMiniDatabase must come from remote!
warning('on','MATLAB:dispatcher:nameConflict')
%r=ratrix([rootPath 'ServerData' pathSep],0); possibleIDs=getSubjectIDs(r)

%remove all others already in...only allows one at at time
removeSubjectFromPmeierRatrix

%% runIt
numTrialsPerLoop=1000; %maximum trials, scheduler will choose less
numLoops=99;  %set to high and wait for kq to break it

loop=0;
while loop<numLoops
    %setup
    loop=loop+1
    r=ratrix(fullfile(rootPath, 'ServerData',filesep),0);
    
    s=getSubjectFromID(r,subjectID);
    b=getBoxIDForSubjectID(r,getID(s));

   
%FOR DEBUGGING bad stimManagers 
%     ifFeatureGoRightWithTwoFlank
%     [p step]=getProtocolAndStep(s);
%     stim=getStimManager(getTrainingStep(p, step))
%     class(stim)

    r=putSubjectInBox(r,subjectID,1,'pmm'); %force box1
    b=getBoxIDForSubjectID(r,getID(s))
    st=getStationsForBoxID(r,b)
    
    r=doTrials(st,r,numTrialsPerLoop); %run
    r=removeSubjectFromBox(r,subjectID,b,'no comment','pmm')
    
    %error('now')
    
    data=loadRatrixData([rootPath 'Boxes\box1\'],{subjectID},'lastNfiles',int8(1)); %load this rats data to check last trial
    clearSubjectDataDir(getBoxFromID(r,1)); %clear subjectData directory from box1 to shrink trial records
    if strcmp(data{1}.trialRecords(end).response,'manual kill')
        %quit force
        numToAnalyze=loop;
        loop=numLoops
    end
    %loop=numLoops+1 %for debugging loop
    
end


% [p t]=getProtocolAndStep(s);
% t=getTrainingStep(p,t)
% s=getStimManager(t)
% 
% disp(t)
% display(t)
% display(getTrialManager(t))
%
% doFlush(st,1)

if 0
    path=[rootPath 'Boxes\box1\'];
    subjects={subjectID};%{'test','rat_w'}; %set subjects=[] for all
    lastN=int8(numToAnalyze);
    data=loadRatrixData(path,subjects,'lastNFiles',lastN);
    ratrixAnalysis(data);
end

