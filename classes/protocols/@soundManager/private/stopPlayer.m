function sm=stopPlayer(sm,i)
if sm.playingNonLoop(i) ||  sm.playingLoop(i)
    if sm.usePsychPortAudio
        PsychPortAudio('Stop', sm.players{i},2,0);
    else
        m.players{i}.UserData=0;
        stop(sm.players{i});
    end
    
    sm.playingNonLoop(i)=false;
    sm.playingLoop(i)=false;
end