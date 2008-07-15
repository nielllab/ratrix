function [t updateTM stimDetails stimSpec targetPorts details] = calcStimBeta(t,ifi,targetPorts,responsePorts,width,height,trialRecords)

if ~stimIsCached(t)
    t=inflate(t);
    setSeed(stimulus, 'seedFromClock');
    updateTM=1;
else
    updateTM=0;
end

a=rand('seed');
b=randn('seed');
details.randomMethod='seedFromClock';
details.randomSeed=[a(end) b(end)]; %if using twister method, this single number is pretty meaningless

%% choose ratrix standard verse PTB method
%this should be passed in during the dynamic mode
%firstTimeThisTrial=getNewTrialParameters 
%phase='discriminandum'; %{'session','trial','discriminandum','reward','penalty','final'}



%% start main

% choose parameters for this trial only 
firstTimeThisTrial=1;
if firstTimeThisTrial

%% CORRECT RESPONSE

    targetPorts=targetPorts; %someone else should tell me what this is! or I call the correlation manager?
    %[targetPorts hadToResample]=getSameLimitedResponsePort(responsePorts,t.maxCorrectOnSameSide,trialRecords)
    %stimDetails.maxCorrectForceSwitch=hadToResample;
    %targetPorts=responsePorts(ceil(rand*length(responsePorts)));

%     stimDetails.correctionTrial=correctionTrial;  %Todo: Can I get rid of this?
%     if stimDetails.correctionTrial
%     end

    if targetPorts==1
        responseIsLeft=1;
    elseif targetPorts==3
        responseIsLeft=-1; % on the right
    else
        targetPorts
        error('Targetports is inappropriate.  Stimulus is defined for 3 ports with one correct L/R answer')
    end
    stimDetails.correctResponseIsLeft=responseIsLeft;
%% Shaped Params

if ~isempty(t.shapedParameter)
   [parameterChanged t]  = shapeParameter(t, trialRecords)
   if parameterChanged
        updateTM = 1;
   end
end


%% set params
        
        calibStim=logical(t.calib.calibrationModeOn);
        if ~calibStim
            %set variables for random selections
            a=Randi(size(t.goRightOrientations,2));
            b=Randi(size(t.goLeftOrientations,2));
            c=Randi(size(t.flankerOrientations,2));
            z=Randi(size(t.distractorOrientations,2));
            d=Randi(size(t.goRightContrast,2));      %
            e=Randi(size(t.goLeftContrast,2));
            f=Randi(size(t.flankerContrast,2));
            g=Randi(size(t.distractorContrast,2));
            h=Randi(size(t.flankerOffset,2));
            p=Randi(size(t.phase,2));
            pD=Randi(size(t.phase,2));
            pF=Randi(size(t.phase,2));
        else %calibrationModeOn
            %use frame to set values a-h , p
            [a b c z d e f g h p pD pF] = selectStimulusParameters(t);
            %override side corrrect
            responseIsLeft=-1; % on the right
            stimDetails.correctResponseIsLeft=responseIsLeft;
        end

        %CONTRAST AND ORIENTATION
        if responseIsLeft==1
            stimDetails.targetContrast=t.goLeftContrast(e);
            stimDetails.targetOrientation=t.goLeftOrientations(a);
        elseif responseIsLeft==-1
            stimDetails.targetContrast=t.goRightContrast(d);
            stimDetails.targetOrientation=t.goRightOrientations(a);
        else
            error('Invalid response side value. responseIsLeft must be -1 or 1.')
        end

        stimDetails.distractorContrast=t.distractorContrast((g));
        stimDetails.flankerContrast=t.flankerContrast((f));
        stimDetails.flankerOrientation= t.flankerOrientations((c));
        stimDetails.distratorOrientation = stimDetails.targetOrientation;

        
