function [tm quit trialRecords eyeData eyeDataFrameInds gaze station ratrixSVNInfo ptbSVNInfo] ...
    = stimOGL(tm, stimSpecs, startingStimSpecInd, stimManager, LUT, targetOptions, distractorOptions, requestOptions, interTrialLuminance, ...
    station, manual,timingCheckPct,textLabel,rn,subID,stimID,protocolStr,trialLabel,eyeTracker,msAirpuff,trialRecords)
% This function gets ready for stimulus presentation by precaching textures (unless expert mode), and setting up some other small stuff.
% All of the actual real-time looping is handled by runRealTimeLoop.


verbose = false;
responseOptions = union(targetOptions, distractorOptions);

originalPriority = Priority;

%ListenChar(2);
%FlushEvents('keyDown');
%edf moved these to station.doTrials() so that we don't get garbage sent to matlab windows from between-trial keypresses.
%however, whether they're here or there, we still seem to get garbage -- figure out why!
%something wrong with flushevents?

phaseData = cell(1,length(stimSpecs));

if strcmp(tm.displayMethod,'ptb')
    window=getPTBWindow(station);
    if window<=0
        error('window must be >0')
    end
    HideCursor;
else
    window=0;
end
ifi=getIFI(station);

frameDropCorner.size=[.05 .05];
frameDropCorner.loc=[1 0];
frameDropCorner.on=~strcmp(tm.frameDropCorner{1},'off');
frameDropCorner.ind=1;

try
    [garbage ptbVer]=PsychtoolboxVersion;
    ptbVersion=sprintf('%d.%d.%d(%s %s)',ptbVer.major,ptbVer.minor,ptbVer.point,ptbVer.flavor,ptbVer.revstring);
    ptbSVNInfo=sprintf('%d.%d.%d%s at %d',ptbVer.major,ptbVer.minor,ptbVer.point,ptbVer.flavor,ptbVer.revision);
    try
        [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
        ratrixVersion=sprintf('%s (%d of %d)',url,runningSVNversion,repositorySVNversion);
        ratrixSVNInfo=sprintf('%s@%d',url,runningSVNversion);
    catch ex
        ratrixVersion='no network connection';
        ratrixSVNInfo = ratrixVersion;
    end
    
    [frameDropCorner currentCLUT] = setCLUTandFrameDropCorner(tm, window, station, LUT, frameDropCorner);
    
    for i=1:length(stimSpecs)
        spec = stimSpecs{i};
        stim = getStim(spec);
        type = getStimType(spec);
        metaPixelSize = getScaleFactor(spec);
        framesUntilTransition = getFramesUntilTransition(spec);
        
        [phaseData{i}.loop phaseData{i}.trigger phaseData{i}.frameIndexed phaseData{i}.timeIndexed ...
            phaseData{i}.indexedFrames phaseData{i}.timedFrames phaseData{i}.strategy phaseData{i}.toggleStim] = determineStrategy(tm, stim, type, responseOptions, framesUntilTransition);
        
        [phaseData{i}.floatprecision stim] = determineColorPrecision(tm, stim, phaseData{i}.strategy);
        stimSpecs{i}=setStim(spec,stim);
        
        if window>0
            phaseData{i}.destRect = determineDestRect(tm, window, station, metaPixelSize, stim, phaseData{i}.strategy);
            
            phaseData{i}.textures = cacheTextures(tm, phaseData{i}.strategy, stim, window, phaseData{i}.floatprecision);
        else
            
            phaseData{i}.destRect=[];
            phaseData{i}.textures=[];
            
        end
    end
    
    [interTrialPrecision interTrialLuminance] = determineColorPrecision(tm, interTrialLuminance, 'static');
    
    [tm quit trialRecords eyeData eyeDataFrameInds gaze frameDropCorner station] ...
        = runRealTimeLoop(tm, window, ifi, stimSpecs, startingStimSpecInd, phaseData, stimManager, ...
        targetOptions, distractorOptions, requestOptions, interTrialLuminance, interTrialPrecision, ...
        station, manual,timingCheckPct,textLabel,rn,subID,stimID,protocolStr,ptbVersion,ratrixVersion,trialLabel,msAirpuff, ...
        originalPriority, verbose,eyeTracker,frameDropCorner,trialRecords, currentCLUT);
    
catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    
    securePins(station);
    
    Screen('CloseAll');
    Priority(originalPriority);
    ShowCursor(0);
    if usejava('desktop')
        FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
    end
    ListenChar(0);
    
    if IsWin
        daqreset;
    end
    
    if ~isempty(eyeTracker)
        cleanUp(eyeTracker);
    end
    
    trialRecords(end).response=sprintf('error_in_StimOGL: %s',ex.message);
    
    rethrow(ex);
end
