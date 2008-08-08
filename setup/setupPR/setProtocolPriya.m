function r = setProtocolPriya(r,subjIDs, istest)
% OUTPUTS
%   r   a ratrix object
% INPUTS
%   r   a ratrix object
%   subjIDS     a cell array of strings specifying subject id's eg '194'
%   istest      boolean, default 0, if 1 use test subject params
% FUNCTIONS
%   sets parameters and creats trial manager, stim manager etc for  a
%   particular experiment, culminating in a protocol p that is applied to
%   the subjID's in the ratrix object r
% CALL BY
%   makeRatrix via standAloneTest, or by hand on main ratrix
% MAJOR CHANGE 080709 images method will now take explicit list of images &
% their probabilities as an argument

if ~exist('istest', 'var') || isempty(istest), 
    istest=0; end
%istest=1; %%%TESTMODE MANUAL%%%

%CHECK = things to check
% GRADUATION from free drinks seems to work downstairs but not in
% standalone mode upstairs??
% TO DO enable unnormalized stimuli, then insert after TS2?
% TO DO enable request makes stim stay until response (no toggle)
% TO DO makesilence sound subclass
% TO DO need to specify the morphed S+/S- pairs and their probabilities 

% params used by both freedrinks and gotostim trial managers
msFlushDuration =1000; %CHECK not used??
msMinimumPokeDuration   =10; %CHECK not used?
msMinimumClearDuration  =10; %CHECK not used?
maxWidth                =1024; % of the screen
maxHeight               =768; % of the screen
scaleFactor             =[1 1]; %show image at full size

%params of reinforcement manager
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 1;
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

svnRevision={'svn://132.239.158.177/projects/ratrix/tags/v0.6'};

%path containing ALL the stimuli
imdir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\TMPPriyaImageSet'
% '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\PriyaImageSet'; 
% execute separate file containing the lists for each trainingstep
% TMP enforces erik's naming scheme, for use with his checkImages 
imlist=PriyaImageSets; % populate struct, each training step has a field for its list
% each list is a cell array of cell arrays, passed to images

% params for all the NAFC trial managers
%NB LUT is set in CALCSTIM; image method uses ramp not linearized
%NB error stim set in ERRORSTIM; image method set to BLACK screen
msPenaltyNAFC          =2000;
requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0; %not used?
pokeToRequestStim=true; 
maintainPokeToMaintainStim=true; %CHECK  toggles?
msMaximumStimPresentationDuration=0; % unlimited duration
maximumNumberStimPresentations=0; % unlimited presentations
doMask=false; %CHECK not used?
%NOTE nAFC uses maxWidth, maxHeight and scaleFactor defined above
interTrialLuminance_nAFC = 0.3; %extremely brief during stim calculation
background_nAFC=0; % range 0-1; bg for images (should differ from error screen) **CHANGED 080707**
% note this is also the color of screen between toggles but does NOT
% determine pre-requst color.
ypos_nAFC=0; %location of image stimuli is near ports

%create graduation criterion object for nAFC trial managers
% if istest,
%     graduationCriterion=performanceCriterion([.8], int8([10])); %note performanceCriterion should check that these are ints!
% else % real training
%performanceCriterion is a subclass of class 'criteria'
% CHANGED by PR as per Bob's request on 7/29/08
graduationCriterion=performanceCriterion([0.85], int8([400])); 

%([.95, .85], int8([20,200]));
%will graduate a subject if he is 95% correct after 20 consecutive trials
%or if he is at least 85% correct after 200 consecutive trials
% end

laststep_crit=repeatIndefinitely();

 
%create sound manager object used by stochastic free drinks only
% no hissing sound when water clogs ports
smSTOCH=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','allOctaves',[],2000), ...
    soundClip('wrongSound','allOctaves',[],20000)}); %SILENCE

%create sound manager object used by all the other trial managers
sm =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','allOctaves',[],20000)}); %SILENCE

%create scheduer used by all trial managers
scheduler=noTimeOff(); %runs trials until rat logged off
%minutesPerSession is alternative 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS1 = stochastic free drinks
%create reinforcement manager object
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);
%create free drinks object (trial manager)
fd = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, stoch_freeDrinkLikelihood, reinfmanager);
%and associated stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%and associated training step
if istest, FDcriter = rateCriterion(3,1); % quick test mode 3 trialspermin 1 min
else FDcriter = rateCriterion(1,10); % for real training 1 trialpermin 10min
end

