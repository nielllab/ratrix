function [sm updateCache]=cacheSounds(sm,station)
if isa(station,'station')

    updateCache=false;

    if getSoundOn(station) && length(sm.players)~=length(sm.clips)
        fprintf('recaching sounds, this is expensive\n')

        sm=uninit(sm,station); %need to clean up any existing buffers
        InitializePsychSound(1); %we need special low latency, or ppa('close') takse 25ms on osx!
        updateCache=true;

        soundNames = getSoundNames(sm);

        for i=1:length(soundNames)
            [clip sampleRate sm updateSMCache] = getSound(sm,soundNames{i});

            if size(clip,1)>2
                clip=clip'; %psychportaudio requires channels to be rows
            end
            switch size(clip,1)
                case 1
                    clip(2,:) = clip(1,:);
                case 2
                    %pass
                otherwise
                    error('max 2 channels')
            end

            latclass=4;
            sm.players{i}= PsychPortAudio('Open',[],[],latclass,sampleRate,2); %we need special low latency, or ppa('close') takse 25ms on osx!
            %argh!  can only have one of these on windows.  gar!
            %works with black computers on plain dll!  but artifacts...
            PsychPortAudio('FillBuffer', sm.players{i}, clip);
            PsychPortAudio('GetStatus', sm.players{i})

            sm.clipDurs(i)=size(clip,2)/sampleRate;
        end
    end
else
    error('need a station')
end