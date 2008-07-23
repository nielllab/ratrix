function [responseDetails... %structure containing record of events that occurred during this trial
    tm...                    %the trialManager is returned in case its state updated
    updateTM...              %true iff the trialManager state should be persisted (costly remote operation, cuz may need to send new state to server)
    ] = phasedStim (...
    tm,...                    %this trialManager
    isCorrection,...          %boolean indicating this is a correction trial
    rn,...                    %the rnet, otherwise []
    subID,...                 %string subjectID, for writing to screen
    stimID...                %string stimID, for writing to screen
    )

%trialManager data members that this method depends on:
% trialManager.station      %the station where this trial is running
% trialManager.window       %pointer to target PTB window (should already be open)
% trialManager.ifi          %inter-frame-interval for PTB window in seconds (measured when window was opened)
% trialManager.framePulsesEnabled  %station will provide TTL pulse for each frame
% trialManager.manualEnabled     %allow keyboard responses, quitting, pausing, rewarding, and manual poke indications
% trialManager.manualOn          %the previous trial left with manual poke indicator on, so this trial should start with it on
% trialManager.timingCheckPct       %percent of allowable frametime error before apparently dropped frame is reported
% trialManager.numFrameDropReports  %number of frame drops to keep detailed records of for this trial

% trialManager.percentCorrectionTrials      %probability that if this trial is incorrect that it will be repeated until correct
%                                            note this needs to be moved
%                                            here from wherever it
%                                            currently is (or should it be in doTrial()?)
% note trialManager.percentRejectSameConsecutiveAnswer  %ex: [0 0 0 1] (always reject 4 or more) array of probabilities of rejecting a trial for having the same answer as previous trials is handled in doTrial()


%trialManger.stimDetails: a set of parameters stored on the trial manager that specifies everything about this trial
%             it is filled in (selectively overwritten) before every trial by a call to trialManager.calcStim()
%             a trial progresses through a fixed set of PHASES (SESSION->TRIAL->DISCRIMINANDUM->REINFORCEMENT->FINAL)
%             each PHASE has a stimSpec (and some additional phase-specific stuff) which defines the audio and video for that phase
%POSSIBLE FUTURE FEATURE: stimDetails is optinally modified after every frame by a call to trialManager.updateStimDetails()
%                         note, this makes it hard to save records


%stimSpec
% either 'dynamic', in which case stimManager/doDynamicPTBFrame(phaseID) is called on every frame (note this requires thinking about how to save history record), or:
% 'expert', in which ptb calls are made directly in stimManager/doDynamicPTBFrame(phaseID), or:
% stimSpec.stim             %must be of type (logical, uint8, single, or double)
%                           single, double should normalize to 0-1
%                           uint8 should be in range 0-255
%                           note, the linear position of the stim
%                           value within the extremeVals is used to
%                           determine the corresponding CLUT entry (depends on CLUT length), which
%                           specifies the actual pixel value
%                           logical will be smallest and largest CLUT
%                           entries
% stimSpec.metaPixelSize    %[height width] in real pixels represented by each stimPixel ([] means scale to full screen)
% stimSpec.frameTimes       %list of integers > 0 for each page in stim, indicating number of frames to hold each page
%                            last entry can be 0 to hold it, otherwise the stim loops
% stimSpec.frameSounds      %list of sound names to play during each frame (this is in addition to fixed sounds, such as those caused by licks/pokes)
% stimSpec.maxDurationSecs  %timeout if this duration is exceeded (negative means no limit)
% stimSpec.timeoutKillLevel %one of 'phase', 'trial', or 'session'


