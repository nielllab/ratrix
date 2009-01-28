%by design: you can only have one copy of a sound by a given name playing at a time
%this call will override a previously running call to playSound or playLoop.
%negative durations mean play the native clip length
function sm=playSound(sm,soundName,duration,station)
if isa(station,'station')
    if getSoundOn(station)
        match=getClipInd(sm,soundName);
        sm=cacheSounds(sm,station);
        reps=1;
        
        if duration>0
            reps=duration/sm.clipDurs(match);
        end
        
        sm=stopPlayer(sm,match);
        
        if duration~=0
            if sm.usePsychPortAudio

                    PsychPortAudio('Start', sm.players{match}, reps);

            else
                numSamps = floor(reps*sm.players{match}.TotalSamples);
                sm.players{match}.UserData=numSamps;
                if reps>1
                    warning('audioplayer can''t loop clips to play longer than the original duration')
                    play(sm.players{match});
                else
                    play(sm.players{match},[1 numSamps]);
                end
            end
            
            sm.playingNonLoop(match)=true;
            sm.playingLoop(match)=false;
        end
    end
else
    error('need a station')
end