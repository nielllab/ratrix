function [stimulus,updateSM,resInd,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance, text]=calcStim(stimulus, trialManagerClass,resolutions,screenDisplaySize,LUTbits,responsePorts,totalPorts,trialRecords);
%[stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance isCorrection] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,trialRecords)


%this makes a target that has feature to go right or left
%this is a discrimination paradigm
%a detection paradigm follows if the left stims have 0 contrast
%flankers above and below target, total of three stims

text='pmmStim';
details.screenDisplaySize=screenDisplaySize;


desiredWidth=getMaxWidth(stimulus);
desiredHeight=getMaxHeight(stimulus);
desiredHertz=100;
ratrixEnforcedColor=32;
appropriateSize=([resolutions.height]==desiredHeight) & ([resolutions.width]==desiredWidth) & ([resolutions.pixelSize]==ratrixEnforcedColor);
if sum(appropriateSize)>0
    hz=[resolutions.hz]
    maxHz=max(hz(appropriateSize));
    if maxHz==75
        selectedHz=60; %this enforces that some LCD's won't fail sync tests, but shouldn't influence any NEC CRT's
    else
        selectedHz=maxHz;
    end
    appropriateSizeAndRefresh=appropriateSize & ([resolutions.hz]==selectedHz)
    resInd=find(appropriateSizeAndRefresh);

%     if sum(appropriateSizeAndRefresh)==1
%         resInd=find(appropriateSizeAndRefresh);
%     elseif sum(appropriateSizeAndRefresh)>1
%         pixelSize=[resolutions.pixelSize];
%         selectedSize=min(pixelSize(appropriateSizeAndRefresh));
%         resInd=find(appropriateSizeAndRefresh & pixelSize==selectedSize);       
%     end
else 
    error ('can''t find appropriate resolution');
    end



details.width=resolutions(resInd).width
details.height=resolutions(resInd).height
details.pixelSize=resolutions(resInd).pixelSize
details.hz=resolutions(resInd).hz

width=details.width
height=details.height

details.LUTbits=LUTbits

%if resInd is different, updateSM

%record keeping
details.protocolType=stimulus.protocolType;
details.protocolVersion=stimulus.protocolVersion;
details.protocolSettings=datenum(stimulus.protocolSettings);

%setup for first trial...

if ~stimIsCached(stimulus)
    stimulus=inflate(stimulus);
    setSeed(stimulus, 'seedFromClock');
    updateSM=true;
else
    updateSM=false;
end

a=rand('seed');
b=randn('seed');
details.randomMethod='seedFromClock';
details.randomSeed=[a(end) b(end)]; %if using twister method, this single number is pretty meaningless

if ~isempty(stimulus.shapedParameter)
    [parameterChanged, stimulus]  = shapeParameter(stimulus, trialRecords); %will CopyOnWrite help?
    %else 'checkShape' and 'doShape' are different functions...
    if parameterChanged
        updateSM=true;
    end
    details.currentShapedValue=stimulus.shapingValues.currentValue; 
else
    details.currentShapedValue=nan; 
end

details.shapedParameter=stimulus.shapedParameter;
details.shapingMethod=stimulus.shapingMethod;
details.shapingValues=stimulus.shapingValues;  

details.toggleStim=stimulus.toggleStim;

frameTimes=[]; % Referenced below

if details.toggleStim==1
    type='trigger';
else
    % type='timedFrames'; %will be set to a vector
    %by virture of being a vector, not a string, will be treated as
    %timedFrames type

    %frameTimes=[stimulus.framesJustCue/2,stimulus.framesJustCue,stimulus.framesStimOn]; %edf divided the cue time in half -- impatient rats respond too early.  we should really prevent responses before stim (even after cue)
    %frameTimes=[1,4*stimulus.framesJustCue,stimulus.framesStimOn]; %edf hacked

    frameTimes=[stimulus.framesJustCue,stimulus.framesStimOn,int8(0)]; %pmm hacked
    type={'timedFrames',frameTimes}; % 040108 dfp changed format to cell array
end

%scaleFactor = getScaleFactor(stimulus);
scaleFactor = 0; %makes it full screen

interTrialLuminance = intmax(class(stimulus.flankerStim))*getInterTrialLuminance(stimulus);

LUT=getLUT(stimulus);
details.LUT=LUT;  % in future, consider saving a LUT id?
%interTrialLuminance = 0.5;

%edf: 11.15.06 realized we didn't have correction trials!
details.pctCorrectionTrials=0.5; % need to change this to be passed in from trial manager
%details.pctCorrectionTrials=stimulus.percentCorrectionTrials; % need to change this to be passed in from trial manager

