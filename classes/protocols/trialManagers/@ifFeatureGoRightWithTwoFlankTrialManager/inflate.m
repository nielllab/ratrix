function t=inflate(t)
%method to inflate stim patches into cache

%determine patch size
% maxHeight=getMaxHeight(s);
maxHeight=t.maxHeight;
patchX=ceil(maxHeight*t.stdGaussMask*t.stdsPerPatch);  %stdGaussMask control patch size which control the radius
patchY=patchX;

%% DETERMINE RADIUS OF GABOR
normalizeMethod= t.gaborNormalizeMethod;
if t.thresh==0.001 && strcmp(normalizeMethod,'normalizeVertical')
    radius=1/t.stdsPerPatch;
else
    radius=1/t.stdsPerPatch;
    t.thresh=t.thresh
    thresh=0.001;
    params =[radius 16 0 pi 1 thresh 1/2 1/2 ];
    grating=computeGabors(params,0.5,200,200,t.gratingType,'normalizeVertical',1);
    imagesc(abs(grating-0.5)>0.001)
    imagesc(grating)
    %error('Uncommon threshold for gabor edge; radius 1/t.stdsPerPatch normally used with thresh 0.001')

    %find std -- works if square grating
    h=(2*abs(0.5-grating(100,:)));
    plot(h)
    oneSTDboundary=find(abs(h-exp(-1))<0.01);  %(two vals)
    oneStdInPix=diff(oneSTDboundary)/2
end

%make patches
%     params= radius   pix/cyc      phase orientation ontrast thresh % xPosPct yPosPct
staticParams =[radius  t.pixPerCycs  -99    -99        1    t.thresh  1/2     1/2   ];

stimTypes=3; %exclude mask
mask=getFeaturePatchStim(t,patchX,patchY,'variableOrientationAndPhase',t.flankerOrientations,0,[radius 1000 0 0 1 t.thresh 1/2 1/2]);
goRightStim=getFeaturePatchStim(t,patchX,patchY,'variableOrientationAndPhase',t.goRightOrientations,t.phase,staticParams);
goLeftStim= getFeaturePatchStim(t,patchX,patchY,'variableOrientationAndPhase',t.goLeftOrientations,t.phase,staticParams);
flankerStim=getFeaturePatchStim(t,patchX,patchY,'variableOrientationAndPhase',t.flankerOrientations,t.phase,staticParams);


if t.displayTargetAndDistractor
    %only bother rendering if you need to display the distractor and
    %distractorFlanker are unique from target & flanker
    if ~t.distractorYokedToTarget
        distractorStim=getFeaturePatchStim(t,patchX,patchY,'variableOrientationAndPhase',t.distractorOrientations,t.phase,staticParams);
        stimTypes=stimTypes+1;
    else
        distractorStim=[];
    end
    if ~t.distractorFlankerYokedToTargetFlanker
        distractorFlankerStim =getFeaturePatchStim(t,patchX,patchY,'variableOrientationAndPhase',t.flankerOrientations,t.phase,staticParams);
        stimTypes=stimTypes+1;
    else
        distractorFlankerStim=[];
    end
else
    distractorStim=[];
    distractorFlankerStim=[];
end


switch t.renderMode
    case 'ratrixGeneral'

        %     %store these as int8 for more space... (consider int16 if better CLUT exists)
        %     %calcStim preserves class type of stim, and stim OGL accepts without rescaling
        %     t.cache.goRightStim= uint8(double(intmax('uint8'))*(goRightStim));
        %     t.cache.goLeftStim = uint8(double(intmax('uint8'))*(goLeftStim));
        %     t.cache.flankerStim= uint8(double(intmax('uint8'))*(flankerStim));
        %     t.cache.distractorStim = uint8(double(intmax('uint8'))*(distractorStim));
        %     t.cache.distractorFlankerStim= uint8(double(intmax('uint8'))*(distractorFlankerStim));

        %%store these as int8 for more space... (consider int16 if better CLUT exists)
        %%calcStim preserves class type of stim, and stim OGL accepts without rescaling
        integerType='uint8';
        t.cache.mask = cast(double(intmax(integerType))*(mask),integerType);
        
        t.cache.goRightStim= cast(double(intmax(integerType))*(goRightStim), integerType);
        t.cache.goLeftStim = cast(double(intmax(integerType))*(goLeftStim),integerType);
        t.cache.flankerStim= cast(double(intmax(integerType))*(flankerStim),integerType);
        t.cache.distractorStim = cast(double(intmax(integerType))*(distractorStim),integerType);
        t.cache.distractorFlankerStim= cast(double(intmax(integerType))*(distractorFlankerStim),integerType);

    case 'directPTB'

        % Mask = ...
        % another way of doing this might be to save the Mask and a single,
        % oversized, unphased gratting for each orientation

        %pre-catch textures
        try

            orientsPerType=[size(goRightStim,3) size(goLeftStim,3) size(flankerStim,3) size(distractorStim,3) size(distractorFlankerStim,3)] ;
            phasesPerType =[size(goRightStim,4) size(goLeftStim,4) size(flankerStim,4) size(distractorStim,4) size(distractorFlankerStim,4)] ;
            numOrients=max(orientsPerType(1:stimTypes));
            numPhases=max(phasesPerType(1:stimTypes));
            textures=nan(stimTypes,numOrients,numPhases);

            integerType='uint8';
            t.cache.mask = cast(double(intmax(integerType))*(mask),integerType);
                          
                          
            cache{1}.features=cast(double(intmax(integerType))*(goRightStim), integerType);
            cache{2}.features=cast(double(intmax(integerType))*(goLeftStim), integerType);
            cache{3}.features=cast(double(intmax(integerType))*(flankerStim), integerType);
            cache{4}.features=cast(double(intmax(integerType))*(distractorStim), integerType);
            cache{5}.features=cast(double(intmax(integerType))*(distractorFlankerStim), integerType);

            disp('pre-caching textures into PTB');
            windowPtrs=Screen('Windows');
            w=max(windowPtrs); %ToDo: w=t.window
            for type=1:stimTypes
                for o=1:orientsPerType(type)
                    for p=1:phasesPerType(type)
                        textures(type,o,p)= screen('makeTexture',w,cache{type}.features(:,:,o,p));                                           
                    end
                end
            end
            

            t.cache.orientationPhaseTextures=textures;
       

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