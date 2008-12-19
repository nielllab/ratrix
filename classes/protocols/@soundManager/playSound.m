%by design: you can only have one copy of a sound by a given name playing at a time
%this call will override a previously running call to playSound or playLoop.
%negative durations mean play the native clip length
function sm=playSound(sm,soundName,duration,station)
if isa(station,'station')
    if getSoundOn(station)
        match=getClipInd(sm,soundName);
        sm=cacheSounds(sm);
        reps=1;

        if duration>0
            reps=duration/sm.clipDurs(match);
        end

        %sm=stopPlayer(sm,match); %required!  %note: takes too long to copy the cached clips inside sm, have to cut and paste it in...
        if sm.playingNonLoop(match) ||  sm.playingLoop(match)
            PsychPortAudio('Stop', sm.players{match});

            sm.playingNonLoop(match)=false;
            sm.playingLoop(match)=false;
        end


        if duration~=0
            if reps-floor(reps) ~= 0
                %psychportaudio doesn't support non-integer reps
                %could recompute the buffer, but this is inconvenient and hard to recache
                %for now this typically only affects the correct/incorrect sounds, not a big deal to round
                reps=max(1,round(reps));
                warning('your sound was rounded to the nearest integer number of repetitions of the original clip you constructed -- if possible, construct the clip with a duration that will factor the durations you plan to call it with, see http://tech.groups.yahoo.com/group/psychtoolbox/message/8941')
            end

            PsychPortAudio('Start', sm.players{match}, reps);

            sm.playingNonLoop(match)=true;
            sm.playingLoop(match)=false;
        end
    end
else
    error('need a station')
end