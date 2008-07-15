function [stimDetails frameRecords]=doUniqueRepeatDriftFrame(t,phase,stimDetails,frame,timeSinceTrial,eyeRecords,RFestimate, w)
%this would get called after a switch on the experiment field (class=UniqueRepeatDriftTwoFLank).  there is
%probably an dynamicObject and it might be a method on that 

%getExperimentParameters()
experiementClass='uniqueRepeatDriftTwoFlank';
targetDriftPixPerFrame = 1;
flankerDriftPixPerFrame= 1;
framesPerCondition=100;  %?calc this off of duration and ifi?
conditions={'aa','au','ab','aa','ua','uu'}

numConditions=length(conditions);

%calc conditionFrame
conditionFrame=mod(frame,framesPerCondition);
if conditionFrame==0
    conditionFrame=framesPerCondition; %mod works funny
end

%precache elsewhere, confirm cached with right rendermode & exptClass
% if frame ==1
%     if ~strcmp(t.renderMode,'directPTB')
%         error('cannot use pbt mode if trialManager is not set to the appropriate renderMode');
%         % current known conflict: inflate makes the wrong cache
%     end
% 
% end

%precache uniques here:
   U=rand(1,256)*255;
   UTex = screen('makeTexture',w,U);



% windowPtrs=Screen('Windows');
% w=max(windowPtrs); %ToDo: w=t.window

try
    %properties of screen
    filterMode=0; %0 = Nearest neighbour filtering, 1 = Bilinear
    modulateColor=[];
    textureShader=[];

    %setup
    texNum=0;
    typeInd = [];
    oInd = [];
    pInd = [];

    sca
keyboard

    destinationRect(texNum,:)=stimDetails.PTBStimRects(1,:); %target is 1, top is 2, bottom is 3
    destinationRect(texNum,:)=stimDetails.PTBStimRects(3,:); %top is 2, bottom is 3

     

    Screen('FillRect',w, stimDetails.backgroundColor);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


    noise = 0;
    if noise
        Screen('TransformTexture')

        droppedRecord=zeros(frames,1); % my responsibility or the ratrix's?
        drawTime=zeros(frames,1);
    end

    %draw the patches
    for n=1:size(oInd,2)
        screen('drawTexture',w,t.cache.orientationPhaseTextures(typeInd(n),oInd(n),pInd(n)),[],destinationRect(n,:),[],filterMode,globalAlpha(n),modulateColor,textureShader)
        %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader]);
    end
    Screen('DrawingFinished', w);

    frameRecords.xxx = [];  %ToDo: empirically test speed of saving frameRecords{i}.xxx outside this function versus frameRecords.xxx(i,:) inside this function

catch
    sca
    pInd
    oInd
    typeInd
    destinationRect
    globalAlpha
    err=lasterror
    err.stack.line
    err.stack.name
    err.stack.file
    ShowCursor;

    rethrow(lasterror);
end

