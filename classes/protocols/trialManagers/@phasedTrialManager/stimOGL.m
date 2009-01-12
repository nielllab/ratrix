function [quit response didManualInTrial manual actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL ...
    eyeData gaze station phaseRecords]=  ...
    stimOGL(tm, stimSpecs, finalPhase, soundTypes, LUT, scaleFactors, targetOptions, distractorOptions, requestOptions, ...
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
eyeData=[];
gaze=[];
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

% we need to loop before running real time to cache stimuli for each phase

% =====================================================================================================================
% All function need to be enclosed in a try-catch block
try

    % loop for each phase
    for i=1:length(stimSpecs)
        % set some variables
        spec = stimSpecs{i};
        stim = getStim(spec);
        type = getStimType(spec);
        metaPixelSize = scaleFactors{i};
        finalScreenLuminance = 0.5; % fake finalScreenLuminance - never used in phased version
        
        % =====================================================================================================================
        % function [loop trigger frameIndexed timeIndexed indexedFrames strategy] = determineStrategy(tm, stim, type, responseOptions)
        [phaseData{i}.loop phaseData{i}.trigger phaseData{i}.frameIndexed phaseData{i}.timeIndexed ...
            phaseData{i}.indexedFrames phaseData{i}.timedFrames phaseData{i}.strategy] = determineStrategy(tm, stim, type, responseOptions);

        % =====================================================================================================================
        % % function [scrWidth scrHeight scaleFactor] = determineScaleFactorAndLUT(window, station, metaPixelSize, stim, LUT)
        [scrWidth scrHeight scaleFactor height width scrRect scrLeft scrTop scrRight scrBottom phaseData{i}.destRect] ...
            = determineScreenParametersAndLUT(tm, window, station, metaPixelSize, stim, LUT, verbose);

        % =====================================================================================================================
        % function [floatprecision finalScreenLuminance] = determineColorPrecision(tm, stim, finalScreenLuminance, verbose)
        [phaseData{i}.floatprecision finalScreenLuminance] = determineColorPrecision(tm, stim, finalScreenLuminance, verbose);

        % =====================================================================================================================
        %  function [textures, numDots, dotX, dotY, dotLocs, dotSize, dotCtr, resident, texidresident] ...
        %    = cacheTextures(tm, strategy, stim, window, floatprecision, finalScreenLuminance, verbose)

        %   show movie following mario's 'ProgrammingTips' for the OpenGL version of PTB
        %   http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html

        [phaseData{i}.textures, phaseData{i}.numDots, phaseData{i}.dotX, phaseData{i}.dotY, phaseData{i}.dotLocs, ...
            phaseData{i}.dotSize, phaseData{i}.dotCtr] ...
            = cacheTextures(tm, phaseData{i}.strategy, stim, window, phaseData{i}.floatprecision, finalScreenLuminance, verbose);

    end % end caching loop
        
    % =====================================================================================================================
    % Enter main real-time loop
    % function [quit response responseDetails didManual manual didAPause didValves didHumanResponse didStochasticResponse] ...
    %   = runRealTimeLoop(tm, window, ifi, stim, audioStim, targetOptions, distractorOptions, requestOptions,...
    %       station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,msAirpuff, ...
    %       loop, trigger, frameIndexed, timeIndexed, indexedFrames, timedFrames, strategy, destRect, textures,...
    %       numDots, dotLocs, dotSize, dotCtr, originalPriority, verbose)

    % We will break this main function into smaller functions also in the trialManager class
    [quit response didManualInTrial manual actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL phaseRecords] ...
    = runRealTimeLoop(tm, window, ifi, stimSpecs, phaseData, finalPhase, soundTypes, ...
    targetOptions, distractorOptions, requestOptions, ...
    station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,msAirpuff, ...
    originalPriority, verbose);
      
      
catch
    ex=lasterror;
    ple(ex)


    Screen('CloseAll');
    Priority(originalPriority);
    ShowCursor(0);
    ListenChar(0);

    if hasAirpuff(station)
        setPuff(station,false);
    end

    response=sprintf('error_in_StimOGL: %s',ex.message);

    rethrow(ex);


end
