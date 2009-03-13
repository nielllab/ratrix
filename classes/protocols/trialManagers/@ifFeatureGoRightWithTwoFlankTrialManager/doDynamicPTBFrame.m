function [stimDetails frameRecords]=doDynamicPTBFrame(t,phase,stimDetails,frame,timeSinceTrial,eyeRecords,RFestimate, w)

if frame ==1
    if ~strcmp(t.renderMode,'directPTB')
        error('cannot use pbt mode if trialManager is not set to the appropriate renderMode');
        % current known conflict: inflate makes the wrong cache
    end

end

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


    switch phase
        case 'discriminandum'


version=1;
switch version
    case 1
            %this first version of the code slavishly reproduces the method used in the
            %ratrixGeneral renderMode...in the future could be used to validate a
            %version where Gaussian Mask are stored seperate from grating and
            %orientations is handled by PTB and phase is handled by choice of
            %sourceRect

            %set up target
            if (frame>=t.framesTargetOnOff(1) & frame<t.framesTargetOnOff(2))
                %choose indices
                texNum=texNum+1; %target
                if stimDetails.correctResponseIsLeft==1
                    typeInd(texNum)=2; %left
                    oInd(texNum)= find(t.goLeftOrientations==stimDetails.targetOrientation);
                elseif stimDetails.correctResponseIsLeft==-1
                    typeInd(texNum)=1; %right
                    oInd(texNum)= find(t.goRightOrientations==stimDetails.targetOrientation);
                end
                pInd(texNum)= find(t.phase==stimDetails.flankerPhase);
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
                end
            end

            %set up flanker
            if (frame>=t.framesFlankerOnOff(1) & frame<t.framesFlankerOnOff(2))
                %choose indices
                if t.topYokedToBottomFlankerOrientation & t.topYokedToBottomFlankerContrast
                    texNum=texNum+1;
                    typeInd(texNum)=3; %flanker
                    oInd(texNum)= find(t.flankerOrientations==stimDetails.flankerOrientation);
                    pInd(texNum)= find(t.phase==stimDetails.flankerPhase);
                    globalAlpha(texNum) = stimDetails.flankerContrast;
                    destinationRect(texNum,:)=stimDetails.PTBStimRects(2,:); %top is 2, bottom is 3

                    texNum=texNum+1;
                    typeInd(texNum)=3; %flanker
                    oInd(texNum)= oInd(texNum-1);
                    pInd(texNum)= pInd(texNum-1);
                    globalAlpha(texNum) =  globalAlpha(texNum-1);
                    destinationRect(texNum,:)=stimDetails.PTBStimRects(3,:); %top is 2, bottom is 3
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

                            texNum=texNum+1;
                            typeInd(texNum)=3; %distractorFlanker(type 5) is drawn as a flanker(type 3)
                            oInd(texNum)= oInd(texNum-1);
                            pInd(texNum)= pInd(texNum-1);
                            globalAlpha(texNum) =  globalAlpha(texNum-1);
                            destinationRect(texNum,:)=stimDetails.PTBStimRects(6,:); %top is 5, bottom is 6
                        else
                            error('topYokedToBottomFlankerContrast and topYokedToBottomFlankerOrientation must equal 1')
                        end
                    else
                        error('distractorFlankerYokedToTargetFlanker must = 1');
                    end
                end

            end
    case 2
        %use the mask?
        
    otherwise
        error('bad version)
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

catch ex
    sca
    pInd
    oInd
    typeInd
    destinationRect
    globalAlpha

%     ex.stack.line
%     ex.stack.name
%     ex.stack.file
    ShowCursor;

    rethrow(ex);
end

