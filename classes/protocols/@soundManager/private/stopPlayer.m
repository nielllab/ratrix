function sm=stopPlayer(sm,i) 
warning('calling this copies the cached clips inside sm, which will take long enough to cause frame drops -- you should instead copy and past this code (gasp)')
if sm.playingNonLoop(i) ||  sm.playingLoop(i)
    PsychPortAudio('Stop', sm.players{i},2);

    sm.playingNonLoop(i)=false;
    sm.playingLoop(i)=false;
end