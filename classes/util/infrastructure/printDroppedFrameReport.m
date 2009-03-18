function printDroppedFrameReport(fid,timestamps,frameNum,thisIFI,ifi,type)

fprintf(fid,'missed frameNum: %d, ifi: %g (%g%% late): %s\n',frameNum,thisIFI,100*((thisIFI/ifi)-1),type);
fprintf(fid,'\tlast misses recorded:\t\t%g\n',  1000*(timestamps.missesRecorded       - timestamps.prevPostFlipPulse));
fprintf(fid,'\tlast eyetracker done:\t\t%g\n',  1000*(timestamps.eyeTrackerDone       - timestamps.missesRecorded));
fprintf(fid,'\tlast kbCheck done:\t\t%g\n',     1000*(timestamps.kbCheckDone          - timestamps.eyeTrackerDone));
fprintf(fid,'\tlast handle kbd done:\t\t%g\n',  1000*(timestamps.keyboardDone         - timestamps.kbCheckDone));
fprintf(fid,'\tlast into phase logic:\t\t%g\n', 1000*(timestamps.enteringPhaseLogic   - timestamps.keyboardDone));
fprintf(fid,'\tlast phase logic done:\t\t%g\n', 1000*(timestamps.phaseLogicDone       - timestamps.enteringPhaseLogic));
fprintf(fid,'\tlast reward done:\t\t%g\n',      1000*(timestamps.rewardDone           - timestamps.phaseLogicDone));
fprintf(fid,'\tlast server comm done:\t\t%g\n', 1000*(timestamps.serverCommDone       - timestamps.rewardDone));
fprintf(fid,'\tlast phase records done:\t%g\n', 1000*(timestamps.phaseRecordsDone     - timestamps.serverCommDone));
fprintf(fid,'\tlast loop done:\t\t\t%g\n',      1000*(timestamps.loopEnd              - timestamps.phaseRecordsDone));
fprintf(fid,'\tlast time to cycle:\t\t%g\n',    1000*(timestamps.loopStart            - timestamps.loopEnd));
fprintf(fid,'\tphase update:\t\t\t%g\n',        1000*(timestamps.phaseUpdated         - timestamps.loopStart));
fprintf(fid,'\tframe draw:\t\t\t%g\n',          1000*(timestamps.frameDrawn           - timestamps.phaseUpdated));
fprintf(fid,'\tframe drop corner drawn:\t%g\n', 1000*(timestamps.frameDropCornerDrawn - timestamps.frameDrawn));
fprintf(fid,'\ttext drawn:\t\t\t%g\n',          1000*(timestamps.textDrawn            - timestamps.frameDropCornerDrawn));
fprintf(fid,'\tdrawing finished:\t\t%g\n',      1000*(timestamps.drawingFinished      - timestamps.textDrawn));
fprintf(fid,'\tprepulses done:\t\t\t%g\n',      1000*(timestamps.prePulses            - timestamps.drawingFinished));
fprintf(fid,'\tvbl done:\t\t\t%g\n',            1000*(timestamps.vbl                  - timestamps.prePulses));
fprintf(fid,'\tflip returned:\t\t\t%g\n',       1000*(timestamps.ft                   - timestamps.vbl));
fprintf(fid,'\tpost flip pulse:\t\t%g\n',       1000*(timestamps.postFlipPulse        - timestamps.ft));

fprintf(fid,'\tphase logic gotsounds:\t\t%g\n',    1000*(timestamps.logicGotSounds      - timestamps.enteringPhaseLogic));
fprintf(fid,'\tphase logic sound done:\t\t%g\n',    1000*(timestamps.logicSoundsDone      - timestamps.logicGotSounds));
fprintf(fid,'\tphase logic frame:\t\t%g\n',     1000*(timestamps.logicFramesDone      - timestamps.logicSoundsDone));
fprintf(fid,'\tphase logic port:\t\t%g\n',      1000*(timestamps.logicPortsDone       - timestamps.logicFramesDone));
fprintf(fid,'\tphase logic request:\t\t%g\n',   1000*(timestamps.logicRequestingDone  - timestamps.logicPortsDone));

fprintf(fid,'\tkb overhead:\t\t%g\n',   1000*(timestamps.kbOverhead  - timestamps.kbCheckDone));
fprintf(fid,'\tkb init:\t\t%g\n',   1000*(timestamps.kbInit  - timestamps.kbOverhead));
fprintf(fid,'\tkb kDown:\t\t%g\n',   1000*(timestamps.kbKDown  - timestamps.kbInit));