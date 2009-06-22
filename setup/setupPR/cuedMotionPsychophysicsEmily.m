function r= cuedMotionPsychophysicsEmily(r, ratIDs)
% diverged from MotionPsychophysicsEmily(r, ratIDs)
% on 5/27/09
% now this is only for 195 and 196 and is owned by Emily. PR.

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';
% rats validated on this protocol
dotRatCohort={'195','196'};

% sound manager 
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','empty'), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000),...
    soundClip('smallReward','allOctaves',[300],20000),...
    soundClip('jackpot','allOctaves',[500],20000),...
    soundClip('trialStartSound','empty')});

% scheduer 
sch=noTimeOff(); % runs until swapper ends session

% graduation criterion
warmup_pc=performanceCriterion([0.8],int16([200]));
pc=performanceCriterion([0.85, 0.8],int16([200, 500]));

%reinforcement manager
requestRewardSize   =	0; 
doAllRequests       =	'first'; 
msPenalty           =	2000;
fractionSoundOn     =	1;
fractionPenaltySoundOn = 0.10; 
rewardScalar        =	1;
msAirpuff           =   0;

rewards_and_probabilities = [50,500;.9,.1]; %Small reward, 90% of time; jackpot reward 10%.
cuedRewards = cuedReinforcement(rewards_and_probabilities(1,:),requestRewardSize,...
    doAllRequests,msPenalty,fractionSoundOn,fractionPenaltySoundOn,rewardScalar,msAirpuff);

%trial manager
delayMs=1000;
cDelay=constantDelay(delayMs);
responseWindowMs=[1000 Inf];
% t=nAFC(soundManager,percentCorrectionTrials,rewardManager,
%         [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%		  [delayManager],[responseWindowMs],[showText])

percentCorrectionTrials=0.10; 
tm= nAFC(sm, percentCorrectionTrials,cuedRewards,[],[],[],[],[],[],[],responseWindowMs,[]);

%%%% TRAINING STEPS HERE %%%%
% PARAMS  for all training steps
screen_width=100;
screen_height=100;
num_dots=100;
movie_duration=2; % question: does movie end or replay after 2sec?
screen_zoom=[6 6];
maxWidth=1024;
maxHeight=768;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% training step 1 vary coherence, Jackpot trials and small trials
rewards_and_probabilities = [50,500;.9,.1]; %Small reward, 90% of time; jackpot reward 10%.
sound_cues = {'smallReward','jackpot';200,300};

coherence=[.2 .8]; %vary only coherence
speed=1;
contrast=1; 
dot_size=3;
replayMode='loop';

coherenceJackpot=...
    cuedCoherentDots(screen_width,screen_height,num_dots,... % same for all steps
    coherence,speed,contrast,dot_size,movie_duration,rewards_and_probabilities,sound_cues,... % these change from step to step
    screen_zoom,maxWidth,maxHeight,percentCorrectionTrials,replayMode);% same for all steps
 clear coherence speed contrast dot_size replayMode delayMs  % make sure values aren't accidentally propagated
 ts1_coherenceJackpot = trainingStep(tm, coherenceJackpot, pc, sch, svnRev, svnCheckMode);  
   
 
% protocol
p=protocol('cuedMotionpsychometricsEmily090604',...
    {ts1_coherenceJackpot}); 
%090603 first step defined

% assign rats to protocol
logPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrix\setup\setupPR',filesep);
cd(logPath)

thisIsANewProtocol=1; % typically 1
thisIsANewTrainingStep=1; % typically 0
thisIsANewStepNum=1;  %  typically 1
for i=1:length(ratIDs)
    subjObj = getSubjectFromID(r,ratIDs{i});
    if ismember(ratIDs{i},dotRatCohort) % see rat id's at top
        fid=fopen('dotMastersLog.txt','a');
        %stepNum=1; % start all rats on step 1
        if ratIDs{i}=='195', stepNum=1; end 
        if ratIDs{i}=='196', stepNum=1; end 

        [subjObj r]=setProtocolAndStep(subjObj,p,...
            thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,... % added 4/28/09
            stepNum,r,'cued motion psychometrics','pr');
        fprintf(fid,'%s finished setting %s to step %d of cuedMotionPsychophysicsEmily\n', ...
            datestr(now),ratIDs{i},stepNum);
        fclose(fid);
    elseif ismember(ratIDs{i},{'demo1'}),
        stepNum=1;
        [subjObj r]=setProtocolAndStep(subjObj,p,...
             thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,... % added 4/28/09
             stepNum,r,'cued motion psychometrics','pr');
    else
        error('unexpected ID')
    end
end
