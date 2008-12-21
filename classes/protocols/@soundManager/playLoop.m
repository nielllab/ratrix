%by design: you can only have one copy of a sound by a given name playing at a time
%this call will override a previously running call to playSound.
function sm=playLoop(sm,newSound,station,keepPlaying)
if isa(station,'station')
    if getSoundOn(station)

        if isempty(newSound) && ~keepPlaying
            for i = 1:length(sm.players)
                %sm=stopPlayer(sm,i); %note: takes too long to copy the cached clips inside sm, have to cut and paste it in...
                if sm.playingNonLoop(i) ||  sm.playingLoop(i)
                    PsychPortAudio('Stop', sm.players{i},2);

                    sm.playingNonLoop(i)=false;
                    sm.playingLoop(i)=false;
                end
            end
        else
            match=getClipInd(sm,newSound);

            if ~keepPlaying

                %sm=stopPlayer(sm,match); %note: takes too long to copy the cached clips inside sm, have to cut and paste it in...
                if sm.playingNonLoop(match) ||  sm.playingLoop(match)
                    PsychPortAudio('Stop', sm.players{match},2);

                    sm.playingNonLoop(match)=false;
                    sm.playingLoop(match)=false;
                end
            elseif keepPlaying && ~sm.playingLoop(match)
                sm=cacheSounds(sm,station);

                if sm.playingNonLoop(match)

                    %sm=stopPlayer(sm,match); %required!  %note: takes too long to copy the cached clips inside sm, have to cut and paste it in...
                    if sm.playingNonLoop(match) ||  sm.playingLoop(match)
                        PsychPortAudio('Stop', sm.players{match},2);

                        sm.playingNonLoop(match)=false;
                        sm.playingLoop(match)=false;
                    end
                end
                PsychPortAudio('Start', sm.players{match}, 0);

                sm.playingNonLoop(match)=false;
                sm.playingLoop(match)=true;
            end
        end
    end
else
    error('need a station')
end