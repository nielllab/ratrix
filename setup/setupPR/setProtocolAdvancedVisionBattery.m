function r = setProtocolAdvVisTest(r,subjIDs)
% OUTPUTS
%   r   a ratrix object
% INPUTS
%   r   a ratrix object
%   subjIDS     a cell array of strings specifying subject id's eg '194'
% FUNCTIONS
%   sets parameters and creats trial manager, stim manager etc for  a
%   particular experiment, culminating in a protocol p that is applied to
%   the subjID's in the ratrix object r
% revised 3/9/09 for new tag
%%%%%QUESTIONS 3/9 need to request support in each relevant calcstim 
% do stimuli toggle? 
% response time limit 
% max stim duration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

svnRevision={'svn://132.239.158.177/projects/ratrix/trunk'};
ValidRats={'307','309','297','298','299','302'};  % all rats that received LGN lesions in cohort 2 or 3 
demostep=3; % for testing: affects demo1 subject only

% params used by both freedrinks and gotostim trial managers
maxWidth                =1024; % of the screen
maxHeight               =768; % of the screen
scaleFactor             =[1 1]; %show image at full size

%params of reinforcement manager
requestRewardSizeULorMS=0;
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 0;
rewardScalar =1;
msPuff=0;
%params of freedrinks trial manager only
msPenaltyFD              =0; %no penalty during free drinks
stoch_freeDrinkLikelihood=0.006; %ts1 stochastic water emitted without licks
earned_freeDrinkLikelihood=0; % ts2 lick required

%params of stim manager used in free drinks (oriented gabors)
interTrialLuminance     =.5;  %gray screen between trials
mean                    =.5;
contrast                =0;%%% HERE make stimuli invisible
%ergo all the rest doesnt matter
pixPerCycs              =[20]; %spatial frequency value vector
targetOrientations      =[pi/2];
distractorOrientations  =[]; % if empty, no distractor
radius                  =.10;
thresh                  =.00005; %what is this?
yPosPct                 =.65;


%path containing ALL the stimuli
imdir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\preinagel\PRimageset' 
imlist=PR_ImageSet1; % populate struct, each training step has a field for its list  
 
% params for all the NAFC trial managers
%NB LUT is set in CALCSTIM; image method uses ramp not linearized
%NB error stim set in ERRORSTIM; image method set to BLACK screen
msPenaltyNAFC          =2000;
percentCorrectionTrials=.1; % LOW for post lesion tests
%NOTE nAFC uses maxWidth, maxHeight and scaleFactor defined above
interTrialLuminance_nAFC = 0.3; %extremely brief during stim calculation
background_nAFC=0; % range 0-1; bg for images (should differ from error screen) **CHANGED 080707**
% note this is also the color of screen between toggles but does NOT
% determine pre-requst color.
ypos_nAFC=0; %location of image stimuli is near ports

%create graduation criterion object for nAFC trial managers
graduationCriterion=performanceCriterion([.85 0.80], int16([200 300])); %85% correct for 200 consecutive trials

%create sound manager object used by stochastic free drinks only
%[correctSound, keepGoingSound,trySomethingElseSound, wrongSound]
smSTOCH=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
     soundClip('trySomethingElseSound','allOctaves',[],20000), ... % no white noise hiss
    soundClip('wrongSound','allOctaves',[50],20000)}); % tone

%create sound manager object used by all the other trial managers
sm =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
   soundClip('wrongSound','allOctaves',[50],20000)}); % tone

%create scheduer used by all trial managers
scheduler=minutesPerSession(120,3); % sch=noTimeOff();

% new in trunk 3/9/09
doAllRequests='first'; % only reward first request trial lick
%create FD reinforcement manager object
FDreinfmanager = constantReinforcement(rewardSizeULorMS,...
    requestRewardSizeULorMS,doAllRequests,... % NEW parameters
    msPenaltyFD,fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);
%create reinforcement manager object for all nAFC training steps
nAFCreinfmanager = constantReinforcement(rewardSizeULorMS,...
    requestRewardSizeULorMS,doAllRequests,... % NEW parameters
    msPenaltyNAFC,... %different penalty duration
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%freedrink1 = stochastic free drinks
%create free drinks object (trial manager)
%fd_sto = freeDrinks(sm,freeDrinkLikelihood,constantRewards);
fd = freeDrinks(smSTOCH, stoch_freeDrinkLikelihood, FDreinfmanager);
%and associated stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%and associated training step
FDcriter = rateCriterion(1,10); % for real training 1 trialpermin 10min
freedrink1 = trainingStep(fd, freeStim, FDcriter, scheduler,svnRevision);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%freedrink2= free drinks rotate among ports
%use same reinforcement manager
%new trial manager for ts2
fd2 = freeDrinks(sm, earned_freeDrinkLikelihood, FDreinfmanager);
%use same stim manager as before
%define associated training step
FDcriter = rateCriterion(3,10); % for real training  3 trialpermin 10min
freedrink2 = trainingStep(fd2, freeStim, FDcriter, scheduler,svnRevision); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec1=gotostim, natural objects  [go to Nike]
%create nAFC object (trial manager)
gotostim=nAFC(sm,percentCorrectionTrials,nAFCreinfmanager);
%create the associated stim manager (gets images from path defined above)
imageSelectionMode='normal'; % not deck
imageSize=[1 1]; % full size
imageSizeYoked=true; % images have same size
imageRotation=[0 0]; % upright
imageRotationYoked=false; % images have same size
drawingMode='expert';
imagelevel1 = images(imdir,ypos_nAFC, background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level1,...
    imageSelectionMode,imageSize,imageSizeYoked,imageRotation,imageRotationYoked,drawingMode);
objrec1 = trainingStep(gotostim, imagelevel1, graduationCriterion, scheduler,svnRevision);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% objrec2=gotos+ ignore s- [Nike Shuttle]
%use same nAFC object (trial manager)
imagelevel2 = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level2,...
    imageSelectionMode,imageSize,imageSizeYoked,imageRotation,imageRotationYoked,drawingMode);
