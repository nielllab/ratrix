function [sm updateCache]=cacheSounds(sm,station,sounds)
if exist('sounds','var') && ~isempty(sounds)
    for i=1:length(sounds) % can't use cellfun cuz need to fold in updated sm's as we go
        sm = addSound(sm,sounds{i},station);
    end
end

if isa(station,'station')

    updateCache=false;

    if getSoundOn(station) && length(sm.boundaries)~=length(sm.clips)+1
        warning('recaching sounds, this is expensive')

        updateCache=true;

        soundNames = getSoundNames(sm);

        sm=uninit(sm,station); %need to clean up any existing buffers

        dllPath=fullfile(PsychtoolboxRoot, 'portaudio_x86.dll');
        if IsWin && exist(dllPath,'file') && length(soundNames)>1
            warning('found enhanced asio driver -- disabling because this only allows us to make one buffer')
            %note that we could instead just select a non-asio device (i
            %think MME is next most preferred)
            [status,message,messageid]=movefile(dllPath,fullfile(PsychtoolboxRoot, 'disabled.portaudio_x86.dll'));
            if ~status || exist(dllPath,'file')
                message
                messageid
                error('couldn''t disable enhanced psychportaudio dll')
            end
        end

        InitializePsychSound(1);

        %tested systems:
        % 1) erik's osx macbook pro
        % 2) gigabyte mobo w/integrated realtek audio, xp sp3, 2GB, core 2 duo 6850 3GHz/2GHz, 8600 GTS (balaji's machine)
        % 3) rig dell w/ati card
        % 4) rig dell w/nvidia + audigy cards, settings below don't work as well, consider moving to asio (need to use new playlist functionality in psychportaudio for this)
        latclass=1; %4 is max, higher means less latency + stricter checks.  lowering may reduce system load if having frame drops.  1 seems ok on systems 1-3.
        if IsWin
            buffsize=1250; %max is 4096 i think.  the larger this is, the larger the audio latency, but if too small, sound is distorted, and system load increases (could cause frame drops).  1250 is good on systems 1-3.
        else
            buffsize=[];
        end

        sampleRate=44100;
        sm.player= PsychPortAudio('Open',[],[],latclass,sampleRate,2,buffsize);

        s=PsychPortAudio('GetStatus',sm.player);
        s=s.SampleRate;
        
        if s~=sampleRate
            sampleRate
            s
            error('didn''t get requested sample rate')
        end

        buff=[];

        for i=1:length(soundNames)
            [clip clipSampleRate sm updateSMCache] = getSound(sm,soundNames{i});

            if clipSampleRate~=sampleRate
                clipSampleRate
                error('soundManager only works for clips with sampleRate %d',sampleRate)
            end

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

            sm.boundaries(i)=size(buff,2); %these are zero based indices cuz ppa('setloop') wants them that way

            buff=[buff clip];

            sm.clipDurs(i)=size(clip,2)/sampleRate;
        end
        sm.boundaries(end+1)=size(buff,2);

        PsychPortAudio('FillBuffer', sm.player, buff);

        PsychPortAudio('RunMode', sm.player, 1);
        PsychPortAudio('Verbosity' ,1); %otherwise it types crap out when we try to start, must think it's still running even after .Active is false, try to reproduce!

        for i=1:length(sm.clips)
            sm.clips{i}=decache(sm.clips{i});
        end        
    end
else
    error('need a station')
end