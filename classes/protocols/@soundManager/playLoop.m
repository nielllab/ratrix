%you have to commit to calling this at least every secsBtwChecks in order to ensure
%continued looping.

%hack design: you can only have one loop by a given name at a time

function sm=playLoop(sm,newSound,station,keepPlaying)
if isa(station,'station')
    if getSoundOn(station)
        secsBtwChecks=1;

        if sm.playerType == sm.AUDIO_PLAYER_CACHED
            %note this type does not yet respect secsBtwChecks!!!
            if isempty(newSound) && ~keepPlaying
                for i = 1:length(sm.players)
                    if isplaying(sm.players{i})
                        stop(sm.players{i}); %this seems to take a long time (average 250ms!) and causes frame drops, at least on osx :(
                    end
                end
            else

                match=0;
                for i = 1:length(sm.clips)
                    if strcmp(getName(sm.clips{i}),newSound)
                        if match>0
                            error('found more than 1 clip by same name')
                        end
                        match = i;
                    end
                end
                if match<=0
                    error('found no clip by that name')
                end
                isp=isplaying(sm.players{match});

                if ~keepPlaying && isp
                    stop(sm.players{match});
                elseif keepPlaying && ~isp
                    play(sm.players{match}); %this averages almost 10ms on osx :(
                end
            end
        else

            match=0;
            for i = 1:length(sm.records)
                if sm.records(i).isLoop && strcmp(sm.records(i).name,newSound)
                    if match>0
                        error('found more than 1 looping sound by same name')
                    end
                    match = i;
                end
            end

            if match>0
                if sm.playerType == sm.AUDIO_PLAYER
                    isp=isplaying(sm.records(match).player); %prevent subtle bug from state changes to player during this call
                elseif sm.playerType == sm.PSYCH_PORT_AUDIO
                    status = PsychPortAudio('GetStatus', sm.records(match).player);
                    isp=status.Active; %prevent subtle bug from state changes to player during this call
                else
                    error('Unkown sound player type')
                end
            else
                isp=0;
            end

            if isempty(newSound) && ~keepPlaying
                %'Stopping all loops'
                %length(sm.records)
                newRecs=struct([]);
                numRecs=0;
                for i = 1:length(sm.records)
                    if sm.records(i).isLoop
                        if sm.playerType == sm.AUDIO_PLAYER
                            stop(sm.records(i).player);
                        elseif sm.playerType == sm.PSYCH_PORT_AUDIO
                            PsychPortAudio('Stop', sm.records(i).player);
                            PsychPortAudio('Close', sm.records(i).player);
                        else
                            error('Unkown sound player type')
                        end
                        sm.records(i).isLoop=0;
                    else
                        if numRecs==0 %lame that this has to be a special case, cuz struct([]) doesn't have matching fields
                            newRecs=sm.records(i);
                        else
                            newRecs(numRecs+1)=sm.records(i);
                        end
                        numRecs=numRecs+1;
                    end
                end
                sm.records=newRecs;
            elseif ~keepPlaying
                if match>0 && isp
                    newRecs=struct([]);
                    numRecs=0;
                    for i = 1:length(sm.records)
                        if match==i
                            if sm.playerType == sm.AUDIO_PLAYER
                                stop(sm.records(i).player);
                            elseif sm.playerType == sm.PSYCH_PORT_AUDIO
                                PsychPortAudio('Stop', sm.records(i).player);
                                PsychPortAudio('Close', sm.records(i).player);
                            else
                                error('Unkown sound player type')
                            end
                        else
                            if numRecs==0 %lame that this has to be a special case, cuz struct([]) doesn't have matching fields
                                newRecs=sm.records(i);
                            else
                                newRecs(numRecs+1)=sm.records(i);
                            end
                            numRecs=numRecs+1;
                        end
                    end
                    sm.records=newRecs;
                else
                    match
                    isp
                    error('sound not found')
                end
            elseif match==0
                sm=playSnd(sm,newSound,secsBtwChecks,station,1);
            elseif match>0
                if sm.playerType == sm.AUDIO_PLAYER
                    if ~isempty(sm.records(i).player)
                        if ~isp
                            %logwrite('playLoop: about to call audioplayer.play');
                            play(sm.records(i).player); %THIS CALL IS PROBLEMATIC ON OSX
                            %logwrite('playLoop: successfully called audioplayer.play');
                        end
                    else
                        error('sound manager error -- lost its player')
                    end
                elseif sm.playerType == sm.PSYCH_PORT_AUDIO
                    % Old way was to call playLoop multiple times, instead of
                    % barfing on this, for right now, just do nothing since the old
                    % one is already looping
                else
                    error('Unkown sound player type')
                end
            else
                newSound, display(sm)
                error('bad call to playLoop()')
            end
        end
    end
else
    error('need a station')
end