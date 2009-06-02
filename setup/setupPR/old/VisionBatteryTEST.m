function setProtocolPR(ratIDs)
% TEST rats on previously learned tasks after lesions
% (see setProtocol_VisionBattery1 for training)
% % PR 081111
% CHANGED training step order 081204 
% do gotohorizontal right after gotoside, before psychometric motion; 
% review motion with easy range before running full range.

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

% sound manager used by many training steps
sm=makeStandardSoundManager();
% soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
%     soundClip('keepGoingSound','allOctaves',[300],20000), ...
%     soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
%     soundClip('wrongSound','tritones',[300 400],20000)});


%create sound manager object used by stochastic free drinks only
% no hissing sound when water clogs ports
smSTOCH=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','allOctaves',[],2000), ...
    soundClip('wrongSound','allOctaves',[],20000)}); %SILENCE

%create scheduer used by all trial managers
sch=noTimeOff(); % return to previous scheduler

%create criterion used by nAFC trial managers
pc=performanceCriterion([0.85, 0.8],int16([200, 500]));

% constants used by many training steps
msPenalty           =2000; % penalty was 0 in previous cohort!
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
rewardSizeULorMS        =10; % for free drinks only
msRewardSoundDuration   =200; % for free drinks only
requestRewardSizeULorMS=1; % was 10 in previous cohort
percentCorrectionTrials=.25; %% NOTE set lower than usual
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;
msFlushDuration=10;
scalar=1; % note there will be ramping per correct in row.

%params of freedrinks trial manager only
msPenaltyFD              =0; %no penalty during free drinks
earned_freeDrinkLikelihood=0; % no untriggered water, lick required

%params of reinforcement manager
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 1;
rewardScalar =1;


% params used by orientation discrimtask AND free drinks
pixPerCycs              =[64];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =1/8;
contrast                =1;
FDcontrast                =0;%%% all stimuli invisible for free drinks
thresh                  =.00005;
yPosPct                 =.65;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
waveform='square';
normalizedSizeMethod='normalizeVertical';
width=1024;
height=768;

% params used by coherent dots
stimulus = coherentDots;
trialManagerClass='nAFC';
frameRate=100;
responsePorts=[1,3];
totalPorts=3;
maxWidth = 100;
maxHeight = 100;

%%reward manager for NAFC trial managers
increasingReward =rewardNcorrectInARow([50, 100, 200],msPenalty ,1,1, scalar); 

%traial manager for NAFC trial managers
tm =nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingReward );

%traial manager for psychometric curves - many imperceptibel stimuli so eliminate
% the error sound (use smSTOCH) 12/12/08
tmQuiet =nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,smSTOCH,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingReward );
%%%%%%%%%%%%%%


%%% ts_fd = earned drinks must trigger and move between ports %%%
% same as old ts1
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,... % stim manager
    mean,radius,FDcontrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
fd = freeDrinks(msFlushDuration, msMinimumPokeDuration,...   %trial manager
    msMinimumClearDuration,smSTOCH, earned_freeDrinkLikelihood, reinfmanager); 
ts_fd = trainingStep(fd, freeStim, rateCriterion(6,3),sch); %training step

%%% ts_dots = coherent dots, between 75 and 89% coherent
% same as old ts2
ts_dots = makeDotTrainingStep([0.75 0.89]); % defaults to optimal size and speed of dots

%%% ts_side = go to side, for orientation task 
% same as old ts3
%stim manager
goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
ts_side = trainingStep(tm , goToSide, pc, sch);

% ts_gotohor = go to HORIZ, for orientation task 
% same as old ts5
%stim manager
distractorOrientations=[0]; % vertical
goToHor = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
% training step
ts_gotohor = trainingStep(tm , goToHor, pc, sch); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ts_dotpsych = coherent dots psychometric curve  
% same as old ts4
% NOTE always repeat ts_dots before this (very hard task)
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [0.2 0.9], 1, 3, 10, 85, [6 6]);
ts_dotpsych = trainingStep(tm , discrimStimPsych, pc,sch); 

