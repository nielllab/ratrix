function sm=playSnd(sm,soundName,duration,station,isLoop)
error('deprecated')

if isa(station,'station')
    if getSoundOn(station)
        if ischar(soundName)
            if duration==-1 || duration>=0

                if sm.playerType == sm.AUDIO_PLAYER_CACHED

                    if isLoop
                        error('can''t call playSnd with isLoop set for AUDIO_PLAYER_CACHED type')
                    end

                    match=0;
                    for i = 1:length(sm.clips)
                        if strcmp(getName(sm.clips{i}),soundName)
                            if match>0
                                error('found more than 1 clip by same name')
                            end
                            match = i;
                        end
                    end
                    if match<=0
                        error('found no clip by that name')
                    end
                    
                    numSamps=get(sm.players{match},'TotalSamples');
                    if duration>=0
                        sampleRate=get(sm.players{match},'SampleRate');
                        
                        durationSamps = max(1,ceil(sampleRate*duration)); %if don't have at least 1, audioplayer complains
                        startStop=[1 durationSamps];
                    else
                        startStop=[1 numSamps];
                    end
                    
                    if isplaying(sm.players{match})
                        error('sound was already playing')
                    end
                    while startStop(2)-startStop(1)>0
                        thisTime=min(numSamps,startStop(2));
                        startStop(2)=startStop(2)-thisTime;
                        playblocking(sm.players{match}, [startStop(1) thisTime]); %note the blocking -- means it won't be simultaneous with stim
                    end
                    
                else



                    [clip sampleRate sm updateSMCache]=getSound(sm,soundName);
                    %size(clip)
                    if duration>=0
                        durationSamps = max(1,ceil(sampleRate*duration)); %if don't have at least 1, audioplayer complains
                        if durationSamps>size(clip,2)
                            clear newClip;
                            for i=1:size(clip,1)
                                newClip(i,:)=repmat(clip(i,:),1,floor(durationSamps/size(clip,2))+1);
                            end
                        else
                            newClip = clip;
                        end
                        clip=newClip(:,1:durationSamps);
                    end

                    try
                        newRecs=struct([]);
                        numRecs=0;
                        %length(sm.records)
                        % If mono sound, send same signal to both channels
                        if(size(clip,1) == 1)
                            clip(2,:) = clip(1,:);
                        elseif(size(clip,1) ~= 2)
                            error('Stereo or mono sound expected');
                        end
                        if sm.playerType == sm.AUDIO_PLAYER
                            for i=1:length(sm.records)
                                if sm.records(i).isLoop || isplaying(sm.records(i).player) %garbage collect anyone that is not a loop and not playing
                                    if numRecs==0 %lame that this has to be a special case, cuz struct([]) doesn't have matching fields
                                        newRecs=sm.records(i);
                                    else
                                        newRecs(numRecs+1)=sm.records(i);
                                    end
                                    numRecs=numRecs+1;
                                end
                            end

                            if size(clip,1)==2
                                clip=clip'; %on osx, audioplayer constructor requires this
                            end
                            newRecs(end+1).player=audioplayer(clip, sampleRate);
                            newRecs(end).name=soundName;
                            newRecs(end).isLoop=isLoop;

                            sm.records=newRecs;
                            play(sm.records(end).player); %THIS CALL IS PROBLEMATIC ON OSX

                        elseif sm.playerType == sm.PSYCH_PORT_AUDIO
                            PsychPortAudio('Close');
                            newRecs(end+1).player=PsychPortAudio('Open', sm.deviceid, [], sm.reqlatencyclass, sampleRate, 2, sm.buffersize);
                            newRecs(end).name=soundName;
                            newRecs(end).isLoop=isLoop;
                            sm.records=newRecs;
                            % Fill buffer with data:
                            PsychPortAudio('FillBuffer', sm.records(end).player, clip);
                            % Start the sound
                            if(isLoop)
                                repetitions = 0; % Loop forever
                            else
                                repetitions = 1; % Only run once
                            end
                            PsychPortAudio('Start', sm.records(end).player, repetitions, 0, 0);
                        else
                            error('Unkown sound player type')
                        end
                    catch
                        ex=lasterror;
                        ple(ex)
                        rethrow(ex)
                    end
                end
            else
                error('duration must be >=0')
            end
        else
            error('need a sound name')
        end
    end
else
    error('need a station')
end

