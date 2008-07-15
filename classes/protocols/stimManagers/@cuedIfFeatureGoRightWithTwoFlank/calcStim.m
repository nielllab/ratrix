function [stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)
%this makes a target that has feature to go right or left
%this is a discrimination paradigm
%a detection paradigm follows if the left stims have 0 contrast
%total of four stims, vertically stacked in a totem
%target and distractor in the center between flankers which are above and below

updateSM=0;
   
    details.toggleStim=stimulus.toggleStim; 
    if details.toggleStim==1
        type='trigger';
    else
        type='timedFrames'; %will be set to a vector
        %by virture of being a vector, not a string, will be treated as
        %timedFrames type

        %frameTimes=[stimulus.framesJustCue/2,stimulus.framesJustCue,stimulus.framesStimOn]; %edf divided the cue time in half -- impatient rats respond too early.  we should really prevent responses before stim (even after cue)
        %frameTimes=[1,4*stimulus.framesJustCue,stimulus.framesStimOn]; %edf hacked

        frameTimes=[stimulus.framesJustCue,stimulus.framesStimOn,int8(0)]; %pmm hacked
        type=frameTimes;
    end
    
%scaleFactor = getScaleFactor(stimulus);
scaleFactor = 0; %makes it full screen

interTrialLuminance = getInterTrialLuminance(stimulus);

LUT=getLUT(stimulus);
details.LUT=LUT;  % in future, consider saving a LUT id?
%interTrialLuminance = 0.5;

%edf: 11.15.06 realized we didn't have correction trials!

details.pctCorrectionTrials=0.5; % need to change this to be passed in from trial manager

details.maxCorrectForceSwitch=0;  % make sure this gets defined even if no trial records or free drinks


if ~isempty(trialRecords)
    lastResponse=find(trialRecords(end).response);
    lastCorrect=trialRecords(end).correct;
    lastWasCorrection=trialRecords(end).stimDetails.correctionTrial;
    if length(lastResponse)>1
        lastResponse=lastResponse(1);
    end
else
    lastResponse=[];
    lastCorrect=[];
    lastWasCorrection=0;
end

