function r=setHeadFixProtocol(r,subjectIDs)

% if ~exist('subjectIDs','var')
%     subjectIDs={'test1'};
% end
%
% if ~exist('r','var')
%     dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
%     r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
% end

%test out the promptedNAFC
nameOfShapingStep={'hfix prompted test'}
p=getDefaultParameters(ifFeatureGoRightWithTwoFlank, 'goToSide','1_0','Oct.09,2007');
p.delayMeanMs=1000; %this parameters are not actually used; all that matters is hardcoded into promptedNAFC doTrial and StimOGL
p.delayStdMs=0;
p.delayStim=.5;
p.promptStim=.7;
[basic previousParameters]=setFlankerStimRewardAndTrialManager(p, nameOfShapingStep{end},'promptedNAFC');

%nameOfProtocol=generateProtocolName
nameOfProtocol=char(nameOfShapingStep);
p=protocol(nameOfProtocol,{basic})
miniDatabasePath = fullfile(getRatrixPath, 'setup','setupPMM');

for i=1:length(subjectIDs)
    switch subjectIDs{i}
        case '127'
            r=setShapingPMM(r,subjectIDs(i), 'goToRightDetection', '1_3');
            requestRewardSizeMs=50;
            setSteps=[999:1000]; % these should be the steps that are all relevant nAFC, excluding free drinks
            %r=setRequestReward(r,subjectIDs(i),requestRewardSizeMs,1);
            setReinforcementParam('requestReward',{'127'},requestRewardSizeMs,setSteps,'on headfix setup','pmm')
        otherwise
            subjectIDs{i}
            s = getSubjectFromID(r, subjectIDs{i});
            stepNum=1;
            [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'from setHeadFixRig','pmm');
            r=setValuesFromMiniDatabase(s,r,miniDatabasePath);
    end
end