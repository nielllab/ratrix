
function [stimulus,updateSM,resInd,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance, text]=...
    calcStim(stimulus, trialManagerClass,resolutions,screenDisplaySize,LUTbits,responsePorts,totalPorts,trialRecords,forceStimDetails);
%[stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance isCorrection] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,trialRecords)
%
%this makes a target that has feature to go right or left
%this is a discrimination paradigm
%a detection paradigm follows if the left stims have 0 contrast
%flankers above and below target, total of three stims
% 1/3/0/09 - trialRecords now includes THIS trial

text='pmmStim';
details.screenDisplaySize=screenDisplaySize;


%DETERMINE RESOLUTION
% [resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));
desiredWidth=getMaxWidth(stimulus);
desiredHeight=getMaxHeight(stimulus);
desiredHertz=100;
ratrixEnforcedColor=32;
if isempty(resolutions)
    resInd=nan;
    details.width=desiredWidth;
    details.height=desiredHeight;
    details.pixelSize=nan;
    details.hz=nan;
else
    appropriateSize=([resolutions.height]==desiredHeight) & ([resolutions.width]==desiredWidth) & ([resolutions.pixelSize]==ratrixEnforcedColor);
    if sum(appropriateSize)>0
        hz=[resolutions.hz];
        maxHz=max(hz(appropriateSize));
        if maxHz==75
            selectedHz=60; %this enforces that some LCD's won't fail sync tests, but shouldn't influence any NEC CRT's
        else
            selectedHz=maxHz;
        end
        appropriateSizeAndRefresh=appropriateSize & ([resolutions.hz]==selectedHz);
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

    details.width=resolutions(resInd).width;
    details.height=resolutions(resInd).height;
    details.pixelSize=resolutions(resInd).pixelSize;
    details.hz=resolutions(resInd).hz;
end

width=details.width;
height=details.height;
details.LUTbits=LUTbits;
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
    [parameterChanged, stimulus]  = shapeParameter(stimulus, trialRecords(1:end-1)); %will CopyOnWrite help?
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

%scaleFactor = getScaleFactor(stimulus);
scaleFactor = 0; %makes it full screen

