
%CalcStim lard removed



%% from calcStim on 090111

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

%grayscale sweep for viewing purposes
drawColorBar=0;  %**add as a parameter in stimManager object
if drawColorBar
    L=256; spacer=6;
    maxLumVal=double (intmax(class(stim)));  %have to do the uint8
    stim(end-(spacer+2):end-(spacer),end-(L+spacer):end-(1+spacer),1)=uint8(gray(L)'*maxLumVal);
    stim(end-(spacer+2):end-(spacer),end-(L+spacer):end-(1+spacer),2)=uint8(gray(L)'*maxLumVal);
end


%contrast=contrast*contrastScale(s.gratingType,orientation,pixPerCyc)
% %find a better way to get contrast and save it in stimDetails --
% %trialManager version does this in the inflate
% extraParams.contrastScale = ones(1,max([length(s.goRightOrientations) length(s.goLeftOrientations) length(s.flankerOrientations) length(s.distractorOrientations)])); %5th parameter is contrast

%for a temp short cut, hardcode a look-up table per orientation right here,
%as long as stimDetails has a record of it.... pmm
%keep in mind it should be per spatial frequency too!


try
    patch=(WHITE*contrast)*(maskVideo.*grating);  % this line was kept
catch
    sca

    WHITE
    contrast
    size(maskVideo)
    size(grating)
    keyboard
end
