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
            
           if ispc 
            latclass=4; %2ok?
            buffsize=4096; %max -- otherwise crackles
           else
                latclass=[];
                buffsize=[];
        end
            sm.players{i}= PsychPortAudio('Open',[],[],latclass,sampleRate,2,buffsize); %we need special low latency, or ppa('close') takse 25ms on osx!
            %argh!  can only have one of these on windows with enhanced dll.  gar!
            %try getting asio card
            
            %non-enhanced dll works with windows but artifacts...  (need large buffer, but that slows down starting/stopping)
            %fastest ppa('close') on windows is 10ms (black/dell -- including ips(1)w/enhanced dll on xfi card), 20ms (beige), 25ms (osx, but once got a session down to 2, don't know how) 
            %cannot eliminate framedrops on beige or dell, can on black at 100Hz (nosound), osx(nosound/notext) at 60Hz
            
            
            %on beige: audioplayer fastest start is 20ms, stop is 15ms.
            %osx start is 2ms, but stop is 60ms!
            %both blacks/dells, both ~2ms!  add this option back...
            
            PsychPortAudio('FillBuffer', sm.players{i}, clip);
            PsychPortAudio('GetStatus', sm.players{i})

            sm.clipDurs(i)=size(clip,2)/sampleRate;
        end
    end
else
    error('need a station')
end