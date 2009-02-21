function [responseDetails timestamps] = ...
    saveMissedFrameData(tm, responseDetails, frameNum, timingCheckPct, ifi, timestamps)

type='';
thisIFI=timestamps.vbl-timestamps.lastFrameTime;

if timestamps.missed>0
    type='caught';
    responseDetails.numMisses=responseDetails.numMisses+1;
    
    if  responseDetails.numMisses<responseDetails.numDetailedDrops
        
        responseDetails.misses(responseDetails.numMisses)=frameNum;
        responseDetails.afterMissTimes(responseDetails.numMisses)=GetSecs();
        responseDetails.missIFIs(responseDetails.numMisses)=thisIFI;
        responseDetails.missTimestamps(responseDetails.numMisses)=timestamps; %need to figure out: Error: Subscripted assignment between dissimilar structures
    else
        responseDetails.numUnsavedMisses=responseDetails.numUnsavedMisses+1;
    end
    
else
    thisIFIErrorPct = abs(1-thisIFI/ifi);
    if  thisIFIErrorPct > timingCheckPct
        type='unnoticed';
        
        responseDetails.numApparentMisses=responseDetails.numApparentMisses+1;
        
        if responseDetails.numApparentMisses<responseDetails.numDetailedDrops
            responseDetails.apparentMisses(responseDetails.numApparentMisses)=frameNum;
            responseDetails.afterApparentMissTimes(responseDetails.numApparentMisses)=GetSecs();
            responseDetails.apparentMissIFIs(responseDetails.numApparentMisses)=thisIFI;
            responseDetails.apparentMissTimestamps(responseDetails.numApparentMisses)=timestamps; %need to figure out: Error: Subscripted assignment between dissimilar structures
        else
            responseDetails.numUnsavedApparentMisses=responseDetails.numUnsavedApparentMisses+1;
        end
        
    end
end

if ~strcmp(type,'')
    fprintf('missed frameNum: %d, ifi: %g (%g%% late): %s\n',frameNum,thisIFI,100*((thisIFI/ifi)-1),type)
    fprintf('\tlast misses recorded:\t\t%g\n',  1000*(timestamps.missesRecorded       - timestamps.prevPostFlipPulse))
    fprintf('\tlast eyetracker done:\t\t%g\n',  1000*(timestamps.eyeTrackerDone       - timestamps.missesRecorded))
    fprintf('\tlast kbCheck done:\t\t%g\n',     1000*(timestamps.kbCheckDone          - timestamps.eyeTrackerDone))
    fprintf('\tlast handle kbd done:\t\t%g\n',  1000*(timestamps.keyboardDone         - timestamps.kbCheckDone))
    fprintf('\tlast into phase logic:\t\t%g\n', 1000*(timestamps.enteringPhaseLogic   - timestamps.keyboardDone))
    fprintf('\tlast phase logic done:\t\t%g\n', 1000*(timestamps.phaseLogicDone       - timestamps.enteringPhaseLogic))
    fprintf('\tlast reward done:\t\t%g\n',      1000*(timestamps.rewardDone           - timestamps.phaseLogicDone))
    fprintf('\tlast server comm done:\t\t%g\n', 1000*(timestamps.serverCommDone       - timestamps.rewardDone))
    fprintf('\tlast phase records done:\t%g\n', 1000*(timestamps.phaseRecordsDone     - timestamps.serverCommDone))
    fprintf('\tlast loop done:\t\t\t%g\n',      1000*(timestamps.loopEnd              - timestamps.phaseRecordsDone))
    fprintf('\tlast time to cycle:\t\t%g\n',    1000*(timestamps.loopStart            - timestamps.loopEnd))
    fprintf('\tphase update:\t\t\t%g\n',        1000*(timestamps.phaseUpdated         - timestamps.loopStart))
    fprintf('\tframe draw:\t\t\t%g\n',          1000*(timestamps.frameDrawn           - timestamps.phaseUpdated))
    fprintf('\tframe drop corner drawn:\t%g\n', 1000*(timestamps.frameDropCornerDrawn - timestamps.frameDrawn))
    fprintf('\ttext drawn:\t\t\t%g\n',          1000*(timestamps.textDrawn            - timestamps.frameDropCornerDrawn))
    fprintf('\tdrawing finished:\t\t%g\n',      1000*(timestamps.drawingFinished      - timestamps.textDrawn))
    fprintf('\tprepulses done:\t\t\t%g\n',      1000*(timestamps.prePulses            - timestamps.drawingFinished))
    fprintf('\tvbl done:\t\t\t%g\n',            1000*(timestamps.vbl                  - timestamps.prePulses))    
    fprintf('\tflip returned:\t\t\t%g\n',       1000*(timestamps.ft                   - timestamps.vbl))    
    fprintf('\tpost flip pulse:\t\t%g\n',       1000*(timestamps.postFlipPulse        - timestamps.ft))
    
    fprintf('\tphase logic gotsounds:\t\t%g\n',    1000*(timestamps.logicGotSounds      - timestamps.enteringPhaseLogic))
    fprintf('\tphase logic sound done:\t\t%g\n',    1000*(timestamps.logicSoundsDone      - timestamps.logicGotSounds))
    fprintf('\tphase logic frame:\t\t%g\n',     1000*(timestamps.logicFramesDone      - timestamps.logicSoundsDone))
    fprintf('\tphase logic port:\t\t%g\n',      1000*(timestamps.logicPortsDone       - timestamps.logicFramesDone))
    fprintf('\tphase logic request:\t\t%g\n',   1000*(timestamps.logicRequestingDone  - timestamps.logicPortsDone))
    
    fprintf('\tkb overhead:\t\t%g\n',   1000*(timestamps.kbOverhead  - timestamps.kbCheckDone))
    fprintf('\tkb init:\t\t%g\n',   1000*(timestamps.kbInit  - timestamps.kbOverhead))
    fprintf('\tkb kDown:\t\t%g\n',   1000*(timestamps.kbKDown  - timestamps.kbInit))
end

timestamps.lastFrameTime=timestamps.vbl;
timestamps.prevPostFlipPulse=timestamps.postFlipPulse;

end % end function