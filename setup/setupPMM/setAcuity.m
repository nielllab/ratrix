function r=setAcuity(r,subjects,protocolType,protocolVersion)
%r=setAcuity(r,{'rat_112','testAcuity'},'tiltDiscrim','1_0')

defaultSettingsDate='Oct.09,2007';
parameters=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);

nameOfShapingStep{1} = sprintf('Expt1: spatial frequency sweep', protocolType);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
parameters.scheduler=minutesPerSession(90,3);
parameters.requestRewardSizeULorMS=0;
parameters.msPenalty=10000;
parameters.mean = 0.5;
parameters.typeOfLUT= 'linearizedDefault';
parameters.rangeOfMonitorLinearized=[0.0 0.5];
parameters.stdGaussMask = 1/5;
parameters.gratingType='sine';
parameters.pixPerCycs =[4 8 16 32 64 128];
[experiment1 previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Expt2: spatial frequency plus contrast sweep', protocolType);
parameters=setLeftAndRightContrastInParameterStruct(previousParameters, protocolType, [0 0.125 0.25 0.5 0.75 1]);
[experiment2 previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate);
p=protocol(nameOfProtocol,{experiment1,experiment2});
persistTrainingSteps=1;


%r=addTheseRats(r,subjects,p,persistTrainingSteps);

for i=1:size(subjects,2)
    if ~any(strcmp(subjects{i}, getSubjectIDs(r)))
        allIDs = getSubjectIDs(r)
        thisID = subjects{i}
        error('rats should already be there')
        %         s = subject(char(subjects(i)), 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories');
        %         r=addSubject(r,s,'pmm');
    else
        s = getSubjectFromID(r, subjects{i});
    end

    miniDatabasePath = fullfile(getRatrixPath, 'setup','setupPMM');
    %miniDatabaseFile = fullfile(getRatrixPath, 'setup','setupPMM','miniDatabase.mat')
    if persistTrainingSteps;
        i
        stepNum=getMiniDatabaseFact(getSubjectFromID(r,subjects{i}),'stepNumber',miniDatabasePath); %this is if you have to reinit...
    else
        stepNum=1;
    end

    stepNum
    subjects(i)
    [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'from pmm master Shaping','pmm');
    if persistTrainingSteps
        r=setValuesFromMiniDatabase(s,r,miniDatabasePath);
    end
end