%%% ts_side_param = go to side VARY spatial freq
pixPerCycsPar=[4 8 16 32 64 128]; % sweep parametrically thru spatial freq
contrast=1; 
goToSidePar = orientedGabors(pixPerCycsPar,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
ts_side_par = trainingStep(tmQuiet , goToSidePar, pc, sch);

%%% ts_side_locontr = go to side low contrast moderate spatial freq
pixPerCycs=32; contrast = 0.5; % above thresh for most rats with LGNs
goToSideLocontr = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
ts_side_locontr = trainingStep(tmQuiet , goToSideLocontr, pc, sch);

% ts_gotohor_param = go to HORIZ, VARY spatial freq
pixPerCycsPar=[4 8 16 32 64 128]; % sweep parametrically thru spatial freq
contrast=1; 
distractorOrientations=[0]; % vertical
goToHorPar = orientedGabors(pixPerCycsPar,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
% training step
ts_gotohor_par = trainingStep(tmQuiet , goToHorPar, pc, sch); 

% ts_gotohor_locontr = go to HORIZ,  low contrast moderate spatial freq
distractorOrientations=[0]; % vertical
pixPerCycs=32; contrast = 0.5; % above thresh for most rats with LGNs
goToHorLoContr = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
% training step
ts_gotohor_locontr  = trainingStep(tmQuiet , goToHorLoContr, pc, sch); 





%%% ts_081213 =  
pixPerCycs=[32 64]; contrast = 0.5; distractorOrientations=[]; 
% above thresh for most rats with LGNs
goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
ts_081213 = trainingStep(tmQuiet , goToSide, pc, sch);



%p=protocol('mixedbattery',{ts1, ts2, ts3,ts4, ts5}); 
% in use through 12/4/08
%1. ts1=earned free drinks
%2. ts2=easy dot motion
%3. ts3=go to side
%4. ts4=dot psychometric
%5. ts5=go to horizontal

% new protocol 12/4/08
% p2 = protocol('mixedbattery',{ts_fd, ts_dots, ts_side, ts_gotohor, ...
%     ts_dots, ts_dotpsych, ts_side_par, ts_side_locontr, ts_gotohor_par, ts_gotohor_locontr });
% %1. ts_fd=earned free drinks
%2. ts_dots=easy dot motion
%3. ts_side=go to side
%4. ts_gotohor = go to horizontal
%5. ts_dots=easy dot motion (again)
%6. ts_dotpsych = dot psychometric
% 12/11 add steps
% 7. ts_side_par (vary spatial freq)
% 8. ts_side_locontr (just above thresh for wt rats)
% 9. ts_gotohor_par (vary spatial freq)
% 10. ts_gotohor_locontr (just above thresh for wt rats)s

p3=protocol('thresh_side', {ts_081213});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE all COH1 rats are on same protocol
% added logging function 11/21/08
logPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrix\setup\setupPR',filesep);
cd(logPath)
fid=fopen('cohort1log.txt','a');
for i=1:length(ratIDs)
    subjObj = getSubjectFromID(r,ratIDs{i});
    if ismember(ratIDs{i},{'285','286','287','290', 'demo1'}), % rats that got lesions in COH 1
        %stepNum=1; %11/11/08 to initiate the post-lesion testing
        
%         switch ratIDs{i}, % values updated 12/11/08 PRs
%             %case '290', stepNum=2; %was 1 effective for post-SC lesion 12/6-12/8 
%             case '285', stepNum=7; %revisit gotoside then try gotohoriz
%             case '287', stepNum=7; %revisit gotoside then try gotohoriz
%                 
%             otherwise % DEFAULT no change
%                 stepNum = getLastTrainingStep(ratIDs{i},getPermanentStorePath(r));  
%         end
        
        %[subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'post lesion testing','pr');
        
       % [subjObj r]=setProtocolAndStep(subjObj,p2,1,0,1,stepNum,r,'post lesion testing','pr');
        
       % keeps running wrong step!! despreate attempt 12/13/08 to force onto correct step
       stepNum=1;
       [subjObj r]=setProtocolAndStep(subjObj,p3,1,1,1,stepNum,r,'post lesion testing','pr');
       fprintf(fid,'%s finished setting %s to step %d of p3\n', datestr(now),ratIDs{i},stepNum);
    else
        error('unexpected ID')
    end
end
fclose(fid)