details.maxCorrectForceSwitch=0;  % make sure this gets defined even if no trial records or free drinks

% if isempty(trialRecords) || ~any(strcmp('correctionTrial',fields(trialRecords(end).stimDetails)))
%     lastResponse=[];
%     lastCorrect=[];
%     lastWasCorrection=0;
%   else  
%     lastResponse=find(trialRecords(end).response);
%     lastCorrect=trialRecords(end).correct;
%     lastWasCorrection=trialRecords(end).stimDetails.correctionTrial;
%     if length(lastResponse)>1
%         lastResponse=lastResponse(1); % could be a value or 2 or 3 which influence freedrinks rewards, but not nAFC
%     end
% end

switch trialManagerClass
    case 'freeDrinks'

        targetPorts=setdiff(responsePorts,lastResponse);
        distractorPorts=[];

    case {'nAFC','promptedNAFC'}

        if ~isempty(trialRecords)
            lastRec=trialRecords(end);
        else
            lastRec=[];
        end
        [targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts);
        
        %note that this implementation will not show the exact same
        %stimulus for a correction trial, but just have the same side
        %correct.  may want to change...
        if details.correctionTrial
            details.maxCorrectForceSwitch=0;
        else
            [targetPorts hadToResample]=getSameLimitedResponsePort(responsePorts,stimulus.maxCorrectOnSameSide,trialRecords);  % add this to assignPorts
            details.maxCorrectForceSwitch=hadToResample;
        end
        
        
%         if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && (lastWasCorrection || rand<details.pctCorrectionTrials)
%             details.correctionTrial=1;
%             details.maxCorrectForceSwitch=0;
%             'correction trial!'
%             targetPorts=trialRecords(end).targetPorts;
%         else
%             details.correctionTrial=0;
% 
%             [targetPorts hadToResample]=getSameLimitedResponsePort(responsePorts,stimulus.maxCorrectOnSameSide,trialRecords);
%             details.maxCorrectForceSwitch=hadToResample;
%             %targetPorts=responsePorts(ceil(rand*length(responsePorts)));
%             %old random selection is now inside helper function -pmm
%         end

        %isCorrection = details.correctionTrial;

        distractorPorts=setdiff(responsePorts,targetPorts);
        targetPorts
    otherwise
        error('unknown trial manager class')
end


%CORRECT RESPONSE
if targetPorts==1
    responseIsLeft=1;
elseif targetPorts==3
    responseIsLeft=-1; % on the right
else
    targetPorts
    error('Targetports is inappropriate.  Stimulus is defined for 3 ports with one correct L/R answer')
    %i have never seen this happen -pmm 080504
    %one reason one could get here is if Center  and Left were blocked
    %during a correction trial that was right before manual graduation from freeDrinks, then lastResponse=lastResponse(1)
    % and target ports from the trial history was 2.  RARE. 
end
details.correctResponseIsLeft=responseIsLeft;

%CALC CUE PARAMS

ctr=[height/2 width/2 ];

%cueIsLeft=((rand>0.5)*2)-1;
%cueLoc=ctr-[0 round(cueIsLeft*stimulus.eccentricity/2*stimulus.cuePercentTargetEcc*width)];
%cueRect=[cueLoc(1)-stimulus.cueSize cueLoc(1)+stimulus.cueSize cueLoc(2)-stimulus.cueSize cueLoc(2)+stimulus.cueSize];
%details.cueIsLeft=cueIsLeft;


calibStim = 0; %The notion of calibration is only defined in later trialManager versions, hard coded here.
if ~calibStim
    %set variables for random selections
    a=Randi(size(stimulus.goRightOrientations,2));
    b=Randi(size(stimulus.goLeftOrientations,2));
    c=Randi(size(stimulus.flankerOrientations,2));
    z=Randi(size(stimulus.distractorOrientations,2));
    d=Randi(size(stimulus.goRightContrast,2));      %
    e=Randi(size(stimulus.goLeftContrast,2));
    f=Randi(size(stimulus.flankerContrast,2));
    g=Randi(size(stimulus.distractorContrast,2));
    h=Randi(size(stimulus.flankerOffset,2));
    p=Randi(size(stimulus.phase,2));
    pD=Randi(size(stimulus.phase,2));
    pF=Randi(size(stimulus.phase,2));
    m=Randi(size(stimulus.stdGaussMask,2));
    x=Randi(size(stimulus.pixPerCycs,2));
    fpa=Randi(size(stimulus.flankerPosAngle,2));