%% CHECKS FOR FLANKERS
        if t.topYokedToBottomFlankerContrast
            %stimDetails.topFlankerOrient=stimDetails.flankerOriention
            %stimDetails.bottomFlankerOrient=stimDetails.flankerOriention;
        else
            %draw from distribution again
            error('currently undefined; topYokedToBottomFlankerContrast must be 1');
            c=Randi(size(t.flankerOrientations,2)); %Can't use c because you have to resample in order to be unique.
            stimDetails.bottomFlankerOrient=t.flankerOrientations((c));
        end

        if t.topYokedToBottomFlankerOrientation
            %currently do nothing
        else
            error('currently undefined; topYokedToBottomFlankerOreintation must be 1');
        end

        if t.flankerYokedToTargetPhase  
            stimDetails.flankerPhase = t.phase(p);
            stimDetails.targetPhase = t.phase(p);
        else
            stimDetails.targetPhase = t.phase(p);
            stimDetails.flankerPhase = t.phase(pF);
        end

        if t.distractorYokedToTarget
            stimDetails.distractorPhase = stimDetails.targetPhase;
            stimDetails.distractorOrientation = stimDetails.targetOrientation;
        else
            stimDetails.distractorPhase = t.phase(pD);
            stimDetails.distractorOrientation = t.distractorOrientations(z);
        end

        if t.distractorFlankerYokedToTargetFlanker
            stimDetails.distractorFlankerContrast = stimDetails.flankerContrast;
            stimDetails.distractorFlankerOrientation = stimDetails.flankerOrientation;
            stimDetails.distractorFlankerPhase = stimDetails.flankerPhase;
        else
            stimDetails.distractorFlankerContrast = stimDetails.flankerContrast;
            stimDetails.distractorFlankerOrientation = t.flankerOrientations((c));
            stimDetails.distractorFlankerPhase = t.phase(pF);
        end

        if t.fractionNoFlanks>rand
            %set all flanker contrasts to be zero for a fraction of the trials
            stimDetails.flankerContrast=0;
            stimDetails.distractorFlankerContrast=0;
            stimDetails.hasFlanks=0;
        else
            if stimDetails.flankerContrast>0 || stimDetails.distractorFlankerContrast>0
                stimDetails.hasFlanks=1;
            else
                stimDetails.hasFlanks=0;
            end
        end
     
        stimDetails.toggleStim=t.toggleStim;



