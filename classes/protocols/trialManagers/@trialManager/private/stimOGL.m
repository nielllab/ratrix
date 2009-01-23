function [quit response manual didManualInTrial actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL ...
    eyeData gaze station phaseRecords ratrixSVNInfo ptbSVNInfo]=  ...
    stimOGL(tm, stimSpecs, stimManager, msRewardSound, msPenaltySound, LUT, scaleFactors, targetOptions, distractorOptions, requestOptions, ...
    station, manual,allowQPM,timingCheckPct, ...
    noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,eyeTracker,msAirpuff)

%%% Edited 8/8/08 - fan
%%% Break this into functions so that each type of trialManager can have different handling
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

% struct to store phase-specific data that gets determined during caching (textures, strategy, etc)
phaseData = cell(length(stimSpecs)); % a cell array of structs (one per phase)

station
window=getPTBWindow(station);
ifi=getIFI(station);

if window<0
    error('window must be >=0')
end
HideCursor;
ListenChar(2);
FlushEvents('keyDown');

%any of the following will cause frame drops (just on entering new code blocks) on the first subsequent run, but not runs thereafter:
%clear java, clear classes, clear all, clear mex (NOT clear Screen)
%each of these causes the code to be reinterpreted
%note that this is what setupenvironment does!
%mlock protects a file from all of these 
% should protect from any clear, but for some reason i wrote: except clear classes (and sometimes clear functions?) -- why? 
%you have to unlock it to read in changes without restarting matlab!
mlock; %to pick up changes without restarting matlab, call munlock('trialmanager/private/stimogl'),clear functions

frameDropCorner.size=[.05 .05];
frameDropCorner.loc=[1 0];
frameDropCorner.seq=[1 .5];
frameDropCorner.on=true;
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
    catch
        ex=lastError
        ratrixVersion='no network connection';
    end

    % loop for each phase
    for i=1:length(stimSpecs)
        % set some variables
        spec = stimSpecs{i};
        stim = getStim(spec);
        type = getStimType(spec);
        metaPixelSize = scaleFactors{i};

        % =====================================================================================================================
        % function [loop trigger frameIndexed timeIndexed indexedFrames strategy] = determineStrategy(tm, stim, type, responseOptions)
        [phaseData{i}.loop phaseData{i}.trigger phaseData{i}.frameIndexed phaseData{i}.timeIndexed ...
            phaseData{i}.indexedFrames phaseData{i}.timedFrames phaseData{i}.strategy] = determineStrategy(tm, stim, type, responseOptions);

        % =====================================================================================================================
        % % function [scrWidth scrHeight scaleFactor] = determineScaleFactorAndLUT(window, station, metaPixelSize, stim, LUT, verbose, strategy)
        [scrWidth scrHeight scaleFactor height width scrRect scrLeft scrTop scrRight scrBottom phaseData{i}.destRect, phaseData{i}.CLUT frameDropCorner] ...
            = determineScreenParametersAndLUT(tm, window, station, metaPixelSize, stim, LUT, verbose, phaseData{i}.strategy, frameDropCorner);

        % =====================================================================================================================
        % function floatprecision = determineColorPrecision(tm, stim, verbose, strategy)
        [phaseData{i}.floatprecision stim] = ...
            determineColorPrecision(tm, stim, verbose, phaseData{i}.strategy);
        stimSpecs{i}=setStim(spec,stim);

        % =====================================================================================================================
        %  function [textures, numDots, dotX, dotY, dotLocs, dotSize, dotCtr, resident, texidresident] ...
        %    = cacheTextures(tm, strategy, stim, window, floatprecision, verbose)

        %   show movie following mario's 'ProgrammingTips' for the OpenGL version of PTB
        %   http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html

        [phaseData{i}.textures, phaseData{i}.numDots, phaseData{i}.dotX, phaseData{i}.dotY, phaseData{i}.dotLocs, ...
            phaseData{i}.dotSize, phaseData{i}.dotCtr] ...
            = cacheTextures(tm, phaseData{i}.strategy, stim, window, phaseData{i}.floatprecision, verbose);

    end % end caching loop
    
    % =====================================================================================================================
    % Enter main real-time loop
%     function [quit response didManualInTrial manual actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL phaseRecords] ...
%     = runRealTimeLoop(tm, window, ifi, stimSpecs, phaseData, stimManager, msRewardSound, msPenaltySound, ...
%     targetOptions, distractorOptions, requestOptions, ...
%     station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,msAirpuff, ...
%     originalPriority, verbose);

    % We will break this main function into smaller functions also in the trialManager class
    [quit response didManualInTrial manual actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL phaseRecords eyeData gaze frameDropCorner] ...
    = runRealTimeLoop(tm, window, ifi, stimSpecs, phaseData, stimManager, msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, ...
    station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,ptbVersion,ratrixVersion,trialLabel,msAirpuff, ...
    originalPriority, verbose,eyeTracker,frameDropCorner);
      
      
catch ex
    ple(ex)


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
