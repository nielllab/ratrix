function sm=stopPlayer(sm)
try
    PsychPortAudio('Stop', sm.player,2,0);
catch e
    sca
    keyboard
end
sm.playing=[];
sm.looping=false;