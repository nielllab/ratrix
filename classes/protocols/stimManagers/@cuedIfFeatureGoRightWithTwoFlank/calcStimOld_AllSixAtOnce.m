function [stimulus updateSM out scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)
%this makes targets on one side and a distractor on the other, with
%flankers above and below each, total of six stims

updateSM=0;
type='timedFrames'; %will be set to a vector 
    %by virture of being a vector, not a string, will be treated as
    %timedFrames type
    frameTimes=[stimulus.framesJustCue,stimulus.framesJustCue,stimulus.framesStimOn];
    type=frameTimes;

%scaleFactor = getScaleFactor(stimulus);
scaleFactor = 0; %makes it full screen

%interTrialLuminance = getInterTrialLuminance(stimulus);
interTrialLuminance = 0.5;

switch trialManagerClass
    case 'freeDrinks'
        if ~isempty(trialRecords)
            lastResponse=find(trialRecords(end).response);
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
        end

        targetPorts=setdiff(responsePorts,lastResponse);
        distractorPorts=[];
        
    case 'nAFC'
        targetPorts=responsePorts(ceil(rand*length(responsePorts)));
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
        error('TargetportS S inappropriate.  Stimulus is defined for 3 ports with one correct L/R answer')
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
    
    
    params=...
 ...%radius             pix/cyc               phase           orientation                     contrast                      thresh           xPosPct                 yPosPct
    [ radius    details.pixPerCycs    details.phase   details.targetOrientation       details.targetContrast        stimulus.thresh  1/2-cueIsLeft*ecc    stimulus.targetYPosPct;...
      radius    details.pixPerCycs    details.phase   details.distractorOrientation   details.distractorContrast    stimulus.thresh  1/2+cueIsLeft*ecc    stimulus.targetYPosPct;...
      radius    details.pixPerCycs    details.phase   details.leftFlankerOrient       details.flankerContrast       stimulus.thresh  1/2-ecc              stimulus.targetYPosPct+dev;...
      radius    details.pixPerCycs    details.phase   details.leftFlankerOrient       details.flankerContrast       stimulus.thresh  1/2-ecc              stimulus.targetYPosPct-dev;...
      radius    details.pixPerCycs    details.phase   details.rightFlankerOrient      details.flankerContrast       stimulus.thresh  1/2+ecc              stimulus.targetYPosPct+dev;...
      radius    details.pixPerCycs    details.phase   details.rightFlankerOrient      details.flankerContrast       stimulus.thresh  1/2+ecc              stimulus.targetYPosPct-dev ];

  
%params = [repmat([stimulus.radius details.pixPerCyc],numGabors,1) details.phases details.orientations repmat([stimulus.contrast stimulus.thresh],numGabors,1) details.xPosPcts repmat([stimulus.yPosPct],numGabors,1)];
preStim=computeGabors(params(1,:),'square',stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)));
mainStim=computeGabors(params,'square',stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)));

stim=stimulus.mean(ones([size(mainStim) 3]));
stim(:,:,2)=preStim;
stim(:,:,3)=mainStim;
stim(cueRect(1):cueRect(2),cueRect(3):cueRect(4),1:3)=stimulus.cueLum;
stim(1)=0; stim(2)=1;

out=stim;