else %calibrationModeOn
    %use frame to set values a-h , p
    % [a b c d e f g h p] = selectStimulusParameters(trialManager);
     [a b c z d e f g h p pD pF m x] = selectStimulusParameters(stimulus);
    error('this should never happen, because there is no calibration mode');
    for i=1:10
        beep
    end
    %override side corrrect
    % responseIsLeft=-1; % on the right
    % details.correctResponseIsLeft=responseIsLeft;
end

%CONTRAST AND ORIENTATION
if responseIsLeft==1
    details.targetContrast=stimulus.goLeftContrast((e));
    details.targetOrientation=stimulus.goLeftOrientations((b));
elseif responseIsLeft==-1
    details.targetContrast=stimulus.goRightContrast((d));
    details.targetOrientation=stimulus.goRightOrientations((a));
else
    error('Invalid response side value. responseIsLeft must be -1 or 1.')
end

details.distractorContrast=stimulus.distractorContrast((g));
details.flankerContrast=stimulus.flankerContrast((f));
details.flankerOrientation= stimulus.flankerOrientations((c));
details.distratorOrientation = details.targetOrientation;



%FUTURE CHECKS FOR FLANKERS
if stimulus.topYokedToBottomFlankerContrast
    %details.topFlankerOrient=details.flankerOriention
    %details.bottomFlankerOrient=details.flankerOriention;
else
    %draw from distribution again
    error('currently undefined; topYokedToBottomFlankerContrast must be 1');
    c=Randi(size(stimulus.flankerOrientations,2)); %Can't use c because you have to resample in order to be unique.
    details.bottomFlankerOrient=stimulus.flankerOrientations((c));
end

if stimulus.topYokedToBottomFlankerOrientation
    %currently do nothing
else
    error('currently undefined; topYokedToBottomFlankerOreintation must be 1');
end

%FUTURE CHECKS FOR FLANKERS

if size(stimulus.flankerPosAngle,1)==1
    %if a vector, assume two flankers on opposite sides, with only one specified
    details.flankerPosAngles=[stimulus.flankerPosAngle(fpa) stimulus.flankerPosAngle(fpa)+pi];
    %currently the second value is just logged so that it's in the records;
    %it is not actually used in the computation - code assumes it's on the
    %opposite side
else 
    error ('only two flankers supported');
end

if stimulus.flankerYokedToTargetPhase  
    details.flankerPhase = stimulus.phase(p);
    details.targetPhase = stimulus.phase(p);
else
    details.targetPhase = stimulus.phase(p);
    details.flankerPhase = stimulus.phase(pF);
end

if stimulus.distractorYokedToTarget
    details.distractorPhase = details.targetPhase;
    details.distractorOrientation = details.targetOrientation;
else
    details.distractorPhase = stimulus.phase(pD);
    details.distractorOrientation = stimulus.distractorOrientations(z);
end

if stimulus.distractorFlankerYokedToTargetFlanker
    details.distractorFlankerContrast = details.flankerContrast;
    details.distractorFlankerOrientation = details.flankerOrientation;
    details.distractorFlankerPhase = details.flankerPhase;
else
    details.distractorFlankerContrast = details.flankerContrast;
    details.distractorFlankerOrientation = stimulus.flankerOrientations((c));
    details.distractorFlankerPhase = stimulus.phase(pF);
end
    
if stimulus.fractionNoFlanks>rand
    %set all flanker contrasts to be zero for a fraction of the trials
    details.flankerContrast=0;
    details.distractorFlankerContrast=0;
    details.hasFlanks=0;
else
    if details.flankerContrast>0 || details.distractorFlankerContrast>0
        details.hasFlanks=1;
    else
        details.hasFlanks=0;
    end
end


%SPATIAL PARAMS
%ecc=stimulus.eccentricity/2;

xPosPct=stimulus.xPositionPercent; % original line

%xPosPct=xPosPct+.2*randn*xPosPct; %edf added to tinker

dev = stimulus.flankerOffset(h)*stimulus.stdGaussMask;
devY = dev.*cos(stimulus.flankerPosAngle(fpa));
devX = dev.*sin(stimulus.flankerPosAngle(fpa)); 
nDevX= devX* (height/width); %normalized by the height:width ratio, so that when screen width is multiplied by the fraction x value, the linear displacement is appropriate 


details.deviation = dev;    %fractional devitation
details.devPix=[devY*getMaxHeight(stimulus) devX*getMaxHeight(stimulus) ];  %pixel deviation, note: horizontal is still normalized to screen vertical,
    %which is okay in square pixel world

