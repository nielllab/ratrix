%by design: you can only have one copy of a sound by a given name playing at a time
%this call will override a previously running call to playSound.
function sm=playLoop(sm,newSound,station,keepPlaying)
if isa(station,'station')
    if getSoundOn(station)
        
        if isempty(newSound) && ~keepPlaying
            for i = 1:length(sm.players)
                sm=stopPlayer(sm,i);
            end
        else
            match=getClipInd(sm,newSound);
            
            if ~keepPlaying
                
                sm=stopPlayer(sm,match);
            elseif keepPlaying && ~sm.playingLoop(match)
                sm=cacheSounds(sm,station);
                
                if sm.playingNonLoop(match)
                    
                    sm=stopPlayer(sm,match);
                end
                if sm.usePsychPortAudio
                    PsychPortAudio('Start', sm.players{match}, 0);
                else
                    sm.players{match}.UserData=inf;
                    play(sm.players{match});
                end
                sm.playingNonLoop(match)=false;
                sm.playingLoop(match)=true;
            end
        end
    end
else
    error('need a station')
end