%% calculate positions

        %choose screen size to compute stimulus at 
        if t.maxHeight==height & t.maxWidth==width
        height=t.maxHeight;
        width=t.maxWidth;
        else
            height=height
            width=width
            t.maxHeight
            t.maxWidth
            error ('this monitor doesn''t have the right screen size for the trialManager')
            %height=getMaxHeight(t)
        end

        %precompute short variables
        ctr=[height/2 width/2 ]; 
        xPosPct=t.xPositionPercent;
        devY = t.flankerOffset((h))*t.stdGaussMask;
        radius=t.stdGaussMask;
        szY=size(t.cache.mask,1);
        szX=size(t.cache.mask,2);
        fracSizeX=szX/width;
        fracSizeY=szY/height;
        display ('calculating stimulus patch positions, which may have noise');
        stimFit = 0;
        resampleCounter = 0;

        %these would be redundant with a deflated(t)
        stimDetails.xPositionPercent=t.xPositionPercent; %stored
        stimDetails.yPositionPercent=t.targetYPosPct; %stored
        stimDetails.framesTargetOnOff=t.framesTargetOnOff;
        stimDetails.framesFlankerOnOff=t.framesFlankerOnOff;
        stimDetails.stdGaussMask=t.stdGaussMask;
        stimDetails.pixPerCycs=t.pixPerCycs;
        stimDetails.gratingType=gratingType;

        %some computation required
        stimDetails.deviation = devY;    %fractional devitation
        stimDetails.devPix=devY*height; %pixel deviation
        stimDetails.patchX1=ceil(height*t.stdGaussMask*t.stdsPerPatch);
        stimDetails.patchX2=size(t.cache.mask,2);
        stimDetails.stdGaussMaskPix=t.stdGaussMask*ceil(height);

        while stimFit == 0
            %%%%%%%%%% CREATE CENTERS %%%%%%%%%%%%%%
            if t.displayTargetAndDistractor ==0
                numPatchesInserted=3;
                centers =...
                    ...%yPosPct                      yPosPct       xPosPct                   xPosPct
                    [ t.targetYPosPct       t.targetYPosPct        xPosPct                   xPosPct;...                   %target
                    t.targetYPosPct+devY   t.targetYPosPct+devY    xPosPct                   xPosPct;...                   %top
                    t.targetYPosPct-devY   t.targetYPosPct-devY    xPosPct                   xPosPct];                     %bottom

            elseif t.displayTargetAndDistractor== 1
                numPatchesInserted=6;
                centers =...
                    ...%yPosPct                         yPosPct       xPosPct             xPosPct
                    [ t.targetYPosPct        t.targetYPosPct          xPosPct             xPosPct;...                   %target
                    t.targetYPosPct+devY     t.targetYPosPct+devY     xPosPct             xPosPct;...                   %top
                    t.targetYPosPct-devY     t.targetYPosPct-devY     xPosPct             xPosPct;...                   %bottom
                    t.targetYPosPct          t.targetYPosPct          xPosPct             xPosPct;...                   %distractor
                    t.targetYPosPct+devY     t.targetYPosPct+devY     xPosPct             xPosPct;...                   %top
                    t.targetYPosPct-devY     t.targetYPosPct-devY     xPosPct             xPosPct];                     %bottom
            else
                error('must be 0 or 1');
            end

            %%%%%%%%% DETERMINE SCREEN POSITIONS IN PIXELS %%%%%%%%%%%%%%%%

            pos = round(centers.* repmat([ height, height, width, width],numPatchesInserted,1)...          %convert to pixel vals
                -  repmat([ floor(szY/2), -(ceil(szY/2)-1 ), floor(szX/2) -(ceil(szX/2)-1)],numPatchesInserted,1)); %account for patch size

            xPixHint = round(t.positionalHint * width)*sign(-responseIsLeft); % x shift value in pixels caused by hint
            detail.xPixShiftHint = xPixHint;
            if t.displayTargetAndDistractor ==0
                hintOffSet= repmat([0, 0, xPixHint, xPixHint], numPatchesInserted, 1);
            else
                %first half move one direction, second half move the other
                hintOffSet= [repmat([0, 0,  xPixHint,  xPixHint], numPatchesInserted/2, 1);...
                             repmat([0, 0, -xPixHint, -xPixHint], numPatchesInserted/2, 1)];
            end
            pos = pos + hintOffSet;

            if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))

                error('At least one image patch is going to be off the screen.  Make patches smaller or closer together or check the size of xPosHint.')
            end % check error without noise

            %%%%%%%%%%% ADD NOISE TERMS TO PIXEL POSITIONS %%%%%%%%%%%%%%%

            xPixShift = round(t.xPosNoise * randn * width); % x shift value in pixels caused by noise
            yPixShift = round(t.yPosNoise * randn * height); % y shift value in pixels caused by noise
            stimDetails.xPixShiftNoise = xPixShift;
            stimDetails.yPixShiftNoise = yPixShift;

            pos = pos + repmat([yPixShift, yPixShift, xPixShift, xPixShift], numPatchesInserted, 1);

            if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))
                resampleCounter = resampleCounter+1;
                display(sprintf('stimulus off screen because of noise, number of resamples = %d', resampleCounter));
                if resampleCounter > 10
                    error('too many resamples for stimulus patch position, reconsider the size of the noise');
                end
            else
                stimFit = 1;
                stimDetails.stimRects = pos;
                stimDetails.PTBStimRects = [pos(:, 3), pos(:, 1), pos(:, 4), pos(:, 2)];
            end % check error with noise
        end

%% prerender the stim

        %stim class is inherited from flankstim patch
        %just check flankerStim, assume others are same
        if isinteger(t.cache.mask)                   
            white=intmax(class(t.cache.mask));
        elseif isfloat(t.cache.mask)
            white=1;
        else
            error('stim patches must be floats or integers')
        end

         %PTB could define white differently, we rely on the convention of
         %255 and having int8s 
%         windowPtrs=Screen('Windows');
%         w=max(windowPtrs); %ToDo: w=t.window
%         white=WhiteIndex(w); %Todo: Move this to stimDetails in calcStim
    
        stimDetails.mean=t.mean;
        stimDetails.meanColor=t.mean*white;
        stimDetails.dimmingAmount=t.interTrialDimmingFraction*white;
        
        
    stimDetails.targetColor=white*stimDetails.targetContrast;
    stimDetails.flankerColor=white*stimDetails.flankerContrast;
    stimDetails.backgroundColor=stimDetails.meanColor;

    end %trial parameter setup
    