details.patchX1=ceil(getMaxHeight(stimulus)*stimulus.stdGaussMask*stimulus.stdsPerPatch);
details.patchX2=size(stimulus.goLeftStim,2);

details.xPositionPercent=stimulus.xPositionPercent; %stored
details.yPositionPercent=stimulus.targetYPosPct; %stored

%TEMPORAL PARAMS
details.requestedNumberStimframes=frameTimes;

%GRATING PARAMS
details.stdGaussMask=stimulus.stdGaussMask(m);
details.stdGaussMaskPix=stimulus.stdGaussMask*ceil(getMaxHeight(stimulus));
radius=details.stdGaussMask;
details.pixPerCycs=stimulus.pixPerCycs(x);
details.gratingType=stimulus.gratingType;
%details.phase=rand*2*pi;  %all phases yoked together

%OLD WAY ON THE FLY
%     params=...
%  ...%radius             pix/cyc               phase           orientation                     contrast                      thresh           xPosPct                 yPosPct
%     [ radius    details.pixPerCycs    details.phase   details.targetOrientation       details.targetContrast        stimulus.thresh  1/2-cueIsLeft*ecc    stimulus.targetYPosPct;...
%       radius    details.pixPerCycs    details.phase   details.distractorOrientation   details.distractorContrast    stimulus.thresh  1/2+cueIsLeft*ecc    stimulus.targetYPosPct;...
%       radius    details.pixPerCycs    details.phase   details.leftFlankerOrient       details.flankerContrast       stimulus.thresh  1/2-ecc              stimulus.targetYPosPct+dev;...
%       radius    details.pixPerCycs    details.phase   details.leftFlankerOrient       details.flankerContrast       stimulus.thresh  1/2-ecc              stimulus.targetYPosPct-dev;...
%       radius    details.pixPerCycs    details.phase   details.rightFlankerOrient      details.flankerContrast       stimulus.thresh  1/2+ecc              stimulus.targetYPosPct+dev;...
%       radius    details.pixPerCycs    details.phase   details.rightFlankerOrient      details.flankerContrast       stimulus.thresh  1/2+ecc              stimulus.targetYPosPct-dev ];

% mainStim=computeGabors(params,'square',stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)));
% preStim=computeGabors(params(1,:),'square',stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)));
% VERY OLD EXAMPLE params = [repmat([stimulus.radius details.pixPerCyc],numGabors,1) details.phases details.orientations repmat([stimulus.contrast stimulus.thresh],numGabors,1) details.xPosPcts repmat([stimulus.yPosPct],numGabors,1)];

