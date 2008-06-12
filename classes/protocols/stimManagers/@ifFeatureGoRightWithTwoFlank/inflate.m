function s=inflate(s)
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
    %     params= radius   pix/cyc      phase orientation ontrast thresh xPosPct yPosPct
    staticParams=[radius  s.pixPerCycs  s.phase    0        1    s.thresh  1/2     1/2   ];
    extraParams.normalizeMethod=normalizeMethod;
    extraParams.mean=s.mean;
    s.goRightStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientation',s.goRightOrientations,staticParams,extraParams);
    s.goLeftStim= getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientation',s.goLeftOrientations, staticParams,extraParams);
    s.flankerStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientation',s.flankerOrientations,staticParams,extraParams);
    
    %%store these as int8 for more space... (consider int16 if better CLUT exists) 
    %%calcStim preserves class type of stim, and stim OGL accepts without rescaling
    s.goRightStim= uint8(double(intmax('uint8'))*(s.goRightStim));
    s.goLeftStim = uint8(double(intmax('uint8'))*(s.goLeftStim));
    s.flankerStim= uint8(double(intmax('uint8'))*(s.flankerStim));
    
    