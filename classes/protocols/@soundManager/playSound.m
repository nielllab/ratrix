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
        
        %sm=stopPlayer(sm,match); %required!  %note: takes too long to copy the cached clips inside sm, have to cut and paste it in...
        if sm.playingNonLoop(match) ||  sm.playingLoop(match)
            if sm.usePsychPortAudio
                PsychPortAudio('Stop', sm.players{match},2,0);
                s=PsychPortAudio('GetStatus',sm.players{match});
                if s.Active
                    s.RequestedStopTime
                    s.EstimatedStopTime
                    %error('failed to stop -- may need to loop to wait for it to stop?')
                end
            else
                m.players{match}.UserData=0;
                stop(sm.players{match});
            end
            
            sm.playingNonLoop(match)=false;
            sm.playingLoop(match)=false;
        end
        
        
        if duration~=0
            if sm.usePsychPortAudio
%                 if reps-floor(reps) ~= 0
%                     %psychportaudio doesn't support non-integer reps
%                     %could recompute the buffer, but this is inconvenient and hard to recache
%                     %for now this typically only affects the correct/incorrect sounds, not a big deal to round
%  NO LONGER TRUE!
%                     reps=max(1,round(reps));
%                     warning('your sound was rounded to the nearest integer number of repetitions of the original clip you constructed -- if possible, construct the clip with a duration that will factor the durations you plan to call it with, see http://tech.groups.yahoo.com/group/psychtoolbox/message/8941')
%                 end
                try
                    waitForStop(sm.players{match});
                    PsychPortAudio('Start', sm.players{match}, reps);
                catch
                    ex=lasterror;
                    ple(ex)
                    sm.playingNonLoop(match)
                    sm.playingLoop(match)
                    PsychPortAudio('GetStatus', sm.players{match})
                    error('we are getting ''Device already started.'' as if we failed to stop above...')
                end
            else
                numSamps = floor(reps*sm.players{match}.TotalSamples);
                sm.players{match}.UserData=numSamps;
                if reps>1
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