szY=size(stimulus.mask,1);
szX=size(stimulus.mask,2);
fracSizeX=szX/width;
fracSizeY=szY/height;
display (' @@@@@@@@@@@@@@@@@@@@ starting the while loop for stim shifts @@@@@@@@@@@@@@@@@@@@');
stimFit = 0;
resampleCounter = 0;
while stimFit == 0
    %%%%%%%%%% CREATE CENTERS %%%%%%%%%%%%%%
    if stimulus.displayTargetAndDistractor ==0
        numPatchesInserted=3;
        centers =...
            ...%yPosPct                      yPosPct                     xPosPct                   xPosPct
            [ stimulus.targetYPosPct       stimulus.targetYPosPct        xPosPct                   xPosPct;...                   %target
            stimulus.targetYPosPct+devY   stimulus.targetYPosPct+devY    xPosPct-nDevX             xPosPct-nDevX;...                   %top  (firstFlanker, on top if flankerPosAngle == 0)
            stimulus.targetYPosPct-devY   stimulus.targetYPosPct-devY    xPosPct+nDevX             xPosPct+nDevX];                     %bottom (secondFlanker, on bottom if flankerPosAngle == 0)

    elseif stimulus.displayTargetAndDistractor== 1
        numPatchesInserted=6;
        centers =...
            ...%yPosPct                         yPosPct                       xPosPct              xPosPct
            [ stimulus.targetYPosPct        stimulus.targetYPosPct          xPosPct                xPosPct;...                   %target
            stimulus.targetYPosPct+devY     stimulus.targetYPosPct+devY     xPosPct-nDevX          xPosPct-nDevX;...                   %top
            stimulus.targetYPosPct-devY     stimulus.targetYPosPct-devY     xPosPct+nDevX          xPosPct+nDevX ;...                   %bottom
            stimulus.targetYPosPct          stimulus.targetYPosPct          xPosPct                xPosPct;...                   %distractor
            stimulus.targetYPosPct+devY     stimulus.targetYPosPct+devY     xPosPct-nDevX          xPosPct-nDevX;...                   %top
            stimulus.targetYPosPct-devY     stimulus.targetYPosPct-devY     xPosPct+nDevX          xPosPct+nDevX ];                     %bottom
    else
        error('must be 0 or 1');
    end
    %%%%%%%%% END OF CREATE CENTERS %%%%%%%%%%%%%%%%%

    %%%%%%%%% DETERMINE SCREEN POSITIONS IN PIXELS %%%%%%%%%%%%%%%%

    pos = round(centers.* repmat([ height, height, width, width],numPatchesInserted,1)...          %convert to pixel vals
        -  repmat([ floor(szY/2), -(ceil(szY/2)-1 ), floor(szX/2) -(ceil(szX/2)-1)],numPatchesInserted,1)); %account for patch size

    xPixHint = round(stimulus.positionalHint * width)*sign(-responseIsLeft); % x shift value in pixels caused by hint
    detail.xPixShiftHint = xPixHint;
    if stimulus.displayTargetAndDistractor ==0
        hintOffSet= repmat([0, 0, xPixHint, xPixHint], numPatchesInserted, 1);
    else
        %first half move one direction, second half move the other
        hintOffSet= [repmat([0, 0,  xPixHint,  xPixHint], numPatchesInserted/2, 1);...
                     repmat([0, 0, -xPixHint, -xPixHint], numPatchesInserted/2, 1)];
    end
    pos = pos + hintOffSet;

    if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))
        width
        height
        xPixHint
        szY
        centers
        pos
        error('At least one image patch is going to be off the screen.  Make patches smaller or closer together or check the size of xPosHint.')
    end % check error without noise

    %%%%%%%%%%% ADD NOISE TERMS TO PIXEL POSITIONS %%%%%%%%%%%%%%%

    xPixShift = round(stimulus.xPosNoise * randn * width); % x shift value in pixels caused by noise
    yPixShift = round(stimulus.yPosNoise * randn * height); % y shift value in pixels caused by noise
    details.xPosNoisePix = xPixShift;
    details.yPosNoisePix = yPixShift;
    details.xPosNoiseSample = xPixShift/width;
    details.yPosNoiseSample = yPixShift/height;
    details.xPosNoiseStd = stimulus.xPosNoise;
    details.yPosNoiseStd = stimulus.yPosNoise;

    pos = pos + repmat([yPixShift, yPixShift, xPixShift, xPixShift], numPatchesInserted, 1);

    if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))
        resampleCounter = resampleCounter+1;
        display(sprintf('stimulus off screen because of noise, number of resamples = %d', resampleCounter));
        if resampleCounter > 10
            error('too many resamples, reconsider the size of the noise');
        end
    else
        stimFit = 1;
        details.stimRects = pos;
    end % check error with noise
end