switch trialManagerClass
    case 'freeDrinks'

        targetPorts=setdiff(responsePorts,lastResponse);
        distractorPorts=[];
        
    case 'nAFC'
        
        %note that this implementation will not show the exact same
        %stimulus for a correction trial, but just have the same side
        %correct.  may want to change...
        if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            details.maxCorrectForceSwitch=0;
            'correction trial!'
            targetPorts=trialRecords(end).targetPorts;
        else
            details.correctionTrial=0;
            [targetPorts hadToResample]=getSameLimitedResponsePort(responsePorts,stimulus.maxCorrectOnSameSide,trialRecords)
            details.maxCorrectForceSwitch=hadToResample;
            %targetPorts=responsePorts(ceil(rand*length(responsePorts)));
            %old random selection is now inside helper function -pmm  
        end
        
        
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
    end
    details.correctResponseIsLeft=responseIsLeft;
    

    %set variables for random selections
    a=size(stimulus.goRightOrientations,2);
    b=size(stimulus.goLeftOrientations,2);
    c=size(stimulus.flankerOrientations,2);
    
    d=size(stimulus.goRightContrast,2);      %
    e=size(stimulus.goLeftContrast,2);
    f=size(stimulus.flankerContrast,2); 
    g=size(stimulus.distractorContrast,2); 
    
    
    %CONTRAST AND ORIENTATION
    if responseIsLeft==1
        details.targetContrast=stimulus.goLeftContrast(Randi(e));
        details.targetOrientation=stimulus.goLeftOrientations(Randi(b));
    elseif responseIsLeft==-1
        details.targetContrast=stimulus.goRightContrast(Randi(d));
        details.targetOrientation=stimulus.goRightOrientations(Randi(a));
    else
        error('Invalid response side value. responseIsLeft must be -1 or 1.')
    end
    
   details.flankerContrast=stimulus.flankerContrast(Randi(f));
   details.distractorContrast=stimulus.distractorContrast(Randi(g));
   details.flankerOrientation= stimulus.flankerOrientations(Randi(c));
   
   %note: if doing a detection task, up to experimenter to make distractor
   %contrast intelligently related to goRightContrast and goLeftContrast
   %(maybe mimick same probability distribution of contrasts)
   
   if rand>0.5
      details.distractorSampledFromLeft=1;
      details.distractorOrientation=stimulus.goLeftOrientations(Randi(b));
   else
      details.distractorSampledFromLeft=0;
      details.distractorOrientation=stimulus.goRightOrientations(Randi(a));
   end
   
   %FUTURE CHECKS FOR FLANKERS
    if stimulus.topYokedToBottomFlankerOrientation
        %not using name but entries in a vector
        %details.bottomFlankerOrient=details.flankerOriention;
        %details.topFlankerOrient=details.flankerOriention
        details.flankerOrientation(2)= details.flankerOrientation(1)
    else
        %draw from distribution again
        details.flankerOrientation(2)=stimulus.flankerOrientations(Randi(c));  
    end
    
    if stimulus.topYokedToBottomFlankerContrast
        %currently do nothing
    else
        error('currently undefined; topYokedToBottomFlankerContrast must be 1');
    end
      
    
    %SPATIAL PARAMS
    %ecc=stimulus.eccentricity/2;
    xPosPct=stimulus.xPositionPercent;
    dev=stimulus.flankerOffset*stimulus.stdGaussMask;
    details.deviation=dev;    %fractional devitation
    details.devPix=dev*getMaxHeight(stimulus); %pixel deviation
    details.patchX1=ceil(getMaxHeight(stimulus)*stimulus.stdGaussMask*stimulus.stdsPerPatch);
    details.patchX2=size(stimulus.goLeftStim,2);
    details.xPositionPercent=stimulus.xPositionPercent; %stored
    details.yPositionPercent=stimulus.targetYPosPct; %stored
    
    

    %CALC CUE PARAMS
    ctr=[height/2 width/2 ];
    cueIsAbove=((rand>0.5)*2)-1;

    cueLoc1=ctr-[round(cueIsAbove*details.devPix/2)  round(2*stimulus.stdGaussMask*getMaxHeight(stimulus))];  %right side cue
    cueLoc2=ctr-[round(cueIsAbove*details.devPix/2) -round(2*stimulus.stdGaussMask*getMaxHeight(stimulus))];  %left side cue
    cueRect1=[cueLoc1(1)-stimulus.cueSize cueLoc1(1)+stimulus.cueSize cueLoc1(2)-stimulus.cueSize cueLoc1(2)+stimulus.cueSize];
    cueRect2=[cueLoc2(1)-stimulus.cueSize cueLoc2(1)+stimulus.cueSize cueLoc2(2)-stimulus.cueSize cueLoc2(2)+stimulus.cueSize];
    details.cueRect1=cueRect1;
    details.cueIsAbove=cueIsAbove;
    details.persistentCue=1; 
    
    %OLD CUE for 2 spatial choice
    %cueIsLeft=((rand>0.5)*2)-1;
    %cueLoc=ctr-[0 round(cueIsLeft*stimulus.eccentricity/2*stimulus.cuePercentTargetEcc*width)];
    %cueRect=[cueLoc(1)-stimulus.cueSize cueLoc(1)+stimulus.cueSize cueLoc(2)-stimulus.cueSize cueLoc(2)+stimulus.cueSize];
    %details.cueIsLeft=cueIsLeft;


    %TEMPORAL PARAMS
    details.requestedNumberStimframes=type;
    
    %GRATING PARAMS
    details.stdGaussMask=stimulus.stdGaussMask;
    details.stdGaussMaskPix=stimulus.stdGaussMask*ceil(getMaxHeight(stimulus));
    radius=stimulus.stdGaussMask;
    details.pixPerCycs=stimulus.pixPerCycs;
    details.phase=rand*2*pi;  %all phases yoked together
    
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

      numPatchesInserted=4; 
      szY=size(stimulus.goRightStim,1);
      szX=size(stimulus.goRightStim,2)
      devs(1)=dev*0.5;   %for target / distractor
      devs(2)=dev*1.5;   %for flankers
      details.devs=devs; %deviation from center of stimulus
      
      pos=round...
      ...%yPosPct                      yPosPct                            xPosPct  xPosPct
    ([ stimulus.targetYPosPct-devs(1)*cueIsAbove   stimulus.targetYPosPct-devs(1)*cueIsAbove    xPosPct  xPosPct;...                   %target
       stimulus.targetYPosPct+devs(2)              stimulus.targetYPosPct+devs(2)               xPosPct  xPosPct;...                   %bottom
       stimulus.targetYPosPct-devs(2)              stimulus.targetYPosPct-devs(2)               xPosPct  xPosPct;...                   %top
       stimulus.targetYPosPct+devs(1)*cueIsAbove   stimulus.targetYPosPct+devs(1)*cueIsAbove    xPosPct  xPosPct]...                   %distractor
      .* repmat([ height            height                        width         width],numPatchesInserted,1))...          %convert to pixel vals
      -  repmat([ floor(szY/2)      -(ceil(szY/2)-1 )             floor(szX/2) -(ceil(szX/2)-1)],numPatchesInserted,1);   %account for patch size
         
      if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))
          width
          height
          pos
          error('At least one image patch is going to be off the screen.  Make patches smaller or closer together.')
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
         
      
          %PRESTIM  - cues drawn first
          stim(cueRect1(1):cueRect1(2),cueRect1(3):cueRect1(4),1)=stimulus.cueLum;
          stim(cueRect2(1):cueRect2(2),cueRect2(3):cueRect2(4),1)=stimulus.cueLum;
          
          %MAIN STIM this could be a for loop except variables are stored as named types...
          
          %target
          if responseIsLeft==1       % choose TARGET stim patch from LEFT candidates
              stim(:,:,2)=insertPatch(stim(:,:,2),pos(1,:),stimulus.goLeftStim, stimulus.goLeftOrientations, details.targetOrientation,details.mean,details.targetContrast); 
          elseif responseIsLeft==-1 %% choose TARGET stim patch from RIGHT candidates
              stim(:,:,2)=insertPatch(stim(:,:,2),pos(1,:),stimulus.goRightStim,stimulus.goRightOrientations,details.targetOrientation,details.mean,details.targetContrast);
          else
              error('Invalid response side value. responseIsLeft must be -1 or 1.')
          end   
          
          %and distractor
          if details.distractorSampledFromLeft==1  % choose DISTRACTOR stim patch from LEFT candidates
              stim(:,:,2)=insertPatch(stim(:,:,2),pos(4,:),stimulus.goLeftStim, stimulus.goLeftOrientations, details.distractorOrientation,details.mean,details.distractorContrast);
          else %% choose DISTRACTOR stim patch from RIGHT candidates
              stim(:,:,2)=insertPatch(stim(:,:,2),pos(4,:),stimulus.goRightStim,stimulus.goRightOrientations,details.distractorOrientation,details.mean,details.distractorContrast);
          end
          
          %and flankers
          stim(:,:,2)=insertPatch(stim(:,:,2),pos(2,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation(1),details.mean,details.flankerContrast); %bottom
          stim(:,:,2)=insertPatch(stim(:,:,2),pos(3,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation(2),details.mean,details.flankerContrast); %top
      
          %and cue
          if details.persistentCue
              stim(cueRect1(1):cueRect1(2),cueRect1(3):cueRect1(4),2)=stimulus.cueLum;
              stim(cueRect2(1):cueRect2(2),cueRect2(3):cueRect2(4),2)=stimulus.cueLum;
          end
          
    %BEFORE DISTRACTOR WAS ADDED
%           %PRESTIM  - flankers first
%           stim(:,:,1)=insertPatch(stim(:,:,1),pos(2,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation,details.mean,details.flankerContrast);
%           stim(:,:,1)=insertPatch(stim(:,:,1),pos(3,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation,details.mean,details.flankerContrast);
%           
%           %MAIN STIM this could be a for loop except variables are stored
%           %as named types...
%           if responseIsLeft==1       % choose TARGET stim patch from LEFT candidates
%               stim(:,:,2)=insertPatch(stim(:,:,2),pos(1,:),stimulus.goLeftStim, stimulus.goLeftOrientations, details.targetOrientation,details.mean,details.targetContrast);  
%           elseif responseIsLeft==-1 %% choose TARGET stim patch from RIGHT candidates
%               stim(:,:,2)=insertPatch(stim(:,:,2),pos(1,:),stimulus.goRightStim,stimulus.goRightOrientations,details.targetOrientation,details.mean,details.targetContrast);
%           else
%               error('Invalid response side value. responseIsLeft must be -1 or 1.')
%           end   
%           %and flankers
%           stim(:,:,2)=insertPatch(stim(:,:,2),pos(2,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation,details.mean,details.flankerContrast);
%           stim(:,:,2)=insertPatch(stim(:,:,2),pos(3,:),stimulus.flankerStim,stimulus.flankerOrientations,details.flankerOrientation,details.mean,details.flankerContrast);
      
      
      %BEFORE THE FUNCTION CALL
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
      %stim(height/2-stimulus.cueSize:height/2+stimulus.cueSize,width/2-stimulus.cueSize:width/2+stimulus.cueSize)=stimulus.cueLum;
      
      %BW pix in corners for imagesc
      stim(1)=0; stim(2)=1;

     
     
     
    if strcmp(type,'trigger') && details.toggleStim==1
        %only send 2 frames if in toggle stim mode
        out=stim(:,:,1:2);
    else
        %send all frames if in normal mode
        out=stim;
    end
    
    %grayscale sweep for viewing purposes
    drawColorBar=1;  %**add as a parameter in stimManager object
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
        type='timedFrames'; %will be set to a vector: by virture of being a vector, not a string, will be treated as timedFrames type
        frameTimes=numFramesPerCalibStep(ones(1,numColors));
        type=frameTimes;

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
      
end
      
  function stim=insertPatch(stim,pos,featureVideo,featureOptions,chosenFeature,mean,contrast)
    featureInd=find(featureOptions==chosenFeature); 
    if isfloat(stim)
          stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+(featureVideo(:,:,featureInd)-mean)*contrast;
    elseif isinteger(stim)
        %in order to avoide saturation of unsigned integers, feature patch
        %is split into 2 channels: above and below mean
        patch=( single(featureVideo(:,:,featureInd))-single(mean) )*contrast;
        above=zeros(size(patch),class(stim));
        below=above;
        above(sign(patch)==1)=(patch(sign(patch)==1));
        below(sign(patch)==-1)=(-patch(sign(patch)==-1));
        stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+above-below;
    end      
  end

      
      
      
      