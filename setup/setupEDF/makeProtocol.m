function p=makeProtocol(name,istest)

%%%%%%%%%% stochastic free drinks

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};

if istest
    gc = rateCriterion(3,1); 
else
    gc = rateCriterion(3,5);
end

rewardSizeULorMS       =75;
msPenalty              =0;
fractionSoundOn        =1;
fractionPenaltySoundOn =1;
rewardScalar           =1;
msPuff                 =0;
rm = constantReinforcement(rewardSizeULorMS,msPenalty,fractionSoundOn,fractionPenaltySoundOn,rewardScalar,msPuff);

correctClip          =soundClip('correctSound','allOctaves',[400],20000);
keepGoingClip        =soundClip('keepGoingSound','allOctaves',[300],20000);
silentTryClip        =soundClip('trySomethingElseSound','allOctaves',[],1);
silentWrongClip      =soundClip('wrongSound','allOctaves',[],1);
sm=soundManager({correctClip,keepGoingClip,silentTryClip,silentWrongClip});

msFlushDuration         =1000; 
msMinimumPokeDuration   =10; 
msMinimumClearDuration  =10; 
freeDrinkLikelihood     =0.006;
fd = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,rm);

pixPerCycs              =[40];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.07;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.66;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

ts1=trainingStep(fd, freeStim, gc, noTimeOff(),svnRev);


%%%%%%%%%% nonstochastic free drinks

msPenalty              =2000;
rm = constantReinforcement(rewardSizeULorMS,msPenalty,fractionSoundOn,fractionPenaltySoundOn,rewardScalar,msPuff);

trySomethingElseClip =soundClip('trySomethingElseSound','gaussianWhiteNoise');
wrongClip            =soundClip('wrongSound','tritones',[300 400],20000);
sm =soundManager({correctClip,keepGoingClip,trySomethingElseClip,wrongClip});

freeDrinkLikelihood     =0;
fd = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,rm);

ts2=trainingStep(fd, freeStim, gc, noTimeOff(),svnRev);


%%%%%%%%%% go to side

requestRewardSizeULorMS             =0;
percentCorrectionTrials             =1;
msResponseTimeLimit                 =0;
pokeToRequestStim                   =true;
maintainPokeToMaintainStim          =true;
msMaximumStimPresentationDuration   =0;
maximumNumberStimPresentations      =0;
doMask                              =false;
gts=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,percentCorrectionTrials,...
    msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,rm);

if istest
    gc=performanceCriterion([.8], int8([10]));
else 
    gc=performanceCriterion([.95, .85], int8([20,200]));
end

radius                  =.12;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

ts3=trainingStep(gts, freeStim, gc, noTimeOff(),svnRev);

p=protocol(name,{ts1, ts2, ts3});