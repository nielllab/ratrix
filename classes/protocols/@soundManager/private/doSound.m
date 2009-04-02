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

                PsychPortAudio('SetLoop',sm.player,sm.boundaries(match), sm.boundaries(match+1)-1);
                PsychPortAudio('Start', sm.player, reps);

                sm.playing=match;
                sm.looping=isLoop;
            end
        end
    end
else
    error('need a station')
end