ts1 = trainingStep(fd, freeStim, FDcriter, scheduler,svnRevision);  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS2= free drinks rotate among ports
%use same reinforcement manager
%new trial manager for ts2
fd2 = freeDrinks(msFlushDuration,msMinimumPokeDuration,...
    msMinimumClearDuration,sm, earned_freeDrinkLikelihood, reinfmanager);
%use same stim manager as before
%define associated training step
if istest, FDcriter = rateCriterion(3,1); % quick test mode 3 trialspermin 1 min
else FDcriter = rateCriterion(3,10); % for real training  3 trialpermin 10min
end
ts2 = trainingStep(fd2, freeStim, FDcriter, scheduler,svnRevision); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS3=gotostim, natural objects NORMALIZED, TRAINING set NO DISTRACTOR
%create reinforcement manager object for all training steps
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyNAFC,... %different penalty duration
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);
%create nAFC object (trial manager)
gotostim=nAFC(msFlushDuration,msMinimumPokeDuration,...
    msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
    maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,reinfmanager);
%create the associated stim manager (gets images from path defined above)
%HELP: how to specify using only the 100% S+, no distrqactor
discrimStim3 = images(imdir,ypos_nAFC, background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.ts3);
%note hardwired in images() is definition of errorstim as black screen.
%define the associated training step
ts3 = trainingStep(gotostim, discrimStim3, graduationCriterion, scheduler,svnRevision);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS4=gotos+ ignore s-, natural objects NORMALIZED, TRAINING set 
%use same nAFC object (trial manager)
%create the associated stim manager (gets images from path defined above)
%using only target=100%S+, distractor=100%S-
discrimStim4 = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.ts4);
%define the associated training step
ts4 = trainingStep(gotostim, discrimStim4, laststep_crit, scheduler,svnRevision);
%graduationCriterion, changed to laststep_crit 8/6/08 because of suspcions
%about graduation not working properly
% should only affect rat 282

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS5=gotoS+, ignore S-, natural objects normalized, TEST set
%use same nAFC object trial manager
%differs from previous step only in the images used
%again using only target=100%S+, distractor=0%S+
% A and B reverse which is the S+ for different rats
discrimStim5A = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.ts5A);
ts5A = trainingStep(gotostim, discrimStim5A, graduationCriterion, scheduler,svnRevision);
discrimStim5B = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.ts5B);
ts5B = trainingStep(gotostim, discrimStim5B, graduationCriterion, scheduler,svnRevision);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS6=gotosS+ ignore S-, natural obj TEST set, mix in intermediate morphs
%as of now, chooses two at random and makes the one closer to the target
% the correct answer.
% DESIRED: designate specific target/distractor pairs
discrimStim6A = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.ts6A);
ts6A = trainingStep(gotostim, discrimStim6A,graduationCriterion, scheduler,svnRevision); %

discrimStim6B = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.ts6B);
ts6B = trainingStep(gotostim, discrimStim6B, graduationCriterion, scheduler,svnRevision); %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TS7=graduate, but keep doing TS6 trials forever
 
ts7A = trainingStep(gotostim, discrimStim6A,laststep_crit , scheduler,svnRevision);  
ts7B = trainingStep(gotostim, discrimStim6B, laststep_crit, scheduler,svnRevision);  


% HERE's THE PROTOCOL! two versions which differ in which is the target
% DO NOT CHANGE the training step list here, use setprotocolandstep to
% change step! 7/22/08 PR
pA=protocol('object rec', {ts1 ts2 ts3 ts4 ts5A ts6A ts7A}); %Grp A paintbrush is target
pB=protocol('object rec', {ts1 ts2 ts3 ts4 ts5B ts6B ts7B}); %Grp B flashlight is target

