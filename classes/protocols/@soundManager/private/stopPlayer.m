function sm=stopPlayer(sm)

        PsychPortAudio('Stop', sm.player,2,0);
sm.playing=[];
sm.looping=false;