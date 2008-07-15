function r = makeRatrix(dataPath,standalone,rewardMethod)
% TO DO - switch code to use reward manager
% TO DO define stimuli to be blank or too small/faint to see
% TO DO enable unnormalized stimuli, to insert after TS2 
% TO DO enable request makes stim come on and stay until response
% TO DO makesilence sound subclass

%TO DO need to specify the morphed S+/S- pairs and their probabilities, EASY

%to make the screen black during errors I modified the errorstim.m
%file in the @images stimmanager subclass folder. 

%HELP  TO WRITE
%define the subjects and assign to boxes and training
%protocols - here just a matrix of the hardwired values
%used at bottom of this code

%NB LUT is set in CALCSTIM; we will use ramp not linearized

% params used by both freedrinks and gotostim trial managers
msFlushDuration =1000; %not used??
msMinimumPokeDuration   =10; %not used?
msMinimumClearDuration  =10; %not used?
maxWidth                =1280;
maxHeight               =1024;
scaleFactor             =[1 1]; %show image at full size

%params of reinforcement manager
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 1;
rewardScalar =1;

%params of freedrinks trial manager only
msPenaltyFD              =0;
stoch_freeDrinkLikelihood=0.006; %ts1 stochastic water emitted without licks
earned_freeDrinkLikelihood=0; % ts2 lick required

%params of stim manager used in free drinks (oriented gabors)
interTrialLuminance     =.5;  %gray screen between trials
mean                    =.5;
contrast                =0;%%% HERE make stimuli invisible
%ergo all the rest doesnt matter
pixPerCycs              =[20]; %spatial frequency will be randomly chosen from this vector
targetOrientations      =[pi/2];
distractorOrientations  =[]; % if empty, no distractor
radius                  =.10;
thresh                  =.00005; %what is this?
yPosPct                 =.65;

%path containing the training stimuli for task structure learning only
trainingset='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\trainingset\'; %TBD
%path containing the training stimuli for task structure learning only
trainingset2='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\trainingset2\'; %TBD
%path containing testing stimuli for real test
testset='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\paintbrush_flashlight\';
%path containing morphed series for real test
testset2='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\paintbrushMORPHflashlight\';

% params for all the NAFC trial managers
msPenaltyNAFC          =2000;
requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0; %not used?
pokeToRequestStim=true; 
maintainPokeToMaintainStim=true; % HELP  need to check into
   % true means stim appears whenever beam broken, or toggle?
msMaximumStimPresentationDuration=0; % means unlimited duration
maximumNumberStimPresentations=0; % means unlimited
doMask=false; % not used?
%NOTE nAFC uses maxWidth, maxHeight and scaleFactor defined above
interTrialLuminance_nAFC = 0.5; %GRAY bg between trials, distinct from error (black)
background_nAFC=0; %black bg for images
ypos_nAFC=0; %location of image stimuli is near ports

%create graduation criterion object for nAFC trial managers
%performanceCriterion is a subclass of class 'criteria'
graduationCriterion=performanceCriterion([.95, .85], int8([20,200])); %note performanceCriterion should check that these are ints!
%will graduate a subject if he is 95% correct after 20 consecutive trials
%or if he is at least 85% correct after 200 consecutive trials
 
%create sound manager object used by all the trial managers
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','allOctaves',[],20000)}); %WILL THIS WORK TO MAKE SILENCE?



%create scheduer used by all trial managers
scheduler=noTimeOff(); %runs trials until rat logged off
%minutesPerSession is alternative 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS1 = stochastic free drinks
%create reinforcement manager object
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
%create free drinks object (trial manager)
fd = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,sm, stoch_freeDrinkLikelihood, reinfmanager);
%and associated stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%and associated training step
ts1 = trainingStep(fd, freeStim, rateCriterion(1,10), scheduler); %%HARDWIRED 1 trialpermin 10min
    %HELP: does this know to ignore stochastically generated auto responses? 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS2= free drinks rotate among ports
%use same reinforcement manager
%new trial manager for ts2
fd2 = freeDrinks(msFlushDuration,msMinimumPokeDuration,...
    msMinimumClearDuration,sm, earned_freeDrinkLikelihood, reinfmanager);
%use same stim manager as before
%define associated training step
ts2 = trainingStep(fd2, freeStim, rateCriterion(3,10), scheduler); %%HARDWIRED 3 trialpermin 10min

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS3=gotostim, natural objects NORMALIZED, TRAINING set NO DISTRACTOR
%create reinforcement manager object for all training steps
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyNAFC,... %different penalty duration
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
%create nAFC object (trial manager)
gotostim=nAFC(msFlushDuration,msMinimumPokeDuration,...
    msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
    maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,reinfmanager);
%create the associated stim manager (gets images from path defined above)
%HELP: how to specify using only the 100% S+, no distrqactor
discrimStim1 = images(trainingset,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC);
%note hardwired in images() is definition of errorstim as black screen.
%define the associated training step
ts3 = trainingStep(gotostim, discrimStim1, graduationCriterion, scheduler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS4=gotos+ ignore s-, natural objects NORMALIZED, TRAINING set 
%use same nAFC object (trial manager)
%create the associated stim manager (gets images from path defined above)
%HELP: I want to specify using only target=100%S+, distractor=0%S+
discrimStim2 = images(trainingset2,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC);
%define the associated training step
ts4 = trainingStep(gotostim, discrimStim2, graduationCriterion, scheduler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS5=gotoS+, ignore S-, natural objects normalized, TEST set
%use same nAFC object trial manager
%differs from previous step only in the images used
%HELP: I want to specify using only target=100%S+, distractor=0%S+
discrimStim3 = images(testset,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC);
ts5 = trainingStep(gotostim, discrimStim3, graduationCriterion, scheduler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS6=gotosS+ ignore S-, natural obj TEST set, mix in intermediate morphs
%as of now, chooses two at random and makes the one closer to the target
% the correct answer.
discrimStim4 = images(testset2,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC);
ts6 = trainingStep(gotostim, discrimStim4, graduationCriterion, scheduler);


objectrec=protocol('object rec',{ts4}); %ts1 ts2 ts3 ts4 ts5 ts6});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%HELP  need code to add subjects to database, define their protocols
%ratrix() %run once first time?
%subject() %use hardwired values from above
%addSubject();
%protocol(); % specify sequence of training steps?
%setProtocolAndStep();

