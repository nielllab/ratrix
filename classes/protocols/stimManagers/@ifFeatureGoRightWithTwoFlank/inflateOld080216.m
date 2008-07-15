function s=inflateOld080216(s)
%method to inflate stim patches

%determine patch size
maxHeight=getMaxHeight(s);
patchX=ceil(maxHeight*s.stdGaussMask*s.stdsPerPatch);  %stdGaussMask control patch size which control the radius
patchY=patchX;

%DETERMINE RADIUS OF GABOR
normalizeMethod='normalizeVertical';
if s.thresh==0.001 && strcmp(normalizeMethod,'normalizeVertical')
    radius=1/s.stdsPerPatch;
else
    radius=1/s.stdsPerPatch;
    s.thresh=s.thresh
    thresh=0.001;
    params =[radius 16 0 pi 1 thresh 1/2 1/2 ];
    grating=computeGabors(params,0.5,200,200,'square','normalizeVertical',1);
    imagesc(abs(grating-0.5)>0.001)
    imagesc(grating)
    %error('Uncommon threshold for gabor edge; radius 1/s.stdsPerPatch normally used with thresh 0.001')

    %find std -- works if square grating
    h=(2*abs(0.5-grating(100,:)));
    plot(h)
    oneSTDboundary=find(abs(h-exp(-1))<0.01);  %(two vals)
    oneStdInPix=diff(oneSTDboundary)/2
end

%make patches
%     params= radius   pix/cyc      phase orientation ontrast thresh % xPosPct yPosPct
staticParams =[radius  s.pixPerCycs  -99    -99        1    s.thresh  1/2     1/2   ];
extraParams.normalizeMethod=normalizeMethod;
extraParams.mean=s.mean;

%find a better way to get contrast and save it in stimDetails --
%trialManager version does this
extraParams.contrastScale = ones(1,max([length(s.goRightOrientations) length(s.goLeftOrientations) length(s.flankerOrientations) length(s.distractorOrientations)])); %5th parameter is contrast

%for a temp short cut, hardcode a look-up table per orientation right here,
%as long as stimDetails has a record of it.... pmm

if ~(strcmp(s.gratingType,'square'))
    error('only square now')
end

mask=computeGabors([radius 999 0 0 1 s.thresh 1/2 1/2],0,patchX,patchY,'none',normalizeMethod,0);  %range from 0 to 1
%mask=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientat
%ionAndPhase',0,0,[radius 1000 0 0 1 s.thresh 1/2 1/2],0);
s.mask= mask;  %keep as double


    goRightStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientationAndPhase',s.goRightOrientations,s.phase,staticParams,extraParams);
    goLeftStim= getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientationAndPhase',s.goLeftOrientations,s.phase,staticParams,extraParams);
    flankerStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientationAndPhase',s.flankerOrientations,s.phase,staticParams,extraParams);

    if s.displayTargetAndDistractor
        %only bother rendering if you need to display the distractor and
        %distractorFlanker are unique from target & flanker
        if ~s.distractorYokedToTarget
            distractorStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientationAndPhase',s.distractorOrientations,s.phase,staticParams,extraParams);
        else
            distractorStim=[];
        end
        if ~s.distractorFlankerYokedToTargetFlanker
            distractorFlankerStim =getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientationAndPhase',s.flankerOrientations,s.phase,staticParams,extraParams);
        else
            distractorFlankerStim=[];
        end
    else
        distractorStim=[];
        distractorFlankerStim=[];
    end

    %%store these as int8 for more space... (consider int16 if better CLUT exists)
    %%calcStim preserves class type of stim, and stim OGL accepts without rescaling

    s.goRightStim= uint8(double(intmax('uint8'))*(goRightStim));
    s.goLeftStim = uint8(double(intmax('uint8'))*(goLeftStim));
    s.flankerStim= uint8(double(intmax('uint8'))*(flankerStim));
    s.distractorStim = uint8(double(intmax('uint8'))*(distractorStim));
    s.distractorFlankerStim= uint8(double(intmax('uint8'))*(distractorFlankerStim));
    
    %THERE IS NO OLD DEFLATE!

