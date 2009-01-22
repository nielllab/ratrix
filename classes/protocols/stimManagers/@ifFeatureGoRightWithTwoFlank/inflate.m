function s=inflate(s)
%method to inflate stim patches

%determine patch size
[patchX patchY]=getPatchSize(s);

%set defaults
contrastScale=[];
normalizeMethod='normalizeVertical';
%DETERMINE RADIUS OF GABOR
if s.thresh==0.001 && strcmp(normalizeMethod,'normalizeVertical')
    radius=1/s.stdsPerPatch;
else
    radius=1/s.stdsPerPatch;
    s.thresh=s.thresh
    thresh=0.001;
    params =[radius 16 0 pi 1 thresh 1/2 1/2 ];
    grating=computeGabors(params,0.5,200,200,s.gratingType,'normalizeVertical',1);
    imagesc(abs(grating-0.5)>0.001)
    imagesc(grating)

    %find std -- works if square grating
    h=(2*abs(0.5-grating(100,:)));
    plot(h)
    oneSTDboundary=find(abs(h-exp(-1))<0.01);  %(two vals)
    oneStdInPix=diff(oneSTDboundary)/2
    sca
    error('Uncommon threshold for gabor edge; radius 1/s.stdsPerPatch normally used with thresh 0.001')
end

% params= radius   pix/cyc      phase orientation ontrast thresh % xPosPct yPosPct
staticParams =[radius  s.pixPerCycs  -99    -99        1    s.thresh  1/2     1/2   ];  %only used by some renderMethods
mask=computeGabors([radius 999 0 0 1 s.thresh 1/2 1/2],0,patchX,patchY,'none',normalizeMethod,0);  %range from 0 to 1
%mask=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientationAndPhase',0,0,[radius 1000 0 0 1 s.thresh 1/2 1/2],0);


flankerStim=1; % just a place holder, may get overwritten
s.cache.flankerStim= uint8(double(intmax('uint8'))*(flankerStim));
%performs the follwoing function:
% if isinteger(stimulus.cache.flankerStim)
%         details.mean=stimulus.mean*intmax(class(stimulus.cache.flankerStim));
% end

if ~isempty(strfind(s.renderMode,'precachedInsertion'))
    stimTypes=3; %exclude mask
    goRightStim=getFeaturePatchStim(s,patchX,patchY,'variableOrientationAndPhase',{s.goRightOrientations,s.phase,staticParams,normalizeMethod,contrastScale});
    goLeftStim= getFeaturePatchStim(s,patchX,patchY,'variableOrientationAndPhase',{s.goLeftOrientations, s.phase,staticParams,normalizeMethod,contrastScale});
    flankerStim=getFeaturePatchStim(s,patchX,patchY,'variableOrientationAndPhase',{s.flankerOrientations,s.phase,staticParams,normalizeMethod,contrastScale});

    if s.displayTargetAndDistractor
        %only bother rendering if you need to display the distractor and distractorFlanker are unique from target & flanker
        if ~s.distractorYokedToTarget
            distractorStim=getFeaturePatchStim(s,patchX,patchY,'variableOrientationAndPhase',{s.distractorOrientations,s.phase,staticParams,normalizeMethod,contrastScale});
            stimTypes=stimTypes+1;
        else
            distractorStim=[];
        end
        if ~s.distractorFlankerYokedToTargetFlanker
            distractorFlankerStim= getFeaturePatchStim(s,patchX,patchY,'variableOrientationAndPhase',{s.flankerOrientations, s.phase,staticParams,normalizeMethod,contrastScale});
            stimTypes=stimTypes+1;
        else
            distractorFlankerStim=[];
        end
    else
        distractorStim=[];
        distractorFlankerStim=[];
    end
end

switch s.renderMode
    case {'ratrixGeneral-maskTimesGrating'}
        s.cache.mask= mask;  %keep as double
    case  'ratrixGeneral-precachedInsertion'

        %%store these as int8 for more space... (consider int16 if better CLUT exists)
        %%calcStim preserves class type of stim, and stim OGL accepts without rescaling
        integerType='uint8';
        s.cache.mask = cast(double(intmax(integerType))*(mask),integerType);
        
        s.cache.goRightStim= cast(double(intmax(integerType))*(goRightStim), integerType);
        s.cache.goLeftStim = cast(double(intmax(integerType))*(goLeftStim),integerType);
        s.cache.flankerStim= cast(double(intmax(integerType))*(flankerStim),integerType);
        s.cache.distractorStim = cast(double(intmax(integerType))*(distractorStim),integerType);
        s.cache.distractorFlankerStim= cast(double(intmax(integerType))*(distractorFlankerStim),integerType);

    case 'dynamic-maskTimesGrating'
         %save the Mask and a single,oversized, unphased grating for each orientation
         s.cache.orientValues=unique([s.goRightOrientations s.goLeftOrientations s.flankerOrientations s.distractorOrientations s.distractorFlankerOrientations]);          
         orientations=getFeaturePatchStim(s,2*patchX,2*patchY,'variableOrientationAndPhase',{s.cache.orientValues,[0],staticParams,normalizeMethod,contrastScale});
         sz=size(gratings);
         s.cache.orientations= reshape(orientations,sz([1 2 4])); %keep as float
         keyboard
    case 'dynamic-onePatchPerPhase'
        gratings=getFeaturePatchStim(s,2*patchX,2*patchY,'variableOrientationAndPhase',{0,s.phase,staticParams,normalizeMethod,contrastScale});
        sz=size(gratings);
        s.cache.gratings= reshape(gratings,sz([1 2 4])); %keep as float
        disp('pre-caching textures into PTB');
        w=getWindow() %local helper function
        for i=1:length(s.phase)
            s.cache.textures(i)=Screen('MakeTexture', w, s.cache.gratings(:,:,i), [], [], 2);
        end
        Screen('BlendFunction', w,GL_SRC_ALPHA, GL_ONE); % blend source then add it
    case 'dynamic-precachedInsertion'      
        %pre-catch textures
        try
            orientsPerType=[size(goRightStim,3) size(goLeftStim,3) size(flankerStim,3) size(distractorStim,3) size(distractorFlankerStim,3)] ;
            phasesPerType =[size(goRightStim,4) size(goLeftStim,4) size(flankerStim,4) size(distractorStim,4) size(distractorFlankerStim,4)] ;
            numOrients=max(orientsPerType(1:stimTypes));
            numPhases=max(phasesPerType(1:stimTypes));
            textures=nan(stimTypes,numOrients,numPhases);

            integerType='uint8';
            s.cache.mask = cast(double(intmax(integerType))*(mask),integerType);
                   
            %draws fine but overlaps
