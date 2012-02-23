function sm=doSound(sm,soundName,station,duration,isLoop)
if isa(station,'station')
    if getSoundOn(station)
        if isempty(soundName)
            if isLoop && duration==0
                sm=stopPlayer(sm);
            else
                error('if soundName is empty, call must have been to playLoop and keepPlaying must be 0')
            end
        else
            
            match=getClipInd(sm,soundName);
            sm=cacheSounds(sm,station);
            
            if ~isLoop
                reps=1;
                
                if duration>0
                    reps=duration/sm.clipDurs(match);
                end
                
                sm=stopPlayer(sm);
            else
                if duration==0 || (~isempty(sm.playing) && (sm.playing~=match || ~sm.looping))
                    sm=stopPlayer(sm);
                end
                
                if duration~=0 && ~isempty(sm.playing) && sm.playing==match && sm.looping
                    duration=0;
                end
                
                reps=0;
            end
            
            if duration~=0
                
                try
                    PsychPortAudio('SetLoop',sm.player,sm.boundaries(match), sm.boundaries(match+1)-1);
                    PsychPortAudio('Start', sm.player, reps);
                catch e
                    e
                    
                    %TODO: debug me
                    sm.player
                    sm.playing
                    sm.looping
                    
                    warning('occurs on k+t -- trying to stop sound but already killed player')
                end
                
                sm.playing=match;
                sm.looping=isLoop;
            end
        end
    end
else
    error('need a station')
end

% Error in function Stop:         Usage error
% Invalid audio device handle provided.
%
% e =
%  MException
%
%  Properties:
%    identifier: ''
%       message: [1x169 char]
%         cause: {0x1 cell}
%         stack: [11x1 struct]
% ans =
%     0
% ans =
%     1
% ans =
%     0
% Warning: occurs on k+t -- trying to stop sound but already killed player
% > In @soundManager\private\stopPlayer at 12
%  In @soundManager\private\doSound at 22
%  In soundManager.playSound at 5
%  In @trialManager\private\handlePhasedTrialLogic at 125
%  In @trialManager\private\runRealTimeLoop at 787
%  In @trialManager\private\stimOGL at 79
%  In trialManager.doTrial at 275
%  In trainingStep.doTrial at 83
%  In subject.doTrial at 9
%  In station.doTrials at 114
%  In standAloneRun at 162
% Error in function GetStatus:    Usage error
% Invalid audio device handle provided.
% Error in function SetLoop:      Usage error
% Invalid audio device handle provided.
%
% ans =
%
%                previousSchedulerState: 0
%                trialNum: 0
%                sessionRecs: empty
%
% ans =
%     0
%
% Error using PsychPortAudio
% Usage:
%
% PsychPortAudio('SetLoop', pahandle[, startSample=0][, endSample=max][,
% UnitIsSeconds=0]);
%
% Error in doSound (line 37)
%
% PsychPortAudio('SetLoop',sm.player,sm.boundaries(match),
% sm.boundaries(match+1)-1);
%
% Error in soundManager/playSound (line 5)
% sm=doSound(sm,soundName,station,duration,false);
% Error in handlePhasedTrialLogic (line 125)
%    tm.soundMgr =
% playSound(tm.soundMgr,soundsToPlay{2}{i}{1},soundsToPlay{2}{i}{2}/1000.0,station);
%
% Error in runRealTimeLoop (line 787)
%        [tm done newSpecInd phaseInd updatePhase transitionedByTimeFlag ...
%
% Error in stimOGL (line 79)
%    [tm quit trialRecords eyeData eyeDataFrameInds gaze
% frameDropCorner station] ...
%
% Error in trialManager/doTrial (line 275)
%                [trialManager stopEarly,...
%
% Error in trainingStep/doTrial (line 83)
%            [newTM updateTM newSM updateSM stopEarly trialRecords station]=...
%
% Error in subject/doTrial (line 9)
%        [graduate keepWorking secsRemainingTilStateFlip subject r
% trialRecords station manualTs] ...
%
% Error in station/doTrials (line 114)
%                    [subject r keepWorking secsRemainingTilStateFlip
% trialRecords s]= ...
%
% Error in standAloneRun (line 162)
%    rx=doTrials(st(1),rx,0,[],~recordInOracle); %0 means keep running
% trials til something stops you (quit, error, etc)