%% per frame data
if strcmp(t.renderMode,'directPTB')
    % this section should only be used for setup at the beginging of the trial
    
    
    % set defaults
    forceEasy = 0;
    noiseFlankers = 0;
    phase='trial';
    % modify per phase
    switch phase
        %case 'session'
        case 'trial'
        case 'discriminandum'
        case 'reward'
            forceEasy = 1;
        case 'penalty'
            forceEasy = 1;
            %case 'final'
        otherwise
            error ('unknown phase')
    end
    
    % override some parameters
    if forceEasy
        if t.targetContrast>0
            t.targetContrast = 1; % if visible, make obvious
        else
            t.targetContrast = 0; % it hidden, keep hidden
        end
    end
    
    if noiseFlankers
    end
    
    stimSpec=t.renderMode; %dynamic, expert
    details=[];

else

%% render the stim

empty=stimDetails.meanColor(ones(height,width,'uint8')); %the unit8 just makes it faster, it does not influence the clas of stim, rather the class of details determines that
insertMethod='matrixInsertion';
stimDetails.insertMethod=insertMethod;

flankersOnly=empty;
flankersOnly(:,:)=insertPatch(insertMethod,flankersOnly(:,:),pos(2,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.flankerOrientation, stimDetails.flankerPhase, stimDetails.meanColor,stimDetails.flankerContrast);
flankersOnly(:,:)=insertPatch(insertMethod,flankersOnly(:,:),pos(3,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.flankerOrientation, stimDetails.flankerPhase, stimDetails.meanColor,stimDetails.flankerContrast);
if t.displayTargetAndDistractor == 1 % add distractor flankers on the opposite side y.z
    flankersOnly(:,:)=insertPatch(insertMethod,flankersOnly(:,:),pos(5,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.distractorFlankerOrientation, stimDetails.distractorFlankerPhase, stimDetails.meanColor,stimDetails.distractorFlankerContrast);
    flankersOnly(:,:)=insertPatch(insertMethod,flankersOnly(:,:),pos(6,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.distractorFlankerOrientation, stimDetails.distractorFlankerPhase, stimDetails.meanColor,stimDetails.distractorFlankerContrast);
end
if ~t.cueLum==-1; %skip cue
    flankersOnly(height/2-t.cueSize:height/2+t.cueSize,width/2-t.cueSize:width/2+t.cueSize)=t.cueLum*intmax(class(empty));
end

targetOnly=empty;
%TARGET and DISTRACTOR this could be a for loop except variables are stored as named types...
if responseIsLeft==1       % choose TARGET stim patch from LEFT candidates
    targetOnly(:,:)=insertPatch(insertMethod,targetOnly(:,:),pos(1,:),t.cache.goLeftStim, t.goLeftOrientations, t.phase, stimDetails.targetOrientation, stimDetails.targetPhase, stimDetails.meanColor,stimDetails.targetContrast);
elseif responseIsLeft==-1 %% choose TARGET stim patch from RIGHT candidates
    targetOnly(:,:)=insertPatch(insertMethod,targetOnly(:,:),pos(1,:),t.cache.goRightStim,t.goRightOrientations,t.phase, stimDetails.targetOrientation, stimDetails.targetPhase, stimDetails.meanColor,stimDetails.targetContrast);
else
    error('Invalid response side value. responseIsLeft must be -1 or 1.')
end
if ~t.cueLum==-1; %skip cue
    targetOnly(height/2-t.cueSize:height/2+t.cueSize,width/2-t.cueSize:width/2+t.cueSize)=t.cueLum*intmax(class(empty));
end

targetAndDistractor=targetOnly;
if t.displayTargetAndDistractor == 1 % add distractor stimulus to the opposite side of the target y.z
    if responseIsLeft==1       % choose TARGET-equivalent DISTRACTOR stim patch from LEFT candidates
        if t.distractorYokedToTarget
            targetAndDistractor(:,:)=insertPatch(insertMethod,targetAndDistractor(:,:),pos(4,:),t.cache.goLeftStim, t.goLeftOrientations, t.phase, stimDetails.targetOrientation, stimDetails.targetPhase, stimDetails.meanColor,stimDetails.distractorContrast);
        else
            targetAndDistractor(:,:)=insertPatch(insertMethod,targetAndDistractor(:,:),pos(4,:),t.cache.distractorStim, t.distractorOrientations, t.phase, stimDetails.distractorOrientation, stimDetails.distractorPhase, stimDetails.meanColor,stimDetails.distractorContrast);
        end
    elseif responseIsLeft==-1 %% choose TARGET-equivalent DISTRACTOR stim patch from RIGHT candidates
        if t.distractorYokedToTarget
            targetAndDistractor(:,:)=insertPatch(insertMethod,targetAndDistractor(:,:),pos(4,:),t.cache.goRightStim, t.goRightOrientations, t.phase, stimDetails.targetOrientation, stimDetails.targetPhase, stimDetails.meanColor,stimDetails.distractorContrast);
        else
            targetAndDistractor(:,:)=insertPatch(insertMethod,targetAndDistractor(:,:),pos(4,:),t.cache.distractorStim, t.distractorOrientations, t.phase, stimDetails.distractorOrientation, stimDetails.distractorPhase, stimDetails.meanColor,stimDetails.distractorContrast);
        end
    end
end

targetAndFlankers=targetAndDistractor;
%FLANKER
targetAndFlankers(:,:)=insertPatch(insertMethod,targetAndFlankers(:,:),pos(2,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.flankerOrientation, stimDetails.flankerPhase, stimDetails.meanColor,stimDetails.flankerContrast);
targetAndFlankers(:,:)=insertPatch(insertMethod,targetAndFlankers(:,:),pos(3,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.flankerOrientation, stimDetails.flankerPhase, stimDetails.meanColor,stimDetails.flankerContrast);
if t.displayTargetAndDistractor == 1
    targetAndFlankers(:,:)=insertPatch(insertMethod,targetAndFlankers(:,:),pos(5,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.distractorFlankerOrientation, stimDetails.distractorFlankerPhase, stimDetails.meanColor,stimDetails.distractorFlankerContrast);
    targetAndFlankers(:,:)=insertPatch(insertMethod,targetAndFlankers(:,:),pos(6,:),t.cache.flankerStim,t.flankerOrientations, t.phase, stimDetails.distractorFlankerOrientation, stimDetails.distractorFlankerPhase, stimDetails.meanColor,stimDetails.distractorFlankerContrast);
end


        
%% build it to spec

        metaPixelSize = [1 1]; %{} means scale to fullScreen
        almostMeanScreen=stimDetails.meanColor+stimDetails.dimmingAmount;

        darkScreen=0;
        flashEasy=repmat(reshape([empty targetOnly],height,width,2),[1 1 (t.numPenaltyFlashes+1)]);
        flashTimes=[repmat(ceil(ifi*t.msPenaltyFlashDuration), 1, double(t.numPenaltyFlashes)) 0];

        silence=[];
        responsivePorts=[];
        goodTone=[];
        badTone=[];

        
        stimDetails.interSessionStim.stim =darkScreen;
        stimDetails.interSessionStim.metalPixelSize =[];
        stimDetails.interSessionStim.frameTimes =0;
        stimDetails.interSessionStim.frameSounds =silence;

        stimDetails.interTrialStim.stim =t.interTrialLuminance*white;
        stimDetails.interTrialStim.metalPixelSize =[];
        stimDetails.interTrialStim.frameTimes =0;
        stimDetails.interTrialStim.frameSounds =responsivePorts;

        if t.toggleStim
            if t.persistFlankersDuringToggle
            stimDetails.discriminandumStim.stim ={targetAndFlankers, flankersOnly};
            else
            stimDetails.discriminandumStim.stim ={targetAndFlankers, empty};
            end
            stimDetails.discriminandumStim.frameTimes =0;
            stimDetails.loopDiscriminandum=1;
        else
            stimDetails.discriminandumStim.stim =createDiscriminandumContextOnOffMovie(t,empty,targetOnly,flankersOnly,targetAndFlankers,t.framesTargetOnOff,t.framesFlankerOnOff);
            stimDetails.discriminandumStim.frameTimes =[getFrameChangeTimes(t) 0];
            stimDetails.loopDiscriminandum=1;
        end
        stimDetails.discriminandumStim.metalPixelSize =[1 1];
        stimDetails.discriminandumStim.frameSounds =responsivePorts;

        stimDetails.rewardWaitStim.stim =flashEasy;
        stimDetails.rewardWaitStim.metalPixelSize =[1 1];
        stimDetails.rewardWaitStim.frameTimes =flashTimes;
        stimDetails.rewardWaitStim.frameSounds =goodTone;
        
        stimDetails.rewardStim.stim =flashEasy;
        stimDetails.rewardStim.metalPixelSize =[1 1];
        stimDetails.rewardStim.frameTimes =flashTimes;
        stimDetails.rewardStim.frameSounds =goodTone;
        
        stimDetails.penaltyStim.stim =flashEasy;
        stimDetails.penaltyStim.metalPixelSize =[1 1];
        stimDetails.penaltyStim.frameTimes =flashTimes;
        stimDetails.penaltyStim.frameSounds =badTone;

        stimDetails.finalStim.stim =almostMeanScreen;
        stimDetails.finalStim.metalPixelSize =[];
        stimDetails.finalStim.frameTimes =0;
        stimDetails.finalStim.frameSounds =silence;
        
        stimDetails.CLUT=t.LUT;
        stimDetails.showScreenLabel=1;
        stimDetails.displayText=sprintf('orientation is: %d',stimDetails.targetOrientation*180/pi);
        stimDetails.reponseOptions.targetPorts=targetPorts;
        stimDetails.reponseOptions.distractorPorts=setdiff(responsePorts,targetPorts);
        
        stimDetails.requestOptions=2;
        stimDetails.maxInterTrialSecs=600;
        stimDetails.framePerRequest=0; %get all frames from one request
        stimDetails.maxDiscriminandumSecs=t.maxDiscriminandumSecs;
        stimDetails.advancedOnRequestEnd=t.advancedOnRequestEnd;
        stimDetails.maxRewardLatencySecs=2;

        stimSpec='standard'; %dynamic, expert
        details=[]; %this used to contain the per trials details and be small
        
        %question: how do we not save the giant stimuli but keep the
        %relevant details? Shouldn't there be a seperate location for the
        %large stimuli that are used but won't go into the records?
        %either: decache (stimDetails)
        %or: [stimDetails stimRecords]

        %stimSpec.extremeVals = [0 intmax(class(stim))]    %[dimmestVal brightestVal]

end

function stim=insertPatch(insertMethod,stim,pos,featureVideo,featureOptions1, featureOptions2,chosenFeature1, chosenFeature2,mean,contrast)

%   size (featureOptions1)
%   size (featureOptions2)
%   size (chosenFeature1)
%   size (chosenFeature2)
%   display('$$$$$$$$$$$')
%   featureOptions1=featureOptions1
%   chosenFeature1=chosenFeature1
%   featureOptions2=featureOptions2
%   chosenFeature2=chosenFeature2
%   featureOptions1 == chosenFeature1
%   featureOptions2 == chosenFeature2
%   featureInd1 = find(featureOptions1 == chosenFeature1)
%   featureInd2 = find(featureOptions2 == chosenFeature2)
%   size(featureVideo)

switch insertMethod
    case 'directPTB'

    case 'matrixInsertion'
        %insert in stim
        featureInd1 = find(featureOptions1 == chosenFeature1);
        featureInd2 = find(featureOptions2 == chosenFeature2);
        if isfloat(stim)
            stim(pos(1):pos(2),pos(3):pos(4)) = stim(pos(1):pos(2),pos(3):pos(4))+(featureVideo(:,:,featureInd1, featureInd2)-mean)*contrast;
        elseif isinteger(stim)
            %in order to avoide saturation of unsigned integers, feature patch
            %is split into 2 channels: above and below mean
            patch=( single(featureVideo(:,:,featureInd1, featureInd2))-single(mean) )*contrast;
            above=zeros(size(patch),class(stim));
            below=above;
            above(sign(patch)==1)=(patch(sign(patch)==1));
            below(sign(patch)==-1)=(-patch(sign(patch)==-1));
            stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+above-below;
        end
    otherwise
        error ('unknown calculation method for inserting stim patches')
end