%             cache{1}.features=cast(double(intmax(integerType))*(goRightStim), integerType);
%             cache{2}.features=cast(double(intmax(integerType))*(goLeftStim), integerType);
%             cache{3}.features=cast(double(intmax(integerType))*(flankerStim), integerType);
%             cache{4}.features=cast(double(intmax(integerType))*(distractorStim), integerType);
%             cache{5}.features=cast(double(intmax(integerType))*(distractorFlankerStim), integerType);

            %cache as double
            cache{1}.features=(goRightStim-s.mean)*2;
            cache{2}.features=(goLeftStim-s.mean)*2;
            cache{3}.features=(flankerStim-s.mean)*2;
            cache{4}.features=(distractorStim-s.mean)*2;
            cache{5}.features=(distractorFlankerStim-s.mean)*2;
            
            
            
            disp('pre-caching textures into PTB');
            w=getWindow() %local helper function
            Screen('BlendFunction', w,GL_SRC_ALPHA, GL_ONE); % blend source then add it
            for type=1:stimTypes
                for o=1:orientsPerType(type)
                    for p=1:phasesPerType(type)
                        %add an alpha channel
                        %fourChannelIM=repmat(cache{type}.features(:,:,o,p), [1, 1, 4]);
                        %fourChannelIM(:,:,4)=s.cache.mask;
                        %textures(type,o,p)= screen('makeTexture',w,fourChannelIM);   
                       
                        % Screen('BlendFunction', textures(type,o,p),GL_SRC_ALPHA, GL_ONE); % blend source then add it
                        %textures(type,o,p)= screen('makeTexture',w,cache{type}.features(:,:,o,p)); % NO ALPHA  
                        textures(type,o,p)= screen('makeTexture',w,cache{type}.features(:,:,o,p),[],[],1); % NO ALPHA , double precision
                    end
                end
            end

            %[resident [texidresident]] = Screen('PreloadTextures', windowPtr [, texids]); %%use preload?;   
                        
            %s.cache.maskTexture = screen('makeTexture',w,s.cache.mask);
            s.cache.textures=textures;
        catch
            sca
            ShowCursor;
            err=lasterror
            err.stack.line
            err.stack.name
            err.stack.file
            rethrow(lasterror);
        end
    otherwise
        stimulus.renderMode
        error('bad renderMode')
end

s=fillLUT(s,s.typeOfLUT,s.rangeOfMonitorLinearized,0);

if ~isempty(s.dynamicSweep) 
    if strcmp('manual', s.dynamicSweep.sweepMode{1})
        %don't do anything, just check if empty
        if isempty(dynamicSweep.sweptValues)
            error ('manual mode of dynamicSweep requires previously filled values');
        end
    else
        s.dynamicSweep.sweptValues=generateFlankerFactorialCombo(s, s.dynamicSweep.sweptParameters, s.dynamicSweep.sweepMode, struct(s));
    end
end

uniqueRepeatDrift=0;
if uniqueRepeatDrift
    %%add some more for a test
    s.cache.A=cast(double(intmax(integerType))*(rand(1,256)),integerType);
    s.cache.B=cast(double(intmax(integerType))*(0.5+(sin([1:256]*2*pi/6)/2)),integerType);
    s.cache.ATex = screen('makeTexture',w,s.cache.A);
    s.cache.BTex = screen('makeTexture',w,s.cache.B);
end

            
            
function w=getWindow()
w=Screen('Windows');
onScreenWindowIndex=find(Screen(Screen('Windows'),'WindowKind')==1);
numOnscreenWindows=length(onScreenWindowIndex);

if isempty(onScreenWindowIndex)
    warning('can''t build textures b/c no window')
else
    if numOnscreenWindows>1
        w
        w(onScreenWindowIndex)
        numOnscreenWindows=numOnscreenWindows
        error('expected only one window open, cant decide which')
    else
        w=w(onScreenWindowIndex(1))
    end
end