%define the associated training step
objrec2 = trainingStep(gotostim, imagelevel2, graduationCriterion, scheduler,svnRevision); 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% objrec2invar=gotos+ ignore s- [Nike Shuttle]
%use same nAFC object (trial manager)
%but now vary size and orientation 
imageSelectionMode='normal'; % not deck
imageSize=[.5 1]; % uniformly between these sizes
imageSizeYoked=true; % images have same size
imageRotation=[-45 45]; % uniform between these angles
imageRotationYoked=false; % images have same size
imagelevel2invar = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level2,... % SAME images as prev step
    imageSelectionMode,imageSize,imageSizeYoked,imageRotation,imageRotationYoked,drawingMode);
%define the associated training step
objrec2invar = trainingStep(gotostim, imagelevel2invar, graduationCriterion, scheduler,svnRevision); 

%%%%%%%%%%%%%%%%%%%% motion training steps %%%%%%%%%%%%%%%%%%%%%%%
% %%% NOT TESTED NOT TESTED NOT TESTED
% 
% % params used by all coherent dots tasks
% %motionstimulus = coherentDots;
% %trialManagerClass='nAFC';
% %frameRate=100;
% %responsePorts=[1,3];
% %totalPorts=3;
% screen_width=100;
% screen_height=100;
% num_dots=100;
% movie_duration=10; % seconds??
% screen_zoom=[6 6];
% maxWidth=1024;
% maxHeight=768;
% 
% %%% motion1 = coherent dots 85% coherence only 
% coherence=[.85];
% speed=[1];
% contrast=[1];
% dot_size=[3];
% discrimStim1 = coherentDots(screen_width,screen_height,...
%     num_dots,coherence,speed,contrast,dot_size,movie_duration,screen_zoom,maxWidth,maxHeight);
%  % discrimStim1= coherentDots(maxWidth,maxHeight, 150, 100, 100, coherence, 1, 3, 10, 85, [6 6]);
% % use the same trial manager as other 2AFC tasks
% motion1 = trainingStep(gotostim, discrimStim1, graduationCriterion, scheduler,svnRevision);
%  

% %%% motion2 = coherent dots, harder
% %motion2 = makeDotTrainingStep([0.5 0.99]); % 70% threshold is ~0.6?
% coherence=[0.5 0.99];
% discrimStim2= coherentDots(stimulus,trialManagerClass,frameRate,...
%     responsePorts,totalPorts,maxWidth,maxHeight,[],...
%     150, 100, 100, coherence, 1, 3, 10, 85, [6 6]);
% motion2 = trainingStep(tmTEST, discrimStim2, pc,sch); %changed from tmEARLY 3/6
% 
% %%% motion3  = coherent dots psychometric curve  
% % many are below threshold!
% discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
%     responsePorts,totalPorts,maxWidth,maxHeight,[],...
%     150, 100, 100, [0.2 0.9], 1, 3, 10, 85, [6 6]);
% motion3 = trainingStep(tmTEST, discrimStimPsych, pc,sch); %changed from tmQUIET 3/6


%%%TO ADD%%
%grating psychophysics
%motion psychophysics
%invariance to flipped images, more distractors, etc

%%%PROTOCOLS%%%%%
 
pAdvTest=   protocol('advanced vision tests', {objrec1 objrec2 objrec2invar});  

%%%%%%%%%%%%
thisIsANewProtocol=1; % typically 1
thisIsANewTrainingStep=1; % typically 0
thisIsANewStepNum=1;  %  typically 1
stepind=1; % 3/9/09 starting point

logPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrix\setup\setupPR',filesep);
cd(logPath)
fid=fopen('Blindsightlog_PRserver.txt','a');
for i=1:length(subjIDs),
    subjObj = getSubjectFromID(r,subjIDs{i});
    if ismember(subjIDs{i},ValidRats) % define rat ID list at top of this file
        
        switch subjIDs{i},% set steps here
            case '297', stepNum=1; %
            case '298', stepNum=1; %
            case '299', stepNum=1; %
            case '302', stepNum=1; %
            case '307', stepNum=1; %
            case '309', stepNum=1; %
        end
        
        [subjObj r]=setProtocolAndStep(subjObj,pAdvTest,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepNum,r,'Advanced Vision Tests','pr');
        fprintf(fid,'%s finished setting %s to step %d of pAdvTest\n', datestr(now),subjIDs{i},stepNum);
    elseif ismember(subjIDs{i}, {'demo1'}),% for testing
        [subjObj r]=setProtocolAndStep(subjObj,pAdvTest,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,demostep,r,'Advanced Vision Tests','pr');
    else
        error('unexpected ID')
    end
end
fclose(fid)
