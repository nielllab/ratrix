function [success] = checkStim(templateStimMgr, targetStimMgrs, localMultiDisplaySetup, tolerance)
% 1/2/09 - this function uses direct PTB calls to check that the stimulus as shown on screen is actually what we think it is
% (as calculated by calcStim)
% - need to do this check in case the expert/dynamic mode PTB calls are messing up in some weird way

% ========================================================================================
targetFrame=[];
templateFrame=[];
success=true;

% tolerance bound - for comparison between stim on screen and calculatedStim
if ~exist('tolerance','var')
    tolerance=0.05;
end

% ========================================================================================
% parameters (screenNum,id,path,mac)
if localMultiDisplaySetup
    warning('you are running with local multidisplay -- timing will be bad!')
    Screen('Preference', 'SkipSyncTests',1)
    screenNum=int8(max(Screen('Screens')));
else
    screenNum=int8(0);
end
id='1U';
path='';
[success mac] = getMACaddress();
if ~success
    mac='000000000000';
end

% ========================================================================================
% station stuff - physicalLocation, rewardMethod
physicalLocation=uint8([1 1 1]);
rewardMethod='localTimed';
st=makeDefaultStation(id,path,mac,physicalLocation,screenNum,rewardMethod);

% ========================================================================================
% create a default trialManager (autopilot)
trialMgr=autopilot();

