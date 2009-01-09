function r=replaceAllStructProtocolsWithTempProtocol(r,dummyProtocol,auth)
%when ratrix has objects that have been redefined it will fail to decache
%certain objects on saves (example, stimManger has been redefined)thus, 
%in one fell swoop, the old stuctized objects  must be replaced.  
%this function does that. keep in mind that it will save over 
%the db.mat, so you will loose your (functionally-useless) structure
%
%example use case: right before re-setting protocols, after SVN update:
%
%r=replaceAllStructProtocolsWithTempProtocol %to flush out structs, enabling:
%setupPMM(r)

if ~exist('r')
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
end

if ~exist('dummyProtocol')
    %just using any old protocol thats up to date, and has one step
    parameters=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToSide','1_0','Oct.09,2007');
    [ts]=setFlankerStimRewardAndTrialManager(parameters, 'dummy');
    dummyProtocol=protocol('dummy',{ts});
    %dummyProtocol=protocol; %has zero steps
end

if ~exist('auth')
    auth='pmm'
end

facts=getBasicFacts(r);

%currently only looks for stim managers that are structs, could add other
%objects within protocol, ts, tm ,rm, etc.
whichHaveStruct=find(strcmp(facts(:,6),'struct'));

subjects=facts(whichHaveStruct,1); % get the ones with bad protocols
for i=1:length(subjects)
    %work on paired down ratrix
    miniR=r;
    subjectInd=find(strcmp(getSubjectIDs(miniR),subjects{i}));

    %remove other subjects
    miniR.subjects={miniR.subjects{subjectInd}}

    %don't let it overwrite real db
    miniR.dbpath=fullfile(fileparts(r.dbpath),'junk_db.mat');

    %set the protocol
    step=1;
    s=getSubjectFromID(miniR,subjects{i})
    getID(s)
    [s miniR]=setProtocolAndStep(s,dummyProtocol,0,0,0,step,miniR,'flushing out struct from protocol',auth);
    r.subjects{subjectInd}=s; % same subject is returned, but with a dummny protocol

end

%replace the full database with the structs removed
saveDB(r,0);
