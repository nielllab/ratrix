% function [quit response manual didManualInTrial actualRewardDurationMSorUL proposedRewardDurationMSorUL ...
%     actualAirpuffDuration proposedAirpuffDuration eyeData gaze station phaseRecords ratrixSVNInfo ptbSVNInfo]=  ...
%     stimOGL(tm, stimSpecs, stimManager, LUT, targetOptions, distractorOptions, requestOptions, interTrialLuminance, ...
%     station, manual,allowQPM,timingCheckPct, ...
%     noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,eyeTracker,msAirpuff,trialRecords)

function [quit trialRecords eyeData gaze station ratrixSVNInfo ptbSVNInfo]=  ...
    stimOGL(tm, stimSpecs, startingStimSpecInd, stimManager, LUT, targetOptions, distractorOptions, requestOptions, interTrialLuminance, ...
    station, manual,allowQPM,timingCheckPct, ...
    noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,eyeTracker,msAirpuff,trialRecords)

%%% =====================================================================================================================


%logwrite('entered stimOGL');

% =====================================================================================================================
% Variables needed for multiple stimOGL functions
verbose = false;
responseOptions = union(targetOptions, distractorOptions);

% =====================================================================================================================
% Variable initialization
% Needs to happen inside stimOGL, not a function
originalPriority = Priority;

%ListenChar(2); 
%FlushEvents('keyDown');
%edf moved these to station.doTrials() so that we don't get garbage sent to matlab windows from between-trial keypresses.  
%however, whether they're here or there, we still seem to get garbage -- figure out why!
%something wrong with flushevents?

% struct to store phase-specific data that gets determined during caching (textures, strategy, etc)
phaseData = cell(1,length(stimSpecs)); % a cell array of structs (one per phase)

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

%any of the following will cause frame drops (just on entering new code blocks) on the first subsequent run, but not runs thereafter:
%clear java, clear classes, clear all, clear mex (NOT clear Screen)
%each of these causes the code to be reinterpreted
%note that this is what setupenvironment does!
%mlock protects a file from all of these
% should protect from any clear, but for some reason i wrote: except clear classes (and sometimes clear functions?) -- why?
%you have to unlock it to read in changes without restarting matlab!
%mlock; %to pick up changes without restarting matlab, call munlock('trialmanager/private/stimogl'),clear functions
%i don't think mlock will do much unless called on all subfunctions as well
%consider calling pcode on everything...  tho didn't make any difference when i tried it...

frameDropCorner.size=[.05 .05];
frameDropCorner.loc=[1 0];
frameDropCorner.on=~strcmp(tm.frameDropCorner{1},'off');
frameDropCorner.ind=1;

% we need to loop before running real time to cache stimuli for each phase

% =====================================================================================================================
% All function need to be enclosed in a try-catch block
try
    % 12/10/08 - return ratrix and ptb svn version info for trainingStepName
    ratrixSVNInfo ='';
    ptbSVNInfo = '';

    [garbage ptbVer]=PsychtoolboxVersion;
    ptbVersion=sprintf('%d.%d.%d(%s %s)',ptbVer.major,ptbVer.minor,ptbVer.point,ptbVer.flavor,ptbVer.revstring);
    ptbSVNInfo=sprintf('%d.%d.%d%s at %d',ptbVer.major,ptbVer.minor,ptbVer.point,ptbVer.flavor,ptbVer.revision);
    try
        [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
        ratrixVersion=sprintf('%s (%d of %d)',url,runningSVNversion,repositorySVNversion);
        ratrixSVNInfo=sprintf('%s@%d',url,runningSVNversion);
    catch ex
        ratrixVersion='no network connection';
    end

    % loop for each phase
    for i=1:length(stimSpecs)
        % set some variables
        spec = stimSpecs{i};
        stim = getStim(spec);
        type = getStimType(spec);
        metaPixelSize = getScaleFactor(spec);
        framesUntilTransition = getFramesUntilTransition(spec);

        % =====================================================================================================================
        [phaseData{i}.loop phaseData{i}.trigger phaseData{i}.frameIndexed phaseData{i}.timeIndexed ...
            phaseData{i}.indexedFrames phaseData{i}.timedFrames phaseData{i}.strategy] = determineStrategy(tm, stim, type, responseOptions, framesUntilTransition);
        
        % =====================================================================================================================
        [phaseData{i}.floatprecision stim] = determineColorPrecision(tm, stim, phaseData{i}.strategy);
        stimSpecs{i}=setStim(spec,stim);

        % =====================================================================================================================
        if window>0
            [scrWidth scrHeight scaleFactor height width scrRect scrLeft scrTop scrRight scrBottom phaseData{i}.destRect, phaseData{i}.CLUT frameDropCorner] ...
                = determineScreenParametersAndLUT(tm, window, station, metaPixelSize, stim, LUT, verbose, phaseData{i}.strategy, frameDropCorner);

            % =====================================================================================================================
            %   show movie following mario's 'ProgrammingTips' for the OpenGL version of PTB
            %   http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html

            phaseData{i}.textures = cacheTextures(tm, phaseData{i}.strategy, stim, window, phaseData{i}.floatprecision, verbose);
        else

            phaseData{i}.destRect=[];
            phaseData{i}.CLUT=[];
            phaseData{i}.textures=[];

            % happens in runRealTimeLoop
            %these should be taken care of?
            %             phase.frameIndexed;
            %             phase.loop;
            %             phase.trigger;
            %             phase.timeIndexed;
            %             phase.indexedFrames;
            %             phase.timedFrames;
            %             phase.strategy;
            %
            %             getCriterion(spec);
            %             getFramesUntilTransition(spec);
            %             getPhaseType(spec);
            %             getIsFinalPhase(spec);
            %             getStochasticDistribution(spec);

        end
    end % end caching loop

    % =====================================================================================================================
    % Enter main real-time loop

    [interTrialPrecision interTrialLuminance] = determineColorPrecision(tm, interTrialLuminance, 'static');
        
    % We will break this main function into smaller functions also in the trialManager class
%     [quit response didManualInTrial manual actualRewardDurationMSorUL proposedRewardDurationMSorUL actualAirpuffDuration proposedAirpuffDuration ...
%         phaseRecords eyeData gaze frameDropCorner station] ...
%         = runRealTimeLoop(tm, window, ifi, stimSpecs, phaseData, stimManager, ...
%         targetOptions, distractorOptions, requestOptions, interTrialLuminance, interTrialPrecision, ...
%         station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,ptbVersion,ratrixVersion,trialLabel,msAirpuff, ...
%         originalPriority, verbose,eyeTracker,frameDropCorner,trialRecords);
    [quit trialRecords eyeData gaze frameDropCorner station] ...
        = runRealTimeLoop(tm, window, ifi, stimSpecs, startingStimSpecInd, phaseData, stimManager, ...
        targetOptions, distractorOptions, requestOptions, interTrialLuminance, interTrialPrecision, ...
        station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,ptbVersion,ratrixVersion,trialLabel,msAirpuff, ...
        originalPriority, verbose,eyeTracker,frameDropCorner,trialRecords);


catch ex
    ple(ex)

    if IsWin
        daqreset;
    end
    
    Screen('CloseAll');
    Priority(originalPriority);
    ShowCursor(0);
    ListenChar(0);

    if hasAirpuff(station)
        setPuff(station,false);
    end
    % ==================
    % 10/19/08 - clean up eyeTracker
    % in catch
    if ~isempty(eyeTracker)
        cleanUp(eyeTracker);
    end
    % ==================
    response=sprintf('error_in_StimOGL: %s',ex.message);

    rethrow(ex);


end