% ========================================================================================
try
    % now we have a station, go ahead and call startPTB(st), then calcStim for the template
    st=startPTB(st);
    resolutions=getResolutions(station);
    trialRecords=[];
    
    % calcStim for the template
    % variables for template:
    %   templateStimMgr
    %   templateStim
    %   templateLUT
    %   templateScaleFactor
    %   templateType
    %   templateStimSpecs
    %   templateScaleFactors (essentially templateScaleFactor repmatted for all phases)
    
    % variables global to all stims (including template)
    %   targetPorts
    %   distractorPorts
    %   resInd
    
    % variables for the targetStimMgrs (non-template)
    %   targetStimMgrs
    %   targetStims
    %   targetLUTs
    %   targetScaleFactors
    %   targetTypes
    %   thisTargetStimSpecs
    %   thisTargetScaleFactors
    
    % ========================================================================================
    % run calcStim for the template, and also set the resolution and get the PTB window
    [templateStimMgr, ...
        garbage, ...
        resInd, ...
        templateStim, ...           %not recorded in trial record
        templateLUT, ...            %not recorded in trial record
        templateScaleFactor, ...
        templateType, ...
        targetPorts, ...
        distractorPorts, ...
        stimulusDetails, ...
        garbage, ...
        garbage]= ...
        calcStim(templateStimMgr, ...
        class(trialMgr), ...
        resolutions, ...
        getDisplaySize(st), ...
        getLUTbits(st), ...
        getResponsePorts(trialMgr,getNumPorts(st)), ...
        getNumPorts(st), ...
        trialRecords(1:end-1));
    % phase-ify
    if strmatch(templateType, 'phased')
        templateStimSpecs = templateStim.stimSpecs;
        templateScaleFactors = templateStim.scaleFactors;
    else
        [templateStimSpecs templateScaleFactors] = phaseify(trialMgr,templateStim,templateStimMgr,...
            targetPorts,distractorPorts,templateScaleFactor,...
            100,100,getIFI(station));
    end    
    % set resolution
    [st resolution]=setResolution(st,resolutions(resInd));
    % set parameters
    verbose=false;
    window=getPTBWindow(st);
    ifi=getIFI(st);
    responseOptions=union(targetPorts,distractorPorts);
    finalScreenLuminance = 0.5;
    
    % ========================================================================================
    % set up target stims - call calcStim
    numTargetStims=length(targetStimMgrs);
    targetStims=cell(1,numTargetStims);
    targetLUTs=cell(1,numTargetStims);
    targetScaleFactors=cell(1,numTargetStims);
    targetTypes=cell(1,numTargetStims);
    allTargetsStimSpecs=cell(1,numTargetStims);
    allTargetsScaleFactors=cell(1,numTargetStims);
    for i=1:length(targetStimMgrs)
        [targetStimMgrs{i}, ...
            garbage, ...
            garbage, ...
            targetStims{i}, ...           %not recorded in trial record
            targetLUTs{i}, ...            %not recorded in trial record
            targetScaleFactors{i}, ...
            targetTypes{i}, ...
            garbage, ...
            garbage, ...
            stimulusDetails, ...
            garbage, ...
            garbage]= ...
            calcStim(targetStimMgrs{i}, ...
            class(trialMgr), ...
            resolutions, ...
            getDisplaySize(st), ...
            getLUTbits(st), ...
            getResponsePorts(trialMgr,getNumPorts(st)), ...
            getNumPorts(st), ...
            trialRecords(1:end-1));

        % phase-ify
        if strmatch(targetTypes{i}, 'phased')
            allTargetsStimSpecs{i} = targetStims{i}.stimSpecs;
            allTargetsScaleFactors{i} = targetStims{i}.scaleFactors;
        else
            [allTargetsStimSpecs{i} allTargetsScaleFactors{i}] = phaseify(trialMgr,targetStims{i},targetStimMgrs{i},...
                targetPorts,distractorPorts,targetScaleFactors{i},...
                100,100,getIFI(station));
        end
    end
    
    % ========================================================================================
    % now loop through each phase of the template stim
    % for each phase, compare the template to each of the targets (in the same phase)
    for phaseInd=1:length(templateStimSpecs)
        % setup variables
        filtMode=0;
        masktex=[];
        lastI=0;
        dontclear=0;
        filtMode=0;
        labelFrames=0;
        xOrigTextPos=0;
        yNewTextPos=0;
        i=0;
        frameIndex=0;
        % calculate the template's properties (loop, trigger, strategy, etc)
        scaleFactor=templateScaleFactors{phaseInd};
        templateStimFromStimSpec=getStim(templateStimSpecs{phaseInd});
        templateStimType=getStimType(templateStimSpecs{phaseInd});
        templateStimSize=size(templateStimFromStimSpec,3);
        % determine strategy
        [loop trigger frameIndexed timeIndexed indexedFrames timedFrames templateStrategy] = ...
            determineStrategy(trialMgr, templateStimFromStimSpec, templateStimType, responseOptions);
        % determine screen params and LUT
        [scrWidth scrHeight scaleFactor height width scrRect scrLeft scrTop scrRight scrBottom destRect] ...
                    = determineScreenParametersAndLUT(trialMgr, window, st, scaleFactor, templateStimFromStimSpec,...
                    templateLUT, verbose, templateStrategy);
        % determine floatprecision
        [templateFloatprecision finalScreenLuminance] = determineColorPrecision(trialMgr, ...
            templateStimFromStimSpec, finalScreenLuminance, verbose, templateStrategy);
        % cache textures
        [templateTextures, numDots, dotX, dotY, dotLocs, dotSize, dotCtr] ...
          = cacheTextures(trialMgr, templateStrategy, templateStimFromStimSpec, window, templateFloatprecision, finalScreenLuminance, verbose);
        % the template's variable for this phase are:
        %   templateStrategy
        %   templateFloatprecision
        %   templateTextures
        
        % ========================================================================================
        % now do the same precaching for all target stimMgrs with variables:
        %   targetStrategies
        %   targetFloatprecisions
        %   targetTextures
        %   - each of these cell arrays is of length(targetStimMgrs) - one per target stim for this phase
        targetStrategies=cell(1,numTargetStims);
        targetFloatprecisions=cell(1,numTargetStims);
        targetTextures=cell(1,numTargetStims);
        targetStimsFromStimSpecs=cell(1,numTargetStims);
        targetStimTypes=cell(1,numTargetStims);
        targetStimSizes=cell(1,numTargetStims);
        
        for targetInd=1:length(targetStimMgrs)
            scaleFactor=allTargetsScaleFactors{targetInd}{phaseInd};
            targetStimsFromStimSpecs{targetInd}=getStim(allTargetsStimSpecs{targetInd}{phaseInd});
            targetStimTypes{targetInd}=getStimType(allTargetsStimSpecs{targetInd}{phaseInd});
            targetStimSizes{targetInd}=size(targetStimsFromStimSpecs{targetInd},3);
            % determine strategy
            [loop trigger frameIndexed timeIndexed indexedFrames timedFrames targetStrategies{targetInd}] = ...
                determineStrategy(trialMgr, targetStimsFromStimSpecs{targetInd}, targetStimTypes{targetInd}, responseOptions);
            % determine screen params and LUT
            [scrWidth scrHeight scaleFactor height width scrRect scrLeft scrTop scrRight scrBottom destRect] ...
                = determineScreenParametersAndLUT(trialMgr, window, st, targetScaleFactors{targetInd},...
                targetStimsFromStimSpecs{targetInd}, targetLUTs{targetInd}, verbose, targetStrategies{targetInd});
            % determine floatprecision
            [targetFloatprecisions{targetInd} finalScreenLuminance] = determineColorPrecision(trialMgr, targetStimsFromStimSpecs{targetInd}, ...
                finalScreenLuminance, verbose, targetStrategies{targetInd});
            % cache textures
            [targetTextures{targetInd}, numDots, dotX, dotY, dotLocs, dotSize, dotCtr] ...
                = cacheTextures(trialMgr, targetStrategies{targetInd}, targetStimsFromStimSpecs{targetInd}, window, targetFloatprecisions{targetInd}, finalScreenLuminance, verbose);
        end
        
        % ========================================================================================
        % now, loop through each frame of this phase in the template
        % for each i-th frame, compare it to the i-th frames from each of the target stims using whatever mode the target stims specify
        % also compare to the target stims' caches if they are in textureCache mode
        % we should also compare template to its own textureCache if possible - maybe later?
        if strcmp(templateStimType,'dynamic') || strcmp(templateStimType,'expert')
            numFramesInThisPhase = sum(sum(templateStimFromStimSpec.durations)); % this might be stim-specific...hmmm...
        else
            numFramesInThisPhase = length(templateTextures);
        end
        
        % now, for each frame, get the template from screen, and compare with all targets from screen
        for i=1:numFramesInThisPhase
            if strcmp(templateStimType,'dynamic') || strcmp(templateStimType,'expert')
                [doFramePulse masktex] = drawDynamicFrame(templateStimMgr,templateStimFromStimSpec,...
                    i,window,templateFloatprecision,destRect,filtMode,masktex);
            else
                % cached mode
                drawFrameUsingTextureCache(trialMgr, window, i, i, templateStimSize, lastI, dontclear, ...
                    templateTextures(i), destRect, filtMode, labelFrames, ...
                    xOrigTextPos, yNewTextPos)
                lastI=i;
            end
            % now flip and pull from screen
            Screen('Flip',window);
            templateFrame=Screen('GetImage',window,[],[],templateFloatprecision,1); % 1=nrchannels = luminance only
            
            % now compare templateFrame with the same i-th frame of each target stim
            % note that this will fail if template is dynamic (i-counter can cycle depending on drawDynamicFrame) and
            % target is cached (only has n<i frames in its movie) - deal with these temporal problems later
            for targetInd=1:numTargetStims
                if strcmp(targetStimTypes{targetInd},'dynamic') || strcmp(targetStimTypes{targetInd},'expert')
                    [doFramePulse masktex] = drawDynamicFrame(targetStimMgrs{targetInd},targetStimsFromStimSpecs{targetInd},...
                        i,window,targetFloatprecisions{targetInd},destRect,filtMode,masktex);
                else
                    % cached mode
                    drawFrameUsingTextureCache(trialMgr, window, i, i, targetStimSizes{targetInd}, lastI, dontclear, ...
                        targetTextures{targetInd}(i), destRect, filtMode, labelFrames, ...
                        xOrigTextPos, yNewTextPos)
                    lastI=i;
                end
                % now flip and pull from screen
                Screen('Flip',window);
                targetFrame=Screen('GetImage',window,[],[],templateFloatprecision,1); % 1=nrchannels = luminance only
                
                % now compare targetFrame with templateFrame
                if ~movieFramesAreWithinTolerance(templateFrame,targetFrame,tolerance)
                    figure;
                    imagesc(templateFrame);
                    figure;
                    imagesc(targetFrame);
                    success=false;
                end
                % also compare this target to its cache if necessary HERE
                if ~strcmp(targetStimTypes{targetInd},'dynamic') && ~strcmp(targetStimTypes{targetInd},'expert')
                    cacheFrame=targetStimsFromStimSpecs{targetInd}(:,:,i);
                    if ~movieFramesAreWithinTolerance(targetFrame,cacheFrame,tolerance)
                        figure;
                        imagesc(targetFrame);
                        figure;
                        imagesc(cacheFrame);
                        success=false;
                    end
                end
                
            end % end for each target stim at i-th frame in this phase loop
            % also compare template to template cache if necessary HERE
            if ~strcmp(templateStimType,'dynamic') && ~strcmp(templateStimType,'expert')
                cacheFrame=templateStimFromStimSpec(:,:,i);
                if ~movieFramesAreWithinTolerance(templateFrame,cacheFrame,tolerance)
                    figure;
                    imagesc(templateFrame);
                    figure;
                    imagesc(cacheFrame);
                    success=false;
                end
            end
            
        end % end for each frame in this phase loop
    end % end phases loop
    
    % ========================================================================================
    % clean up
    Screen('Close');
    
    % ========================================================================================