%trialManager.stimDetails
%   GENERAL
% stimDetails.CLUT                  %CLUT sets the (possibly nonlinear) stimSpec->videoDAC relationship, perhaps to compensate for the videoDAC->photometric CRT output relationship
%                                    see Screen('ReadNormalizedGammaTable'), Screen('LoadNormalizedGammaTable') for proper format (almost always 256 x 3 values from 0 to 1, which is 6k!)
%                                    note stations should store calibration DATA, not CLUTS, which should be COMPUTED (so that a dynamically chosen range of luminances can be linearized, for example)
%                                    would be nice to not save this for every trial!
% stimDetails.showScreenLabel       %print debugging info to screen (eg, rat ID, station ID, session ID, trial ID, isCorrectionTrial, frame number)
% stimDetails.displayText           %additional string to be printed to screen if allowed (eg, state information about this trial's discriminandum)
% stimDetails.responseOptions       %indices of target and distractor ports -- activity on these ports count as responses
% stimDetails.requestOptions        %indices of request ports -- activity on these ports count as requests (if empty, WAIT_FOR_REQUEST phase will be skipped)
%   PHASE: INTERSESSION
% stimDetails.interSessionStim      %stimSpec - (can't loop cuz no stim loop is running), last frame is state of frame buffer between sessions
%                                    note inter-session stim probably won't be handled here, but in the doTrial loop
%   PHASE: WAIT_FOR_REQUEST
% stimDetails.interTrialStim        %stimSpec - show this til first request (if interTrialStim or requestOptions is empty, go straight to discriminandumStim)
%   PHASE: PROGRESSIVE
% stimDeatils.progressiveStim       %n stimSpecs - "progressive disclosure" required stims before discriminandum (each earned by a request; stims can loop; if empty, phase is skipped)
%                                   %each request rewarded by calling getRequestRewardSize(requestTimes))
% stimDetails.completeEachInFull     %boolean - true iff additional requests don't count til each stim completes 
% stimDetails.failOnEarlyResponse   %true iff should abort trial with a penalty if response occurs during this phase
%   PHASE: DISCRIMINANDUM
% stimDetails.discriminandumStim	%n stimSpecs, requests iterate through this list (can implment "toggle" as {discrim, blank})
% stimDetails.advanceOnRequestEnd   %true iff ending a request advances to the next item in discriminandumStim, otherwise advance occurs at next request ("toggle" vs. "maintain-poke-to-maintain-stim")
% stimDetails.loopDiscriminandum    %true iff should loop to beginning of discriminandumStim list after last item reached
%   PHASE: WAIT_FOR_PUMP
% stimDetails.rewardWaitStim        %stimSpec - stim while waiting in reward queue
%   PHASE: REWARD
% stimDetails.rewardStim            %stimSpec - stim while reward is delivered (reward size determined by call to getRewardSize(history))
%   PHASE: PENALTY
% stimDetails.penaltyStim           %stimSpec - stim after an incorrect (length determined by call to getPenaltyDuration(history))
%   PHASE: FINAL
% stimDetails.finalStim             %stimSpec - non-loop, last frame is final state of frame buffer


%responseDetails includes:
% responseDetails.response                  %also indicates if got server or keyboard quit signal
% responseDetails.containedManualPokes      %didManual
% responseDetails.leftWithManualPokingOn	%manual
% responseDetails.containedAPause           %didAPause
% responseDetails.containedForcedRewards    %didValves



% obsolete: maximumNumberStimPresentations,doMask,
%           msResponseTimeLimit,pokeToRequestStim,
%           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,
%           msRewardDuration, msPenalty, msRewardSoundDuration
%           framesPerUpdate


if tm.window<0
    error('window must be >=0')
end

verifyValvesClosed(station);

KbCheck; %load mex files into ram
GetSecs;
Screen('Screens');

HideCursor;
ListenChar(2);
FlushEvents('keyDown');

preSMCacheTime=GetSecs();
[newSM updateSMCache]=cacheSounds(tm.soundMgr);
disp(sprintf('took %g secs to cache sounds',GetSecs()-preSMCacheTime))
if updateSMCache
    tm.soundMgr=newSM; %hmmm, how does this cache get persisted, we don't return tm...
end

originalPriority=Priority;
priorityLevel=MaxPriority(window,'GetSecs','KbCheck');
Priority(priorityLevel); % should use Rush to prevent hard crash if script errors, but then everything below is a string, annoying...
if verbose
    disp(sprintf('running at priority %d',priorityLevel));
end


try
    if size(tm.stimDetals.CLUT,1)<=256 && size(tm.stimDetals.CLUT,2)==3 && all(tm.stimDetals.CLUT(:)>=0) && all(tm.stimDetals.CLUT(:)<=1)
        oldCLUT = Screen('LoadNormalizedGammaTable', tm.window, tm.stimDetals.CLUT);
    else
        error('CLUT must be no longer than 256 rows, 3 cols each, normalized values from 0 to 1')
    end
    
    %create phases, get textures into VRAM
    options.showScreenLabel = stimDetails.showScreenLabel;
    options.displayText = stimDetails.displayText;
    options.window = tm.window;
    options.requestOptions = stimDetails.requestOptions;
    options.responseOptions = [];
    options.failOnEarlyResponse = false;
    options.completeEachInFull = false;
    options.advanceOnRequestEnd = false;
    options.loopPhase = true;
    %
    waitForRequest  = phase(combineStructs(options,stimDetails.interTralStim));

    options.failOnEarlyResponse = stimDetails.failOnEarlyResponse;
    options.completeEachInFull = stimDetails.completeEachInFull;
    %
    progressive     = phase(combineStructs(options,stimDetails.progressiveStim));

    options.failOnEarlyResponse = false;
    options.completeEachInFull = false;
    options.advanceOnRequestEnd = stimDetails.advanceOnRequestEnd;
    options.loopPhase = stimDetails.loopDiscriminandum;
    options.responseOptions = stimDetails.responseOptions;
    %
    discriminandum  = phase(combineStructs(options,stimDetails.discriminandumStim));

    options.advanceOnRequestEnd = false;
    options.loopPhase = true;
    options.requestOptions = [];
    options.responseOptions = [];
    %
    waitForPump     = phase(combineStructs(options,stimDetails.rewardWaitStim));
    reward          = phase(combineStructs(options,stimDetails.rewardStim));
    penalty         = phase(combineStructs(options,stimDetails.penaltyStim));
    final           = phase(combineStructs(options,stimDetails.finalStim));

    [resident texidresident] = Screen('PreloadTextures', tm.window);

    if resident ~= 1
        find(texidresident~=1)
        error('some textures not cached');
    end

    logwrite('textures loaded, starting phases')

    responseDetails.interTrialRecord        = run(waitForRequest);
    responseDetails.progressiveRecord       = run(progressive);
    responseDetails.disciminandumRecord     = run(discriminandum);
    if responseDetails.disciminandumRecord.correct
        responseDetails.waitForPumpRecord   = run(waitForPump);
        responseDetails.reinforcementRecord = run(reward);
    else
        responseDetails.reinforcementRecord = run(penalty);
    end
    responseDetails.finalRecord             = run(final);

    logwrite('done with all phases')

    tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
catch ex
    cleanup(originalPriority,oldCLUT,tm.window);

    ple

    Screen('CloseAll');
    ShowCursor(0);
    ListenChar(0);
    rethrow(ex);
end
cleanup(originalPriority,oldCLUT,tm.window);
end


function cleanup(originalPriority,oldCLUT,window)
currentValveState=verifyValvesClosed(station);
Priority(originalPriority);
Screen('LoadNormalizedGammaTable', window, oldCLUT);
Screen('Close'); %leaving off second argument closes all textures but leaves windows open
end