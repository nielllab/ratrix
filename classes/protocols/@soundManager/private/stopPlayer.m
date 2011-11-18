function sm=stopPlayer(sm)
try
    PsychPortAudio('Stop', sm.player,2,0);
catch e
    e
    
    %TODO: debug me
    sm.player
	sm.playing
    sm.looping    
    
    warning('occurs on k+t -- trying to stop sound but already killed player')
    
%  In @soundManager\private\stopPlayer at 6
%  In @soundManager\private\doSound at 22
%  In soundManager.playSound at 5
%  In @trialManager\private\handlePhasedTrialLogic at 126
%  In @trialManager\private\runRealTimeLoop at 734
%  In @trialManager\private\stimOGL at 79
%  In trialManager.doTrial at 267
%  In trainingStep.doTrial at 83
%  In subject.doTrial at 9
%  In station.doTrials at 114
%  In standAloneRun at 162    
    
    try
        s=PsychPortAudio('GetStatus',sm.player)
    end

end
sm.playing=[];
sm.looping=false;