catch ex
    st=stopPTB(st);
    ple(ex);
    rethrow(ex);
end
st=stopPTB(st);
% ========================================================================================
end %end function



% ========================================================================================
% HELPER FUNCTION

function success = movieFramesAreWithinTolerance(stimFromScreen, calculatedStim, tolerance)
% this function returns true if stimFromScreen and calculatedStim are within tolerance of each other for all pixels
% looks only at luminance values
% tolerance is specified as a luminance value (not a percentage)
success = false;

% check that stimFromScreen and calculatedStim are same size
% if not, then the calculatedStim might be a smaller/larger version of the stimFromScreen (scaled during PTB draw call w/ destRect)
if ~all(size(stimFromScreen)==size(calculatedStim))
    size(stimFromScreen)
    size(calculatedStim)
    calculatedStim=imresize(calculatedStim,size(stimFromScreen));
    warning('frames being compared are not of same dimensions - rescaling');
%     error('frames being compared are not of same dimensions - erroring now, but later can do imresize if given destRect?');
%     % now scale calculatedStim to the size of destRect
%     newCalcStim = imresize(calculatedStim, [destRect(4)-destRect(2) destRect(3)-destRect(1)]);
%     calculatedStim=newCalcStim;
end

% compare frames
if all(all(calculatedStim-stimFromScreen<=tolerance))
    success=true;
end

end % end function

