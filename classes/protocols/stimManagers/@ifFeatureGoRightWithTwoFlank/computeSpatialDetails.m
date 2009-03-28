function details=computeSpatialDetails(stimulus,details);
%for everything thats computed off of spatial details

%LOCAL VALUES - derive from details only (or unchanging stim values ~ constants)
height=details.height;
width=details.width;

[szX szY]=getPatchSize(stimulus);
fracSizeX=szX/width;
fracSizeY=szY/height;

dev = details.flankerOffset*details.stdGaussMask;
devY = dev.*cos(details.flankerPosAngles(1)); %caluate from details
devX = dev.*sin(details.flankerPosAngles(1));
nDevX= devX* (height/width); %normalized by the height:width ratio, so that when screen width is multiplied by the fraction x value, the linear displacement is appropriate

%compute and save some details too
details.deviation = dev;    %fractional devitation
details.devPix=[devY*getMaxHeight(stimulus) devX*getMaxHeight(stimulus) ];  %pixel deviation, note: horizontal is still normalized to screen vertical, which is okay in square pixel world
details.patchX1=ceil(getMaxHeight(stimulus)*details.stdGaussMask*stimulus.stdsPerPatch);
details.patchX2=szX;
details.stdGaussMaskPix=details.stdGaussMask*ceil(getMaxHeight(stimulus));


stimFit = 0;
resampleCounter = 0;
while stimFit == 0
    %CREATE CENTERS
    numPatchesInserted=3;
    centers =...
        ...%yPosPct                      yPosPct                          xPosPct                              xPosPct
        [ details.yPositionPercent       details.yPositionPercent         details.xPositionPercent           details.xPositionPercent;...          %target
        details.yPositionPercent+devY    details.yPositionPercent+devY    details.xPositionPercent-nDevX     details.xPositionPercent-nDevX;...    %top  (firstFlanker, on top if flankerPosAngle == 0)
        details.yPositionPercent-devY    details.yPositionPercent-devY    details.xPositionPercent+nDevX     details.xPositionPercent+nDevX];      %bottom (secondFlanker, on bottom if flankerPosAngle == 0)

    if stimulus.displayTargetAndDistractor
        numPatchesInserted=numPatchesInserted*2;
        centers =repmat(centers,2,1);
        %             [ stimulus.targetYPosPct        stimulus.targetYPosPct          xPosPct                xPosPct;...                   %target
        %             stimulus.targetYPosPct+devY     stimulus.targetYPosPct+devY     xPosPct-nDevX          xPosPct-nDevX;...             %top
        %             stimulus.targetYPosPct-devY     stimulus.targetYPosPct-devY     xPosPct+nDevX          xPosPct+nDevX ;...            %bottom
        %             stimulus.targetYPosPct          stimulus.targetYPosPct          xPosPct                xPosPct;...                   %distractor
        %             stimulus.targetYPosPct+devY     stimulus.targetYPosPct+devY     xPosPct-nDevX          xPosPct-nDevX;...             %top
        %             stimulus.targetYPosPct-devY     stimulus.targetYPosPct-devY     xPosPct+nDevX          xPosPct+nDevX ];              %bottom
    end

    %DETERMINE SCREEN POSITIONS IN PIXELS
    pos = round(centers.* repmat([ height, height, width, width],numPatchesInserted,1)...          %convert to pixel vals
        -  repmat([ floor(szY/2), -(ceil(szY/2)-1 ), floor(szX/2) -(ceil(szX/2)-1)],numPatchesInserted,1))+1; %account for patch size
    xPixHint = round(details.positionalHint * width)*sign(-details.correctResponseIsLeft); % x shift value in pixels caused by hint
    detail.xPixShiftHint = xPixHint;

    hintOffSet= repmat([0, 0, xPixHint, xPixHint], numPatchesInserted, 1);
    if stimulus.displayTargetAndDistractor
        %first half move one direction, second half move the other
        hintOffSet(numPatchesInserted/2+1:end,:)= -hintOffSet(1:numPatchesInserted/2,:)
        %  hintOffSet= [repmat([0, 0,  xPixHint,  xPixHint], numPatchesInserted/2, 1);...
        %  repmat([0, 0, -xPixHint, -xPixHint], numPatchesInserted/2, 1)];
    end
    pos = pos + hintOffSet;

    % CHECK ERROR WITHOUT NOISE - dynamic may pass
    if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width))) && isempty(strfind(stimulus.renderMode,'dynamic'))
        width
        height
        xPixHint
        szY
        centers
        pos
        sca
        edit(mfilename)
        keyboard
        
        error('At least one image patch is going to be off the screen.  Make patches smaller or closer together or check the size of xPosHint.')
    end

    % ADD NOISE TERMS TO PIXEL POSITIONS
    xPixShift = round(details.xPosNoiseStd * randn * width);  % x shift value in pixels caused by noise
    yPixShift = round(details.yPosNoiseStd * randn * height); % y shift value in pixels caused by noise
    details.xPosNoisePix = xPixShift;
    details.yPosNoisePix = yPixShift;
    details.xPosNoiseSample = xPixShift/width;
    details.yPosNoiseSample = yPixShift/height;

    pos = pos + repmat([yPixShift, yPixShift, xPixShift, xPixShift], numPatchesInserted, 1);

    %ERROR CHECK WITH NOISE
    if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width))) && isempty(strfind(stimulus.renderMode,'dynamic'))
        resampleCounter = resampleCounter+1;
        display(sprintf('stimulus off screen because of noise, number of resamples = %d', resampleCounter));
        if resampleCounter > 10
            error('too many resamples, reconsider the size of the noise');
        end
    else
        stimFit = 1;
        details.stimRects = pos;
        details.PTBStimRects = [pos(:, 3), pos(:, 1), pos(:, 4), pos(:, 2)];
    end
end
