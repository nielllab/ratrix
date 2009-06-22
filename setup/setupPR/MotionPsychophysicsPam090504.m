function r= MotionPsychophysicsPam090504(r, ratIDs)
% diverged from r= setProtocolMotion090422(r, ratIDs)
% Pam's protocol please do not edit.
% split off rats 195+196 to MotionPsychophysicsEmily on 5/4/09. PR
% NOTE: prior to this date nonlinearlized monitor LUT was used
% on this protocol version monitors use linearlized LUT (but not calib for
% same monitor)

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';
% rats validated on this protocol
LGNLesionCohort={'307','309','297','298','299','302'};  

% sound manager 
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000), ...
    soundClip('trialStartSound','empty')});

% scheduer 
sch=noTimeOff(); % runs until swapper ends session

% graduation criterion
warmup_pc=performanceCriterion([0.8],int16([200]));
pc=performanceCriterion([0.85, 0.8],int16([200, 500]));

%reinforcement manager
rewardMultiplier    =	[20,80,150,250,350,500]; % changed 4/28/09 by PR from [50 100 200];
requestRewardSize   =	0; %1; CHANGED ON 4/28/09 TO 0 BY PR
doAllRequests       =	'first'; % changed to FIRST on 4/28/09 by PR  from 'all';
msPenalty           =	2000;
fractionSoundOn     =	1;
fractionPenaltySoundOn = 0.10; % changed 4/28/09 by PR was 0.25;
rewardScalar        =	1;
msAirpuff           =   0;

increasingRewards=rewardNcorrectInARow(rewardMultiplier,requestRewardSize, ...
    doAllRequests, msPenalty, fractionSoundOn, fractionPenaltySoundOn,...
    rewardScalar, msAirpuff);

%traial manager
percentCorrectionTrials=0.20; 
tm= nAFC(sm, percentCorrectionTrials,increasingRewards);

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
% traing step 0 trivial 'warm up' task
coherence=.85; speed=1; contrast=1; dot_size=3; % easy/optimal params
% stim manager
warmup=coherentDots(screen_width,screen_height,num_dots,... % same for all steps
    coherence,speed,contrast,dot_size,... % these change from step to step
    movie_duration,screen_zoom,maxWidth,maxHeight,percentCorrectionTrials);% same for all steps
clear coherence speed contrast dot_size  % make sure values aren't accidentally propagated
ts0_warmup = trainingStep(tm, warmup,warmup_pc, sch, svnRev, svnCheckMode);  

% training step 1 vary contrast, otherwise easy
coherence=.85;
speed=1;
contrast=[0.2 1]; % vary only contrast
dot_size=3;
varycontrast=...
    coherentDots(screen_width,screen_height,num_dots,... % same for all steps
    coherence,speed,contrast,dot_size,... % these change from step to step
    movie_duration,screen_zoom,maxWidth,maxHeight,percentCorrectionTrials);% same for all steps
 clear coherence speed contrast dot_size  % make sure values aren't accidentally propagated
 ts1_varycontrast = trainingStep(tm, varycontrast, pc, sch, svnRev, svnCheckMode);  
    
 
 
 % training step 2 vary contrast, otherwise easy
coherence=.85;
speed=1;
contrast=[1/256 0.5]; % from very low to moderate contrast
dot_size=3;
 varycontrast_low=...
    coherentDots(screen_width,screen_height,num_dots,... % same for all steps
    coherence,speed,contrast,dot_size,... % these change from step to step
    movie_duration,screen_zoom,maxWidth,maxHeight,percentCorrectionTrials);% same for all steps
 clear coherence speed contrast dot_size  % make sure values aren't accidentally propagated
 ts2_varycontrastlow = trainingStep(tm, varycontrast_low, pc, sch, svnRev, svnCheckMode);  
 
% protocol
p=protocol('motionpsychometricsPam090504',{ts0_warmup  ts1_varycontrast  ts2_varycontrastlow}); 

% assign rats to protocol
logPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrix\setup\setupPR',filesep);
cd(logPath)

thisIsANewProtocol=1; % typically 1
thisIsANewTrainingStep=1; % typically 0
thisIsANewStepNum=1;  %  typically 1
for i=1:length(ratIDs)
    subjObj = getSubjectFromID(r,ratIDs{i});
    if ismember(ratIDs{i},LGNLesionCohort) % see rat id's at top
        fid=fopen('Blindsightlog_PRserver.txt','a');
        %stepNum=2; % start all rats on step 2 5/4/09 PR FAILED bad LUT
        stepNum=3; % move all rats to step 3 on 5/5/09 PR HARDWIRED linear lut
        [subjObj r]=setProtocolAndStep(subjObj,p,...
             thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,... % added 4/28/09
             stepNum,r,'motion psychometrics','pr');
         fprintf(fid,'%s finished setting %s to step %d of motionpsychometricsPam090504\n', ...
             datestr(now),ratIDs{i},stepNum);
         fclose(fid)  
    elseif ismember(ratIDs{i},{'demo1','rack1test1','rack1test2','rack1test3'}),
        stepNum=1;
        [subjObj r]=setProtocolAndStep(subjObj,p,...
             thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,... % added 4/28/09
             stepNum,r,'motion psychometrics','pr');
    else
        error('unexpected ID')
    end
end
