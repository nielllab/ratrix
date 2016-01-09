function r = setProtocolPriya(r,subjIDs)
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

% define rat cohorts 
% all rats that received LGN lesions in cohort 2 or 3
ValidRats={'307','309','297','298','299','302'};  
demostep=7; % affects demo1 subject only

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

%svnRevision={'svn://132.239.158.177/projects/ratrix/tags/v0.8'};

%path containing ALL the stimuli
imdir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\preinagel\PRimageset' 
imlist=PR_ImageSet1; % populate struct, each training step has a field for its list  
 
% params for all the NAFC trial managers
%NB LUT is set in CALCSTIM; image method uses ramp not linearized
%NB error stim set in ERRORSTIM; image method set to BLACK screen
msPenaltyNAFC          =2000;
requestRewardSizeULorMS=0;
percentCorrectionTrials=.1; % LOW for post lesion tests
msResponseTimeLimit=0; %not used?
pokeToRequestStim=true; 
maintainPokeToMaintainStim=true; %CHECK  toggles?
msMaximumStimPresentationDuration=5000; % limit to 5sec!
maximumNumberStimPresentations=0; % unlimited presentations
doMask=false; %CHECK not used?
%NOTE nAFC uses maxWidth, maxHeight and scaleFactor defined above
interTrialLuminance_nAFC = 0.3; %extremely brief during stim calculation
background_nAFC=0; % range 0-1; bg for images (should differ from error screen) **CHANGED 080707**
% note this is also the color of screen between toggles but does NOT
% determine pre-requst color.
ypos_nAFC=0; %location of image stimuli is near ports

%create graduation criterion object for nAFC trial managers
graduationCriterion=performanceCriterion([.85 0.80], int16([200 300])); %85% correct for 200 consecutive trials
handgrad_crit=repeatIndefinitely();

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
scheduler=minutesPerSession(120,3); % sch=noTimeOff();

%create FD reinforcement manager object
FDreinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);
%create reinforcement manager object for all nAFC training steps
nAFCreinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyNAFC,... %different penalty duration
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%freedrink1 = stochastic free drinks
%create free drinks object (trial manager)
fd = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, stoch_freeDrinkLikelihood, FDreinfmanager);
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
fd2 = freeDrinks(msFlushDuration,msMinimumPokeDuration,...
    msMinimumClearDuration,sm, earned_freeDrinkLikelihood, FDreinfmanager);
%use same stim manager as before
%define associated training step
FDcriter = rateCriterion(3,10); % for real training  3 trialpermin 10min
freedrink2 = trainingStep(fd2, freeStim, FDcriter, scheduler,svnRevision); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec1=gotostim, natural objects  [go to Nike]
%create nAFC object (trial manager)
gotostim=nAFC(msFlushDuration,msMinimumPokeDuration,...
    msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
    maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,nAFCreinfmanager);
%create the associated stim manager (gets images from path defined above)
imagelevel1 = images(imdir,ypos_nAFC, background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level1);
objrec1 = trainingStep(gotostim, imagelevel13, graduationCriterion, scheduler,svnRevision);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec2=gotos+ ignore s- [Nike Shuttle]
%use same nAFC object (trial manager)
imagelevel2 = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level2);
%define the associated training step
objrec2 = trainingStep(gotostim, imagelevel2, graduationCriterion, scheduler,svnRevision); 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec2invar=gotos+ ignore s- [Nike Shuttle]
%use same nAFC object (trial manager)
%but now vary orientation 
imagelevel2 = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level2);
%define the associated training step
objrec2 = trainingStep(gotostim, imagelevel2, graduationCriterion, scheduler,svnRevision); 
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec3 =gotos+ ignore s- [Nike Shuttle] INVARIANT TO MIRROR IMAGES!
%use same nAFC object (trial manager)
imagelevel3 = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level3);
%define the associated training step
objrec3 = trainingStep(gotostim, imagelevel3, graduationCriterion, scheduler,svnRevision); 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec4 =gotos+ ignore s- [Nike Shuttle] INVARIANT TO MIRROR IMAGES, MORE
%DISTRACTOR IMAGES
%use same nAFC object (trial manager)
imagelevel4 = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level4);
%define the associated training step
objrec4 = trainingStep(gotostim, imagelevel4, graduationCriterion, scheduler,svnRevision); 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%objrec4easy =gotos+ ignore s- [Nike Shuttle] 
%exactly like 4, but no mirror image target
imagelevel4easy = images(imdir,ypos_nAFC,background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level4easy);
%define the associated training step
objrec4easy = trainingStep(gotostim, imagelevel4easy, graduationCriterion, scheduler,svnRevision); 
 




%%%PROTOCOLS%%%%%
pAdvTest=   protocol('advanced vision tests', {});  

%%%%%%%%%%%%
thisIsANewProtocol=1; % typically 1
thisIsANewTrainingStep=1; % typically 0
thisIsANewStepNum=1;  %  typically 1
stepind=1; % 3/9/09 starting point

logPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrix\setup\setupPR',filesep);
cd(logPath)
fid=fopen('Blindsightlog_PRserver.txt','a');
for i=1:length(ratIDs)
    if ismember(ratIDs{i},ValidRats) % define rat ID list at top of this file
        subjObj = getSubjectFromID(r,ratIDs{i});
        switch ratIDs{i},% set steps here
            case '297', stepNum=1; %
            case '298', stepNum=1; %
            case '299', stepNum=1; %
            case '302', stepNum=1; %
            case '307', stepNum=1; %
            case '309', stepNum=1; %
        end

        [subjObj r]=setProtocolAndStep(subjObj,pTest,1,1,1,stepNum,r,'Advanced Vision Tests','pr');
        fprintf(fid,'%s finished setting %s to step %d of pAdvTest\n', datestr(now),ratIDs{i},stepNum);
    else
        error('unexpected ID')
    end
end
fclose(fid)
