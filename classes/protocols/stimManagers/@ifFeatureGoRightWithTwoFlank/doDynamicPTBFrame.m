function [dynDetails textString]=doDynamicPTBFrame(t,phase,stimDetails,frame,timeSinceTrial,eyeRecords,RFestimate, w,textString)

%properties of screen
filterMode=1; %0 = Nearest neighbour filtering, 1 = Bilinear
modulateColor=[];  % should be empty of interferes with global alpha
textureShader=[];

%setup
typeInd = [];
oInd = [];
pInd = [];
destinationRect=[];
globalAlpha=[];  % will get overwritten per texture

%init
dynDetails=[];
texNum=0;


try
    %SETUP
    if frame <5 %==1  OLD STIMOGL somehow it might start on 3 or 4, not one?
        if isempty(strfind(t.renderMode,'dynamic'))
            t.renderMode
            error('cannot use pbt mode if trialManager is not set to the appropriate renderMode');
            % current known conflict: inflate makes the wrong cache
            % maybe  b/c inflation happens, then PTB reopens and recloses
            % for resizing
        end
        
        if ~texsCorrespondToThisWindow(t,w)
        t=inflate(t); %very costly! should not happen!
        disp(sprintf('UNEXPECTED REINFLATION! on frame %d',frame))
        if ~texsCorrespondToThisWindow(t,w)
            error('should be there now!')
        end
    end
    end

    

    %[resident texidresident] = Screen('PreloadTextures', w)
    Screen('FillRect',w, stimDetails.backgroundColor);

    switch phase
        case 'discriminandum'

            %%% LOGIC
            [targetIsOn flankerIsOn effectiveFrame cycleNum sweptID repetition]=isTargetFlankerOn(t,frame);
            textString=sprintf('%2.2g stim#: %2.2g stimID: %2.2g rep: %2.2g', effectiveFrame,cycleNum,sweptID,repetition);
            
            %update dynamic values if there
            if ~isempty(t.dynamicSweep)     
                stimDetails=setDynamicDetails(t,stimDetails,sweptID);
            end
       
            %set up target
            if targetIsOn

                %INDS FOR PATCH MODE -- type for many
                texNum=texNum+1;
                pInd(texNum)= find(t.phase==stimDetails.flankerPhase);
                if stimDetails.correctResponseIsLeft==1
                    typeInd(texNum)=2; %left
                    oInd(texNum)= find(t.goLeftOrientations==stimDetails.targetOrientation);
                elseif stimDetails.correctResponseIsLeft==-1
                    typeInd(texNum)=1; %right
                    oInd(texNum)= find(t.goRightOrientations==stimDetails.targetOrientation);
                end
                %PARAMS FOR GABOR RENDERING MODE - not all use
                params(texNum,:)= [Inf  t.pixPerCycs  stimDetails.targetPhase stimDetails.targetOrientation  1  t.thresh  1/2   1/2 ];
                %BASIC STUFF -- all use
                globalAlpha(texNum) = stimDetails.targetContrast;
                destinationRect(texNum,:)=stimDetails.PTBStimRects(1,:); %target is 1, top is 2, bottom is 3

                if t.displayTargetAndDistractor
                    texNum=texNum+1; %distractor
                    if stimDetails.correctResponseIsLeft==1
                        if t.distractorYokedToTarget
                            typeInd(texNum)=2; %left
                            oInd(texNum)= find(t.goLeftOrientations==stimDetails.targetOrientation);
                        else
                            typeInd(texNum)=4; %distractor
                            oInd(texNum)= find(t.distractorOrientations==stimDetails.distractorOrientation);
                        end
                    elseif stimDetails.correctResponseIsLeft==-1
                        if t.distractorYokedToTarget
                            typeInd(texNum)=1; %right
                            oInd(texNum)= find(t.goRightOrientations==stimDetails.targetOrientation);
                        else
                            typeInd(texNum)=4; %distractor
                            oInd(texNum)= find(t.distractorOrientations==stimDetails.distractorOrientation);
                        end
                    end
                    pInd(texNum)= find(t.phase==stimDetails.distractorPhase);
                    globalAlpha(texNum) = stimDetails.distractorContrast;
                    destinationRect(texNum,:)=stimDetails.PTBStimRects(4,:); %distractor is 4
                    params(texNum,:)= [Inf  t.pixPerCycs  stimDetails.distractorPhase distractorOrientation  1  t.thresh  1/2   1/2 ];
                end
            end

            %set up flanker
            if flankerIsOn
                %choose indices
                if t.topYokedToBottomFlankerOrientation & t.topYokedToBottomFlankerContrast
                    texNum=texNum+1;
                    typeInd(texNum)=3; %flanker
                    oInd(texNum)= find(t.flankerOrientations==stimDetails.flankerOrientation);
                    pInd(texNum)= find(t.phase==stimDetails.flankerPhase);
                    globalAlpha(texNum) = stimDetails.flankerContrast;
                    destinationRect(texNum,:)=stimDetails.PTBStimRects(2,:); %top is 2, bottom is 3
                    params(texNum,:)= [Inf  t.pixPerCycs  stimDetails.flankerPhase stimDetails.flankerOrientation  1  t.thresh  1/2   1/2 ];

                    texNum=texNum+1;
                    typeInd(texNum)=3; %flanker
                    oInd(texNum)= oInd(texNum-1);
                    pInd(texNum)= pInd(texNum-1);
                    globalAlpha(texNum) =  globalAlpha(texNum-1);
                    destinationRect(texNum,:)=stimDetails.PTBStimRects(3,:); %top is 2, bottom is 3
                    params(texNum,:)= [Inf  t.pixPerCycs  stimDetails.flankerPhase stimDetails.flankerOrientation  1  t.thresh  1/2   1/2 ];

                else
                    error('topYokedToBottomFlankerContrast and topYokedToBottomFlankerOrientation must equal 1')
                end
                if t.displayTargetAndDistractor
                    if t.distractorFlankerYokedToTargetFlanker
                        if t.topYokedToBottomFlankerOrientation & t.topYokedToBottomFlankerContrast
                            texNum=texNum+1;
                            typeInd(texNum)=3; %distractorFlanker(type 5) is drawn as a flanker(type 3)
                            oInd(texNum)= find(t.flankerOrientations==stimDetails.flankerOrientation);
                            pInd(texNum)= find(t.phase==stimDetails.flankerPhase);
                            globalAlpha(texNum) = stimDetails.distractorFlankerContrast;
                            destinationRect(texNum,:)=stimDetails.PTBStimRects(5,:); %top is 5, bottom is 6
                            params(texNum,:)= [Inf  t.pixPerCycs  stimDetails.flankerPhase stimDetails.flankerOrientation  1  t.thresh  1/2   1/2 ];

                            texNum=texNum+1;
                            typeInd(texNum)=3; %distractorFlanker(type 5) is drawn as a flanker(type 3)
                            oInd(texNum)= oInd(texNum-1);
                            pInd(texNum)= pInd(texNum-1);
                            globalAlpha(texNum) =  globalAlpha(texNum-1);
                            destinationRect(texNum,:)=stimDetails.PTBStimRects(6,:); %top is 5, bottom is 6
                            params(texNum,:)= [Inf  t.pixPerCycs  stimDetails.flankerPhase stimDetails.flankerOrientation  1  t.thresh  1/2   1/2 ];
                        else
                            error('topYokedToBottomFlankerContrast and topYokedToBottomFlankerOrientation must equal 1')
                        end
                    else
                        error('distractorFlankerYokedToTargetFlanker must = 1');
                    end
                end
            end


            if targetIsOn || flankerIsOn
                version=t.renderMode(strfind(t.renderMode,'-')+1:end);
                switch version
                    case 'precachedInsertion'
                        %this first version of the code slavishly reproduces the method used in the
                        %ratrixGeneral renderMode...in the future could be used to validate a
                        %version where Gaussian Mask are stored seperate from grating and
                        %orientations is handled by PTB and phase is handled by choice of
                        %sourceRect

                        %draw the patches
                        N=size(oInd,2);
                        %                         for n=1:N
                        %                             disp(sprintf('frame=%d n=%d',frame,n))
                        %                             t.cache.textures
                        %                             thisTex=t.cache.textures(typeInd(n),oInd(n),pInd(n))
                        %                             screen('drawTexture',w,t.cache.textures(typeInd(n),oInd(n),pInd(n)),[],destinationRect(n,:),[],filterMode,globalAlpha(n),modulateColor,textureShader)
                        %                             %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader]);
                        %                         end


                        texInds=sub2ind(size(t.cache.textures),typeInd(1:N), oInd(1:N),pInd(1:N));
                        %ALL AT ONCE IS OPTIMIZED