% interTrialLuminance = intmax(class(stimulus.cache.flankerStim))*getInterTrialLuminance(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

LUT=getLUT(stimulus);
details.LUT=LUT;  % in future, consider saving a LUT id?
%interTrialLuminance = 0.5;

%edf: 11.15.06 realized we didn't have correction trials!
details.pctCorrectionTrials=stimulus.percentCorrectionTrials;
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

        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastRec=trialRecords(end-1);
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
            [targetPorts hadToResample]=getSameLimitedResponsePort(responsePorts,stimulus.maxCorrectOnSameSide,trialRecords(1:end-1));  % add this to assignPorts
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
    otherwise
        error('unknown trial manager class')
end

%CORRECT RESPONSE
if targetPorts==1
    details.correctResponseIsLeft=1;
elseif targetPorts==3
    details.correctResponseIsLeft=-1; % on the right
else
    targetPorts
    error('Targetports is inappropriate.  Stimulus is defined for 3 ports with one correct L/R answer')
    %i have never seen this happen -pmm 080504
    %one reason one could get here is if Center  and Left were blocked
    %during a correction trial that was right before manual graduation from freeDrinks, then lastResponse=lastResponse(1)
    % and target ports from the trial history was 2.  RARE.
end

%CALC CUE PARAMS
ctr=[height/2 width/2 ];
%cueIsLeft=((rand>0.5)*2)-1;
%cueLoc=ctr-[0 round(cueIsLeft*stimulus.eccentricity/2*stimulus.cuePercentTargetEcc*width)];
%cueRect=[cueLoc(1)-stimulus.cueSize cueLoc(1)+stimulus.cueSize cueLoc(2)-stimulus.cueSize cueLoc(2)+stimulus.cueSize];
%details.cueIsLeft=cueIsLeft;

%choose random or block if requested
[details a b c z d e f g h p pD pF m x fpa frto frfo] = selectStimulusParameters(stimulus,trialRecords(1:end-1),details);


%ASSUMPTIONS
if size(stimulus.flankerPosAngle,1)==1
    %if a vector, assume two flankers on opposite sides, with only one specified
    details.flankerPosAngles=[stimulus.flankerPosAngle(fpa) stimulus.flankerPosAngle(fpa)+pi];
    %currently the second value is just logged so that it's in the records;
    %it is not actually used in the computation - code assumes it's on the
    %opposite side
    % if changed, see switch on case 'flankerPosAngle' for forceStimDetails
    %also search for references to 'flankerPosAngles(1)'
    %and search hard coded reference to the field ''flankerPosAngles'' for example in setDynamicDetails(s,sweptID)
else
    error ('only two flankers supported');
end


%RELATIVE ORIENTATION ADJUSTMENTS
if ~isnan(stimulus.fpaRelativeTargetOrientation)
    %recalulate which orientation from relative orientation
    b=find(stimulus.goLeftOrientations==(details.flankerPosAngles(1)+stimulus.fpaRelativeTargetOrientation(frto)));
    a=find(stimulus.goRightOrientations==(details.flankerPosAngles(1)+stimulus.fpaRelativeTargetOrientation(frto)));
end

if ~isnan(stimulus.fpaRelativeFlankerOrientation)
    %recalulate which orientation from relative orientation
    c=find(stimulus.flankerOrientations==(details.flankerPosAngles(1)+stimulus.fpaRelativeFlankerOrientation(frfo)));
end

if isempty(a) || isempty(b) || isempty (c)
    error('should never happen')
end

%CONTRAST AND ORIENTATION
if details.correctResponseIsLeft==1
    details.targetContrast=stimulus.goLeftContrast((e));
    details.targetOrientation=stimulus.goLeftOrientations((b));
elseif details.correctResponseIsLeft==-1
    details.targetContrast=stimulus.goRightContrast((d));
    details.targetOrientation=stimulus.goRightOrientations((a));
else
    error('Invalid response side value. details.correctResponseIsLeft must be -1 or 1.')
end

details.distractorContrast=stimulus.distractorContrast((g));
details.flankerContrast=stimulus.flankerContrast((f));
details.distratorOrientation = details.targetOrientation;
details.flankerOrientation= stimulus.flankerOrientations((c)); %standard


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

details.stdGaussMask=stimulus.stdGaussMask(m);
details.pixPerCycs=stimulus.pixPerCycs(x);


%FORCE STIMULUS DETAILS -- USED IN NOT RATRIX ENVIRONMENT
if exist('forceStimDetails','var')
    if canForceStimDetails(stimulus,forceStimDetails)
        fsdf=fields(forceStimDetails);
        df=fields(details);
        for i=1:length(fsdf)
            switch fsdf{i}
                case 'flankerPosAngle' %special b/c two numbers are needed, but only one specified in compiled
                    details.flankerPosAngles= forceStimDetails.(fsdf{i}) + [0 pi];
                otherwise %everything else treated in the general case
                    if any(strcmp(df,fsdf{i}))
                        details.(fsdf{i})
                        details.(fsdf{i})=forceStimDetails.(fsdf{i}); %overwrite field
                        details.(fsdf{i})
                    else
                        error('not allowed to add a new field in force details!, just overwrite')
                    end
            end
        end
    else
        error('can''t force those stim details')
    end
end


%SPATIAL DETAILS
details.flankerOffset=stimulus.flankerOffset(h);
details.gratingType=stimulus.gratingType;
details.positionalHint=stimulus.positionalHint;
details.xPosNoiseStd = stimulus.xPosNoise;
details.yPosNoiseStd = stimulus.yPosNoise;
fitRF=0; % still in testing mode
if fitRF
    dataPath='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\Fan\datanet\demo2';
    % subjectID=
    % analysisPath=fullfile(c.dataRecordsPath, getID(subject), 'analysis');
    RFData=getNeuralAnalysis(dataPath,'last','RFEstimate');
    stimulus.fitRF.medianFilter=logical(ones(3));
    stimulus.fitRF.alpha=.05;



    sigSpots=getSignificantSTASpots(RFData.STA,sum(RFData.cumulativeSpikeCount),RFData.mean,RFData.contrast,stimulus.fitRF.medianFilter,stimulus.fitRF.alpha);
    if ~length(union(unique(sigSpots),[0 1]))==2
        error('more than one RF spot!')
    end

    %fake it for code
%%   
    stimParams = [ rand/3 4 0 pi/6 1 0.001 rand rand ];
    %STA=computeGabors(params,0.5,64,64,'square','normalizeVertical',0)-.48+ 0.05*randn(64,64);
    %sigSpots=abs(STA)>0.4;
    STA=computeGabors(stimParams,0.5,64,64,'square','normalizeVertical',0)+ 0.09*(randn(64,64) + 0.1);
    sigSpots=getSignificantSTASpots(STA,500,[],0.005);  
    
    %fit a guassian to the binary image -- conservative
    [sigEnvelope sigConservativeParams] =fitGaussianEnvelopeToImage(sigSpots,0.05,[],false,false);
    
    %use the conservative field to narrow a better seach of the STA
    [STAenvelope STAparams] =fitGaussianEnvelopeToImage(STA,0.05,sigEnvelope,false,false);
    
    mixIm=zeros([size(STA) 3]);
    
    mixIm(:,:,1)=1-sigSpots;
    mixIm(:,:,2)=(STA-min(STA(:)))/range(STA(:));
    mixIm(:,:,3)=1-STAenvelope;
    %mixIm(:,:,3)=1-sigEnvelope;
    image(mixIm)

    
    details.stdGaussMask=STAparams(4)*3;
    details.xPositionPercent=STAparams(1);
    details.yPositionPercent=STAparams(2);
    
    
    stimParams = [details.stdGaussMask 4 0 pi/6 1 0.001 STAparams(1:2) ]; % stim
    stim=computeGabors(stimParams,0.5,64,64,'square','normalizeVertical',0)+ 0.09*(randn(64,64) + 0.1);
    
    subplot(2,2,1); imagesc(STA)
    subplot(2,2,2); image(mixIm)
    subplot(2,2,3); image(mixIm)
    subplot(2,2,4); imagesc(stim-STAenvelope)
%% 
    %[bw params] =fitElipseToBinaryImage(sigSpots)

    %%
    details.stdGaussMask=a
    details.xPositionPercent=STAparams(1);
    details.yPositionPercent=STAparams(2);
else
    details.stdGaussMask=stimulus.stdGaussMask;
    details.xPositionPercent=stimulus.xPositionPercent;
    details.yPositionPercent=stimulus.targetYPosPct;
end    


details=computeSpatialDetails(stimulus,details);

details.targetOnOff=stimulus.targetOnOff;
details.flankerOnOff=stimulus.flankerOnOff;
                
if isinteger(stimulus.cache.flankerStim)
    details.mean=stimulus.mean*intmax(class(stimulus.cache.flankerStim));
elseif isfloat(stimulus.cache.flankerStim)
    details.mean=stimulus.mean; %keep as float
else
    error('stim patches must be floats or integers')
end
%stim class is inherited from flankstim patch
%just check flankerStim, assume others are same
            


%OLD WAY ON THE FLY
%ecc=stimulus.eccentricity/2;
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


details.renderMode=stimulus.renderMode;
switch details.renderMode
    case {'dynamic-precachedInsertion','dynamic-maskTimesGrating','dynamic-onePatchPerPhase','dynamic-onePatch'}
        details.backgroundColor=details.mean;
        details.floatprecision=1;
         type='expert'; 
         out=details;
         
         switch trialManagerClass
             case 'nAFC'
                 %how do i get rewardSizeULorMS and msPenalty inside calcStim?
                [stimSpecs scaleFactors] = phaseify(nAFC,stim,stimulus,type,targetPorts,distractorPorts,scaleFactor,rewardSizeULorMS,msPenalty,1/details.hz);
             
                %check this with fan:
                out=stimSpecs; 
                scaleFactor=scaleFactors;
                type='expert?  phased?'
             otherwise 
                 error('dynamic not tested in that mode yet')
         end
         
    case {'ratrixGeneral-maskTimesGrating', 'ratrixGeneral-precachedInsertion'}
        try

            stim=details.mean(ones(height,width,3,'uint8')); %the unit8 just makes it faster, it does not influence the clas of stim, rather the class of details determines that
            %details.insertMethod='maskTimesGrating'; %old name, now the same as 'ratrixGeneral-maskTimesGrating'

            %PRESTIM  - flankers first
            if details.flankerContrast > 0
                stim(:,:,1)=insertPatch(stimulus,details.renderMode,stim(:,:,1),details.stimRects(2,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);
                stim(:,:,1)=insertPatch(stimulus,details.renderMode,stim(:,:,1),details.stimRects(3,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);

                if stimulus.displayTargetAndDistractor == 1 % add distractor flankers on the opposite side y.z
                    stim(:,:,1)=insertPatch(stimulus,details.renderMode,stim(:,:,1),details.stimRects(5,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase,  details.pixPerCycs,details.mean,details.distractorFlankerContrast);
                    stim(:,:,1)=insertPatch(stimulus,details.renderMode,stim(:,:,1),details.stimRects(6,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase,  details.pixPerCycs,details.mean,details.distractorFlankerContrast);
                end
            end

            %MAIN STIM this could be a for loop except variables are stored
            %as named types...
            if details.correctResponseIsLeft==1       % choose TARGET stim patch from LEFT candidates
                stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(1,:),stimulus.cache.mask,stimulus.cache.goLeftStim, stimulus.goLeftOrientations, stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.targetContrast);
                if stimulus.displayTargetAndDistractor == 1 % add distractor stimulus to the opposite side of the target y.z
                    if stimulus.distractorYokedToTarget
                        stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(4,:),stimulus.cache.mask,stimulus.cache.goLeftStim, stimulus.goLeftOrientations, stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                    else
                        stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(4,:),stimulus.cache.mask,stimulus.cache.distractorStim, stimulus.distractorOrientations, stimulus.phase, details.distractorOrientation, details.distractorPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                    end
                end
            elseif details.correctResponseIsLeft==-1 %% choose TARGET stim patch from RIGHT candidates
                stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(1,:),stimulus.cache.mask,stimulus.cache.goRightStim,stimulus.goRightOrientations,stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.targetContrast);
                if stimulus.displayTargetAndDistractor == 1 % add distractor stimulus to the opposite side of the target y.z
                    if stimulus.distractorYokedToTarget
                        stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(4,:),stimulus.cache.mask,stimulus.cache.goRightStim, stimulus.goRightOrientations, stimulus.phase, details.targetOrientation, details.targetPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                    else
                        stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(4,:),stimulus.cache.mask,stimulus.cache.distractorStim, stimulus.distractorOrientations, stimulus.phase, details.distractorOrientation, details.distractorPhase,  details.pixPerCycs,details.mean,details.distractorContrast);
                    end
                end
            else
                error('Invalid response side value. details.correctResponseIsLeft must be -1 or 1.')
            end

            targetOnly=stim(:,:,2); % save a copy w/o flankers for the non-toggle movie creation mode

            %and flankers
            if details.flankerContrast > 0
                stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(2,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);
                stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(3,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.flankerOrientation, details.flankerPhase,  details.pixPerCycs,details.mean,details.flankerContrast);
                if stimulus.displayTargetAndDistractor == 1
                    stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(5,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase,  details.pixPerCycs,details.mean,details.distractorFlankerContrast);
                    stim(:,:,2)=insertPatch(stimulus,details.renderMode,stim(:,:,2),details.stimRects(6,:),stimulus.cache.mask,stimulus.cache.flankerStim,stimulus.flankerOrientations, stimulus.phase, details.distractorFlankerOrientation, details.distractorFlankerPhase, details.pixPerCycs,details.mean,details.distractorFlankerContrast);
                end
            end

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
            if  details.toggleStim==1 % when strcmp(type,'trigger')
                type={'trigger',toggleStim};
                frameTimes=[]; % saved to details
                %only send 2 frames if in toggle stim mode
                out=stim(:,:,end-1:end);
                if details.persistFlankersDuringToggle
                    out(:,:,end)=stim(:,:,1);  %alternate with a prestim that has flankers, so only target flashes
                end
                details.targetOnOff=nan;  % don't get used, so nan 'em to indicate it
                details.flankerOnOff=nan;
            else
                %OLD: sent all frames if in normal mode out=stim;
                %NEW: (relies on)
                %   empty=stim(:,:,3)
                %   targetOnly=targetOnly; saved a copy above...
                %   flankersOnly=stim(:,:,1)
                %   targetAndFlankers=stim(:,:,2)
                [out frameTimes]=createDiscriminandumContextOnOffMovie(stimulus,stim(:,:,3),targetOnly,stim(:,:,1),stim(:,:,2),details.targetOnOff,details.flankerOnOff);
                type={'timedFrames',frameTimes}; % 040108 dfp changed format to cell array
            end

            %TEMPORAL PARAMS
            details.requestedNumberStimframes=frameTimes;

        catch
            sca
            ShowCursor;
            err=lasterror
            err.stack.line
            err.stack.name
            err.stack.file
            rethrow(lasterror);
        end

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
%   size(featureVideo)
switch insertMethod
    case {'directPTB',{}}
        error('insertion happens in dynamic code!')
    case 'ratrixGeneral-precachedInsertion'
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
    case 'ratrixGeneral-maskTimesGrating'
        %featureVideo is simply the mask at different sizes, must be a structure{}
        %maskInd = find(maskInd == chosenMask);
        maskInd = 1;
        [patchX patchY]=getPatchSize(s);

        %       %radius      pixPerCyc      phase          %orientation
        params= [Inf      chosenFeature3  chosenFeature2   chosenFeature1     1    s.thresh  1/2     1/2   ];
        grating=computeGabors(params,0.5,patchX,patchY,s.gratingType,'normalizeVertical',1);
        grating=(grating-0.5);

        WHITE=double(intmax(class(stim)));
        patch=(WHITE*contrast)*(maskVideo.*grating);

        above=zeros(size(patch),class(stim));
        below=above;
        above(sign(patch)==1)=(patch(sign(patch)==1));
        below(sign(patch)==-1)=(-patch(sign(patch)==-1));
        stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+above-below;
        %disp(['patch range ' num2str(min(patch(:))) ' to '
        %num2str(max(patch(:)))]); figure; imagesc(stim)
    otherwise
        error ('unknown calculation method for inserting stim patches')
end