try

    %stim class is inherited from flankstim patch
    %just check flankerStim, assume others are same
    if isinteger(stimulus.flankerStim)
        details.mean=stimulus.mean*intmax(class(stimulus.flankerStim));
    elseif isfloat(stimulus.flankerStim)
        details.mean=stimulus.mean; %keep as float
    else
        error('stim patches must be floats or integers')
    end
    stim=details.mean(ones(height,width,3,'uint8')); %the unit8 just makes it faster, it does not influence the clas of stim, rather the class of details determines that

    
    
    insertMethod='maskTimesGrating';
    details.insertMethod=insertMethod;
    
    
    
        %PRESTIM  - flankers first
        if details.flankerContrast > 0
            stim(:,:,1)=insertPatch(stimulus,insertMethod,stim(:,:,1),pos(2,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);
            stim(:,:,1)=insertPatch(stimulus,insertMethod,stim(:,:,1),pos(3,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);

            if stimulus.displayTargetAndDistractor == 1 % add distractor flankers on the opposite side y.z
                stim(:,:,1)=insertPatch(stimulus,insertMethod,stim(:,:,1),pos(5,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase,  details.pixPerCycs,details.mean,details.distractorFlankerContrast);
                stim(:,:,1)=insertPatch(stimulus,insertMethod,stim(:,:,1),pos(6,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase,  details.pixPerCycs,details.mean,details.distractorFlankerContrast);
            end
        end
        
        %MAIN STIM this could be a for loop except variables are stored
        %as named types...
        if responseIsLeft==1       % choose TARGET stim patch from LEFT candidates
            stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(1,:),stimulus.mask,stimulus.goLeftStim, stimulus.goLeftOrientations, stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.targetContrast);
            if stimulus.displayTargetAndDistractor == 1 % add distractor stimulus to the opposite side of the target y.z
                if stimulus.distractorYokedToTarget
                    stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(4,:),stimulus.mask,stimulus.goLeftStim, stimulus.goLeftOrientations, stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                else
                    stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(4,:),stimulus.mask,stimulus.distractorStim, stimulus.distractorOrientations, stimulus.phase, details.distractorOrientation, details.distractorPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                end
            end
        elseif responseIsLeft==-1 %% choose TARGET stim patch from RIGHT candidates
            stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(1,:),stimulus.mask,stimulus.goRightStim,stimulus.goRightOrientations,stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.targetContrast);
            if stimulus.displayTargetAndDistractor == 1 % add distractor stimulus to the opposite side of the target y.z
                if stimulus.distractorYokedToTarget
                    stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(4,:),stimulus.mask,stimulus.goRightStim, stimulus.goRightOrientations, stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                else
                    stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(4,:),stimulus.mask,stimulus.distractorStim, stimulus.distractorOrientations, stimulus.phase, details.distractorOrientation, details.distractorPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                end
            end
        else
            error('Invalid response side value. responseIsLeft must be -1 or 1.')
        end

        %and flankers
        if details.flankerContrast > 0
            stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(2,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);
            stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(3,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);
            if stimulus.displayTargetAndDistractor == 1
                stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(5,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase,  details.pixPerCycs,details.mean,details.distractorFlankerContrast);
                stim(:,:,2)=insertPatch(stimulus,insertMethod,stim(:,:,2),pos(6,:),stimulus.mask,stimulus.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase, details.pixPerCycs,details.mean,details.distractorFlankerContrast);
            end
        end

           
        %           %PRESTIM  - flankers first
        %           stim(:,:,1)=insertPatch(stim(:,:,1),pos(2,:),stimulus.flankerStim,stimulus.flankerOrientations, details.flankerOrientation, details.mean, details.flankerContrast);
        %           stim(:,:,1)=insertPatch(stim(:,:,1),pos(3,:),stimulus.flankerStim,stimulus.flankerOrientations, details.flankerOrientation, details.mean, details.flankerContrast);
        %
        %           %MAIN STIM this could be a for loop except variables are stored
        %           %as named types...
        %           if responseIsLeft==1       % choose TARGET stim patch from LEFT candidates
        %               stim(:,:,2)=insertPatch(stim(:,:,2),pos(1,:),stimulus.goLeftStim, stimulus.goLeftOrientations, details.targetOrientation, details.mean, details.targetContrast);
        %           elseif responseIsLeft==-1 %% choose TARGET stim patch from RIGHT candidates
        %               stim(:,:,2)=insertPatch(stim(:,:,2),pos(1,:),stimulus.goRightStim,stimulus.goRightOrientations,details.targetOrientation, details.mean, details.targetContrast);
        %           else
        %               error('Invalid response side value. responseIsLeft must be -1 or 1.')
        %           end
        %           %and flankers
        %           stim(:,:,2)=insertPatch(stim(:,:,2),pos(2,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation,details.mean,details.flankerContrast);
        %           stim(:,:,2)=insertPatch(stim(:,:,2),pos(3,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation,details.mean,details.flankerContrast);
        %
        %
        %       BEFORE THE FUNCTION CALL
        %           %PRESTIM  - flankers first
        %           i=2;
        %           orientInd=find(stimulus.flankerOrientations==details.flankerOrientation);  % choose top(check?) stim patch
        %           stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),1)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),1)+(stimulus.flankerStim(:,:,orientInd)-details.mean)*details.flankerContrast;
        %
        %           i=3;
        %           orientInd=find(stimulus.flankerOrientations==details.flankerOrientation);  % choose bottom(check?) stim patch
        %           stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),1)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),1)+(stimulus.flankerStim(:,:,orientInd)-details.mean)*details.flankerContrast;
        %
        %           %MAIN STIM this could be a for loop except variables are stored as named types...
        %
        %           i=1;   %the target
        %           if responseIsLeft==1
        %               orientInd=find(stimulus.goLeftOrientations==details.targetOrientation);  % choose TARGET stim patch from LEFT candidates
        %               stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.goLeftStim(:,:,orientInd)-details.mean).*details.targetContrast;
        %           elseif responseIsLeft==-1
        %               orientInd=find(stimulus.goRightOrientations==details.targetOrientation);  % choose TARGET stim patch from RIGHT candidates
        %               stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.goRightStim(:,:,orientInd)-details.mean).*details.targetContrast;
        %           else
        %               error('Invalid response side value. responseIsLeft must be -1 or 1.')
        %           end
        %
        %           i=2;
        %           orientInd=find(stimulus.flankerOrientations==details.flankerOrientation);  % choose top(check?) stim patch
        %           stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.flankerStim(:,:,orientInd)-details.mean)*details.flankerContrast;
        %
        %           i=3;
        %           orientInd=find(stimulus.flankerOrientations==details.flankerOrientation);  % choose bottom(check?) stim patch
        %           stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.flankerStim(:,:,orientInd)-details.mean)*details.flankerContrast;



        %OLD EXAMPLE FROM 6 gratings  -- things changed since then: details.mean instead of stimulus.mean
        %       i=i+1;
        %       orientInd=find(stimulus.goLeftOrientations==details.distractorOrientation);  % choose DISTRACTOR stim patch
        %       stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.distractorStim(:,:,orientInd)-stimulus.mean).*details.distractorContrast;
        %
        %       i=i+1;
        %       orientInd=find(stimulus.flankerOrientations==details.rightFlankerOrient);  % choose RIGHT stim patch
        %       stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
        %       i=i+1;
        %       stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
        %
        %       i=i+1;
        %       orientInd=find(stimulus.flankerOrientations==details.leftFlankerOrient);  % choose LEFT stim patch
        %       stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
        %       i=i+1;
        %       stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
        %

        %RENDER CUE - side cue not used, only fixation dot
        %stim(cueRect(1)-stimulus.cueSize:cueRect(2)+stimulus.cueSize,cueRect(3)-stimulus.cueSize:cueRect(4)+stimulus.cueSize,1:3)=1-stimulus.cueLum; %edf added to make cue bigger and more contrasty
        %stim(cueRect(1):cueRect(2),cueRect(3):cueRect(4),1:3)=stimulus.cueLum;
        if ~isempty(stimulus.cueLum)
            stim(height/2-stimulus.cueSize:height/2+stimulus.cueSize,width/2-stimulus.cueSize:width/2+stimulus.cueSize)=stimulus.cueLum*intmax(class(stim));
        end
        %BW pix in corners for imagesc
        cornerMarkerOn=1;
        if cornerMarkerOn
            stim(1)=0; stim(2)=255;
        end
        
        details.persistFlankersDuringToggle=stimulus.persistFlankersDuringToggle;


        switch trialManagerClass
            case 'phasedNAFC'
                %set to design specs

                
                % Initialization of stimSpecs and soundTypes - also decide how many progressive subphases you have here
                numProgressivePhases = 3; % NUMBER OF PROGRESSIVE SUBPHASES
                stimSpecs = cell(1, length(phases) + numProgressivePhases); % preallocate stimSpecs to be length of phases
                soundTypes = cell(1, length(phases) + numProgressivePhases); % preallocate soundTypes
                lengthOfStims = 0; % initialize lengthOfStims
                scaleFactors = cell(1,length(phases)+numProgressivePhases); % preallocate scaleFactors
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %...hmm the signature to calc stim has changed since fan wrote it...
                
                
            otherwise %nAFC or freedrinks

                if strcmp(type,'trigger') && details.toggleStim==1
                    %only send 2 frames if in toggle stim mode
                    out=stim(:,:,end-1:end);
                    if details.persistFlankersDuringToggle
                        out(:,:,end)=stim(:,:,1);  %alternate with a prestim that has flankers, so only target flashes
                    end
                else
                    %send all frames if in normal mode
                    out=stim;
                end

        end



        %grayscale sweep for viewing purposes
        drawColorBar=0;  %**add as a parameter in stimManager object
        if drawColorBar
            L=256; spacer=6;
            maxLumVal=double (intmax(class(stim)));  %have to do the uint8
            stim(end-(spacer+2):end-(spacer),end-(L+spacer):end-(1+spacer),1)=uint8(gray(L)'*maxLumVal);
            stim(end-(spacer+2):end-(spacer),end-(L+spacer):end-(1+spacer),2)=uint8(gray(L)'*maxLumVal);
        end

        %grayscale sweep where the target goes
        calibrateTest=0;  %**add as a parameter in stimManager object
        if calibrateTest  %(LUTBitDepth,colorSweepBitDepth,numFramesPerCalibStep-int8,useRawOrStimLUT,surroundContext-mean/black/stim,)

            %create lut
            LUTBitDepth=8;
            numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
            ramp=[0:fraction:1];
            LUT=[ramp;ramp;ramp]';  %pass a rawLUT to stimOGL
            LUT=getLUT(stimulus);   %use the LUT stimManager has

            colorSweepBitDepth=4;
            numColors=2^colorSweepBitDepth; maxRequestedColorID=numColors-1; fraction=1/(maxRequestedColorID);
            ramp=[0:fraction:1];
            % this is where you might consider: redColors=  [ramp;nada;nada]';
            colorIDs=ramp*maxColorID;  %currently doubles but will be uints when put into calibStim
            numColors=size(colorIDs,2);

            %calibStim=reshape(repmat(stim(:,:,1),1,numColors),height,width,numColors); % in context
            %calibStim=details.mean(ones(height,width,numColors,'uint8'));              % in mean screen
            calibStim=zeros(height,width,numColors,'uint8');                            % in black screen
            for i=1:numColors
                calibStim(pos(1,1):pos(1,2),pos(1,3):pos(1,4),i)=colorIDs(i);
            end

            numFramesPerCalibStep=int8(4);
            % type='timedFrames'; %will be set to a vector: by virture of being a vector, not a string, will be treated as timedFrames type
            frameTimes=numFramesPerCalibStep(ones(1,numColors));
            type={'timedFrames',frameTimes};

            out=calibStim;
        end


        catch

            sca
            ShowCursor;
            err=lasterror
            err.stack.line
            err.stack.name
            err.stack.file
            rethrow(lasterror);
end  


function stim=insertPatch(s,insertMethod,stim,pos,maskVideo,featureVideo,featureOptions1, featureOptions2,chosenFeature1, chosenFeature2 ,chosenFeature3,mean,contrast)

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
        %         size(featureVideo)
switch insertMethod
    
    
    case 'directPTB'
        error('not yet defined')
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
    case 'maskTimesGrating'
        %featureVideo is simply the mask at different sizes, must be a structure{}
        %maskInd = find(maskInd == chosenMask);
        maskInd = 1;
        patchX=ceil(getMaxHeight(s)*s.stdGaussMask(maskInd)*s.stdsPerPatch);  %stdGaussMask control patch size which control the radius 
        patchY=patchX;
            
        %       %radius      pixPerCyc      phase          %orientation
        params= [Inf      chosenFeature3  chosenFeature2   chosenFeature1     1    s.thresh  1/2     1/2   ];
        grating=computeGabors(params,0.5,patchX,patchY,s.gratingType,'normalizeVertical',1);
        grating=(grating-0.5);
        
        
        %contrast=contrast*contrastScale(s.gratingType,orientation,pixPerCyc)
        % %find a better way to get contrast and save it in stimDetails --
        % %trialManager version does this in the inflate
        % extraParams.contrastScale = ones(1,max([length(s.goRightOrientations) length(s.goLeftOrientations) length(s.flankerOrientations) length(s.distractorOrientations)])); %5th parameter is contrast

        %for a temp short cut, hardcode a look-up table per orientation right here,
        %as long as stimDetails has a record of it.... pmm
        %keep in mind it should be per spatial frequency too!

        
        
        WHITE=double(intmax(class(stim)));

        try
        patch=(WHITE*contrast)*(maskVideo.*grating);
        catch
            sca

            WHITE
            contrast
            size(maskVideo)
            size(grating)
            keyboard
        end
        
        above=zeros(size(patch),class(stim));
        below=above;
        above(sign(patch)==1)=(patch(sign(patch)==1));
        below(sign(patch)==-1)=(-patch(sign(patch)==-1));
        stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+above-below;
              
        %disp(['patch range ' num2str(min(patch(:))) ' to '
        %num2str(max(patch(:)))])
        %figure; imagesc(stim)     
        
    otherwise
        
        error ('unknown calculation method for inserting stim patches')
end

%   function stim=insertPatch(stim,pos,featureVideo,featureOptions,chosenFeature,mean,contrast)
%     featureInd=find(featureOptions==chosenFeature);
%     if isfloat(stim)
%           stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+(featureVideo(:,:,featureInd)-mean)*contrast;
%     elseif isinteger(stim)
%         %in order to avoide saturation of unsigned integers, feature patch
%         %is split into 2 channels: above and below mean
%         patch=( single(featureVideo(:,:,featureInd))-single(mean) )*contrast;
%         above=zeros(size(patch),class(stim));
%         below=above;
%         above(sign(patch)==1)=(patch(sign(patch)==1));
%         below(sign(patch)==-1)=(-patch(sign(patch)==-1));
%         stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+above-below;
%     end
%   end;