% % demote two subjs to free drinks on Friday 
% NOTE I should have set back the step, not made a new protocol with
% different steps!
% NOTE it looks like I set two subjects to protocol A one of which should
% have been protocol B! luckily the two protocols are the same up to the
% step used so far.
% for i=1:length(subjIDs),
%     subj=getSubjectFromID(r,subjIDs{i}); %extract the subject object
%     if ismember(subjIDs{i}, {'279'; '280'}),
%         [subj r]=setProtocolAndStep(subj,pA,1,0,1,1,r,date,'pr'); % half are A
%     else
%         sprintf('unknown subject %s\n', subjIDs{i}') % echo to screen
%         error('this rat is not assigned to any group. edit setProtocolPriya to assign.')
%     end
% end
%%%%%%%%%%%%

% % 080722 MODIFIED to add the paintbrush flashlight tasks (ts 5, 6 and 7)
% % restore all steps to the protocols and use the step index to set step
% % instead of deleting the steps already graduated.
% % so many confusing/unlogged changes before this,
% % save everything this once to document status.
% thisIsANewProtocol=1; % typically 1
% thisIsANewTrainingStep=1; % typically 0
% thisIsANewStepNum=1;  %  typically 1
% for i=1:length(subjIDs),
%     subj=getSubjectFromID(r,subjIDs{i}); %extract the subject object
%     % set the current step index here
%     switch subjIDs{i},
%         case '279', stepind=3; % 279 continue at step 3
%         case '280', stepind=4; % 280 continue at step 4 (already graduated but has been out of practice)
%         case '281', stepind=4; % 281 continue at step 4 (almost ready to grad)
%         case '282', stepind=2; % 282 continue at step 2  
%         case 'demo1', stepind=6; %demo test step
%     end
%     % assign to groups THIS CODE SHOULD NOT CHANGE!   
%     if ismember(subjIDs{i}, {'279'; '281'}), % GROUP A (279, 281)
%                 [subj r]=setProtocolAndStep(subj,pA,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepind,r,date,'pr');
%     elseif ismember(subjIDs{i}, {'280'; '282'; 'demo1'}),% GROUP B (280,282)
%                 [subj r]=setProtocolAndStep(subj,pB,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepind,r,date,'pr');
%     else
%         sprintf('unknown subject %s\n', subjIDs{i}') % echo to screen
%         error('this rat is not assigned to any group. edit setProtocolPriya to assign.')
%     end
% end


% % 080729 MODIFIED PR
% % change graduation criterion to 85% correct 400 in a row
% % demote some rats due to premature graduation
% thisIsANewProtocol=1; % typically 1
% thisIsANewTrainingStep=1; % typically 0
% thisIsANewStepNum=1;  %  typically 1
% for i=1:length(subjIDs),
%     subj=getSubjectFromID(r,subjIDs{i}); %extract the subject object
%     % set the current step index here
%     switch subjIDs{i},
%         case '279', stepind=2; % 279 DEMOTE to step 2 from 3 (not doing any trials)
%         case '280', stepind=4; % 280 DEMOTE to step 4  from 5 (premature grad)
%         case '281', stepind=7; % 281 continue at step 7 (doing well)
%         case '282', stepind=3; % 282 DEMOTE to step 3  (premature grad)
%         case 'demo1', stepind=6; %demo test step
%     end
%     
%     % assign to groups THIS CODE SHOULD NOT CHANGE!   
%     if ismember(subjIDs{i}, {'279'; '281'}), % GROUP A (279, 281)
%                 [subj r]=setProtocolAndStep(subj,pA,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepind,r,date,'pr');
%     elseif ismember(subjIDs{i}, {'280'; '282'; 'demo1'}),% GROUP B (280,282)
%                 [subj r]=setProtocolAndStep(subj,pB,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepind,r,date,'pr');
%     else
%         sprintf('unknown subject %s\n', subjIDs{i}') % echo to screen
%         error('this rat is not assigned to any group. edit setProtocolPriya to assign.')
%     end
% end


% 080808 MODIFIED PR
% don't trust grad criterion - change ts4 criterion to repeatindefinitely, and demote 282 to 4

thisIsANewProtocol=1; % typically 1
thisIsANewTrainingStep=1; % typically 0
thisIsANewStepNum=1;  %  typically 1
for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i}); %extract the subject object
    % set the current step index here
    switch subjIDs{i}, % only 283 will be called this time
         case '283', stepind=1; %new rat 283 added  
       % case '280', stepind=4; %  
       % case '281', stepind=7; % 
       % case '282', stepind=4; % 282 DEMOTE to step 4  (premature grad)
        case 'demo1', stepind=6; %demo test step
    end
    
    % assign to groups THIS CODE SHOULD NOT CHANGE!   
    if ismember(subjIDs{i}, {'283'; '281'}), % GROUP A (283, 281)
                [subj r]=setProtocolAndStep(subj,pA,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepind,r,date,'pr');
    elseif ismember(subjIDs{i}, {'280'; '282'; 'demo1'}),% GROUP B (280,282)
                [subj r]=setProtocolAndStep(subj,pB,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,stepind,r,date,'pr');
    else
        sprintf('unknown subject %s\n', subjIDs{i}') % echo to screen
        error('this rat is not assigned to any group. edit setProtocolPriya to assign.')
    end
end