%                         texInds=texInds
%                         w=w
%                         tex=t.cache.textures(texInds)
%                         srcRect=[]
%                         dRect=destinationRect(1:N,:)'
%                         rAngles=[]
%                         filter=repmat(filterMode,1,N)
%                         alpha=globalAlpha(1:N)
%                         modColor=modulateColor
%                         textShade=textureShader

                        Screen('DrawTextures', w, t.cache.textures(texInds) ,[] , destinationRect(1:N,:)', [], repmat(filterMode,1,N), globalAlpha(1:N), modulateColor, textureShader);
                        %Screen('DrawTextures', windowPointer, texturePointer(s) [, sourceRect(s)] [, destinationRect(s)] [, rotationAngle(s)] [, filterMode(s)] [, globalAlpha(s)] [, modulateColor(s)] [, textureShader] [, specialFlags] [, auxParameters]);

%                         mainIm=unique(Screen('GetImage', w))
%                         oneTex=unique(Screen('GetImage', t.cache.textures(1)))
                        
                      


                        
                    case {'maskTimesGrating'}
                        error('not tested yet')
                        %this 2nd version of the code coped from  ratrixGeneral-maskTimesGrating
                        % Gaussian Mask are stored seperate and gratings are recalculated

                        maskInd = t.stdGaussMask==details.stdGaussMask
                        WHITE=double(intmax(class(stim)));
                        %         above=zeros(size(patch),class(stim));
                        %         below=above;
                        %         above(sign(patch)==1)=(patch(sign(patch)==1));
                        %         below(sign(patch)==-1)=(-patch(sign(patch)==-1));
                        %         stim(pos(1):pos(2),pos(3):pos(4))=stim(pos(1):pos(2),pos(3):pos(4))+above-below;

                        %draw the patches
                        for n=1:size(params,1)
                            contrast=1; %relying on global alpha
                            grating=computeGabors(params(1,:),0.5,stimDetails.patchX2,stimDetails.patchX2,t.gratingType,'normalizeVertical',0);
                            patch=(WHITE*contrast)*(s.cache.maskVideo(maskInd).*(grating{n}-0.5));
                            tex= screen('makeTexture',w,patch);
                            screen('drawTexture',w,tex,[],destinationRect(n,:),[],filterMode,globalAlpha(n),modulateColor,textureShader)
                            %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader]);
                        end
                    case {'onePatchPerPhase'}
                        %this 3rd version of the code
                        % one grating per phase is precomputed,
                        % orientation handled by PTB's internal rotation

                        rotAngles=rad2deg(params(:,4)');

                        internalRotation=0; % a stim parameter? set in details by onePatchPerPhase?
                        if internalRotation
                            sflags = kPsychUseTextureMatrixForRotation;
                            ind=1; % all phase tex the same size, so just use the first
                            srcRect = CenterRect([0 0 stimDetails.patchX2 stimDetails.patchX2], Screen('Rect', t.cache.textures(ind)));
                            %                         srcRect = repmat(srcRect,length(pInd),1);
                            %                         apparently only needs one of them
                        else
                            sflags = 0;
                            srcRect = [];
                        end

                        for i=1:length(t.phase)
                            which=find(params(:,3)==t.phase(i)); %which stims get drawn this phase
                            if length(which)>0
                                i=i
                                w=w
                                tex=t.cache.textures(i)
                                srcRect=srcRect'
                                dRect=destinationRect(which,:)'
                                rAngles=rotAngles(which)
                                filter=repmat(filterMode,1,length(which))
                                alpha=globalAlpha(which)
                                modColor=modulateColor
                                textShade=textureShader
                                sflags=sflags
                                Screen('DrawTextures', w, t.cache.textures(i), srcRect', destinationRect(which,:)', rotAngles(which), repmat(filterMode,1,length(which)), globalAlpha(which),modulateColor,textureShader, sflags);
                            end
                        end
         
                        %all at once

                        %                     Screen('DrawTextures', w, t.cache.textures([pInd]), srcRect', destinationRect', rotAngles, repmat(filterMode,1,length(pInd)), globalAlpha,modulateColor,textureShader, sflags);

                    case {'onePatch'}
                        % phase handled by source selection
                        error('never used')

                    otherwise
                        error('bad version')
                end
            end
        case 'penalty'
            error('not coded yet');
        case 'reward'
            error('not coded yet');
        case 'final'
            error('not coded yet');
        otherwise
            error('not a known phase');
    end

    noise = 0;
    if noise
        Screen('TransformTexture')
        droppedRecord=zeros(frames,1); % my responsibility or the ratrix's?
        drawTime=zeros(frames,1);
    end

    Screen('DrawingFinished', w);

catch
    err=lasterror
    sca
    pInd
    oInd
    typeInd
    destinationRect
    globalAlpha

    err.stack.line
    err.stack.name
    err.stack.file
    ShowCursor;

    rethrow(err);
end



