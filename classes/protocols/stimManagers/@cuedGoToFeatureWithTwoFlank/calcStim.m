function [stimulus updateSM out scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)
%this makes targets on one side and a distractor on the other, with
%flankers above and below each, total of six stims

updateSM=0;
type='timedFrames'; %will be set to a vector 
    %by virture of being a vector, not a string, will be treated as
    %timedFrames type
    
    %frameTimes=[stimulus.framesJustCue/2,stimulus.framesJustCue,stimulus.framesStimOn]; %edf divided the cue time in half -- impatient rats respond too early.  we should really prevent responses before stim (even after cue)
    %frameTimes=[2,4*stimulus.framesJustCue,stimulus.framesStimOn]; %edf hacked 

    frameTimes=[int8(1),int8(20),int8(20)(0)];
    type=frameTimes;

%scaleFactor = getScaleFactor(stimulus);
scaleFactor = 0; %makes it full screen

%interTrialLuminance = getInterTrialLuminance(stimulus);
interTrialLuminance = 0.5;


%edf: 11.15.06 realized we didn't have correction trials!
%changing below...

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager

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
            'correction trial!'
            targetPorts=trialRecords(end).targetPorts;
        else
            details.correctionTrial=0;
            targetPorts=responsePorts(ceil(rand*length(responsePorts)));
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
    
    %CALC CUE PARAMS
    ctr=[height/2 width/2 ];
    cueIsLeft=((rand>0.5)*2)-1;
    cueLoc=ctr-[0 round(cueIsLeft*stimulus.eccentricity/2*stimulus.cuePercentTargetEcc*width)];
    cueRect=[cueLoc(1)-stimulus.cueSize cueLoc(1)+stimulus.cueSize cueLoc(2)-stimulus.cueSize cueLoc(2)+stimulus.cueSize];
    details.cueIsLeft=cueIsLeft;
    

    %set variables for random selections
    a=size(stimulus.targetOrientations,2);
    b=size(stimulus.distractorOrientations,2);
    c=size(stimulus.flankerOrientations,2);
    
    d=size(stimulus.targetContrast,2);      %
    e=size(stimulus.distractorContrast,2);
    f=size(stimulus.flankerContrast,2);  
    %CONTRAST
    details.targetContrast=stimulus.targetContrast(Randi(d));
    if stimulus.leftYokedToRightTargetContrast
        details.distractorContrast=details.targetContrast;
    else
        details.distractorContrast=stimulus.distractorContrast(Randi(e));
    end
    details.flankerContrast=stimulus.flankerContrast(Randi(f));
    
    %ORIENTATION   - the logic for matching the stim to the the trial is done here
    %given the correct answer, and the location of the cue, choose the
    %orientation of the feature that is indicative of where to go
    details.goToOrient=stimulus.targetOrientations(1);
    details.goAwayFromOrient=stimulus.targetOrientations(2);
   
    if (cueIsLeft==1)
        if (responseIsLeft==1) %correct response would be left
            details.targetOrientation=details.goToOrient;
        elseif (responseIsLeft==-1) %correct response would be right
            details.targetOrientation=details.goAwayFromOrient
        else
            error('Invalid response side value. responseIsLeft must be -1 or 1.')
        end
    elseif (cueIsLeft==-1) %cueIsRight
        if (responseIsLeft==1) %correct response would be left
            details.targetOrientation=details.goAwayFromOrient
        elseif (responseIsLeft==-1) %correct response would be right
            details.targetOrientation=details.goToOrient;
        else
            error('Invalid response side value. responseIsLeft must be -1 or 1.')
        end
    else
        error('Invalid cue side value.')
        %yes cueIsLeft really does have to obtain -1 b/c it is used to plot L/R=ness
        %could make a new variable to do this, so logic is represented by
        %var name
    end
    
    details.distractorOrientation=stimulus.distractorOrientations(Randi(b));
    details.leftFlankerOrient=stimulus.flankerOrientations(Randi(c));
    if stimulus.leftYokedToRightFlankerOrientation
        details.rightFlankerOrient=details.leftFlankerOrient;
    else
        %draw from distribution again
        details.rightFlankerOrient=stimulus.flankerOrientations(Randi(c));
    end
    
    %SPATIAL PARAMS
    ecc=stimulus.eccentricity/2;
    dev=stimulus.flankerOffset*stimulus.stdGaussMask;  
    details.deviation=dev;    %stored
    details.eccentricity=stimulus.eccentricity; %stored
    
    %TEMPORAL PARAMS
    details.requestedNumberStimframes=type;
    
    %GRATING PARAMS
    details.stdGaussMask=stimulus.stdGaussMask;
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

      numPatchesInserted=6; 
      szY=size(stimulus.targetStim,1)
      szX=size(stimulus.targetStim,2)
      
      pos=round...
      ...%yPosPct                   yPosPct                       xPosPct              xPosPct
    ([ stimulus.targetYPosPct       stimulus.targetYPosPct        1/2-cueIsLeft*ecc    1/2-cueIsLeft*ecc;...    %target
       stimulus.targetYPosPct       stimulus.targetYPosPct        1/2+cueIsLeft*ecc    1/2+cueIsLeft*ecc;...    %distractor
       stimulus.targetYPosPct+dev   stimulus.targetYPosPct+dev    1/2-ecc              1/2-ecc;...              %left top
       stimulus.targetYPosPct-dev   stimulus.targetYPosPct-dev    1/2-ecc              1/2-ecc;...              %left bottom
       stimulus.targetYPosPct+dev   stimulus.targetYPosPct+dev    1/2+ecc              1/2+ecc;...              %right top
       stimulus.targetYPosPct-dev   stimulus.targetYPosPct-dev    1/2+ecc              1/2+ecc]...              %right bottom
      .* repmat([ height            height                        width         width],numPatchesInserted,1))...     %convert to pixel vals
      -  repmat([ floor(szY/2)     -(ceil(szY/2)-1 )               floor(szX/2) -(ceil(szX/2)-1)],numPatchesInserted,1); %account for patch size
      
      if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))
          width
          height
          pos
          error('At least one image patch is going to be off the screen.  Make patches smaller or closer together.')
      end
 
      stim=stimulus.mean(ones(height,width,3));
      
      %PRESTIM
      i=1;
      orientInd=find(stimulus.targetOrientations==details.targetOrientation);  % choose TARGET stim patch
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),2)+(stimulus.targetStim(:,:,orientInd)-stimulus.mean).*details.targetContrast;
      
      %MAIN STIM
      %this could be a for loop except variables are stored as named types...
      i=1;
      orientInd=find(stimulus.targetOrientations==details.targetOrientation);  % choose TARGET stim patch
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)+(stimulus.targetStim(:,:,orientInd)-stimulus.mean).*details.targetContrast;
       
      i=i+1;         
      orientInd=find(stimulus.distractorOrientations==details.distractorOrientation);  % choose DISTRACTOR stim patch
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)+(stimulus.distractorStim(:,:,orientInd)-stimulus.mean).*details.distractorContrast;

      i=i+1;
      orientInd=find(stimulus.flankerOrientations==details.rightFlankerOrient);  % choose RIGHT stim patch
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
      i=i+1;
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
      
      i=i+1;
      orientInd=find(stimulus.flankerOrientations==details.leftFlankerOrient);  % choose LEFT stim patch
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
      i=i+1;
      stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)=stim(pos(i,1):pos(i,2),pos(i,3):pos(i,4),3)+(stimulus.flankerStim(:,:,orientInd)-stimulus.mean)*details.flankerContrast;
       

      %RENDER CUE
      stim(cueRect(1)-stimulus.cueSize:cueRect(2)+stimulus.cueSize,cueRect(3)-stimulus.cueSize:cueRect(4)+stimulus.cueSize,1:3)=1-stimulus.cueLum; %edf added to make cue bigger and more contrasty
      stim(cueRect(1):cueRect(2),cueRect(3):cueRect(4),1:3)=stimulus.cueLum;
      %BW pix in corners for imagesc
      stim(1)=0; stim(2)=1;

out=stim;

