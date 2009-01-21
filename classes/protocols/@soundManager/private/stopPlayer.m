function sm=stopPlayer(sm,i)
warning('calling this copies the cached clips inside sm, which will take long enough to cause frame drops -- you should instead copy and past this code (gasp)')
if sm.playingNonLoop(i) ||  sm.playingLoop(i)
    if sm.usePsychPortAudio
        PsychPortAudio('Stop', sm.players{i},2,0);
        s=PsychPortAudio('GetStatus',sm.players{i});
        if s.Active
            s.RequestedStopTime
            s.EstimatedStopTime
            error('failed to stop -- may need to loop to wait for it to stop?')
        end
    else
        m.players{i}.UserData=0;
        stop(sm.players{i});
    end
    
    sm.playingNonLoop(i)=false;
    sm.playingLoop(i)=false;
end