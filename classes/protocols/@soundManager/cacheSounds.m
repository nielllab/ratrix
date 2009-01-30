function [sm updateCache]=cacheSounds(sm,station)
if isa(station,'station')
    
    updateCache=false;
    
    if getSoundOn(station) && length(sm.players)~=length(sm.clips)
        warning('recaching sounds, this is expensive')
        
        updateCache=true;
        
        soundNames = getSoundNames(sm);
        
        sm=uninit(sm,station); %need to clean up any existing buffers
        
        if sm.usePsychPortAudio
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
        end
        
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
            
            if sm.usePsychPortAudio
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
                
                %see  http://tech.groups.yahoo.com/group/psychtoolbox/message/9012
                %note this is not exactly supported usage -- we're opening
                %a buffer for every sound.  mario imposes a limit of 10
                %because each additioanl one degrades system performance,
                %and in asio only one is allowed (see above disabling of
                %the enhanced driver).  should use the new playlists
                %feature, but then can't layer sounds (not a big deal for us)...
                %for now since we have only 4 sounds we just do this.
                sm.players{i}= PsychPortAudio('Open',[],[],latclass,sampleRate,2,buffsize);
                
                s=PsychPortAudio('GetStatus',sm.players{i});
                s=s.SampleRate;
                
                %only way to get ppa('stop') to return in <1ms rather tha >10ms is to have asio card AND enhanced dll.
                %otherwise, fastest ppa('stop') on windows is 10ms (black/dell)
                %others: 20ms (beige), 25ms (osx, but once got a session down to 2, don't know how)
                
                %on beige: audioplayer fastest start is 20ms, stop is 15ms.
                %osx start is 2ms, but stop is 60ms!
                %both blacks/dells, both ~2ms!  add this option back...
                
                %without audioplayer or asio card+enhanced dll,
                %cannot eliminate framedrops on beige or dell(ati), can on black/dell(nvidia) at 100Hz (nosound), osx(nosound/notext) at 60Hz
                
                PsychPortAudio('FillBuffer', sm.players{i}, clip);
                %PsychPortAudio('GetStatus', sm.players{i})
                
                PsychPortAudio('RunMode', sm.players{i}, 1);
                PsychPortAudio('Verbosity' ,1); %otherwise it types crap out when we try to start, must think it's still running even after .Active is false, try to reproduce!
                
            else
                sm.players{i}=audioplayer(clip',sampleRate); %audioplayer requires channels to be columns
                sm.players{i}.StopFcn=@audioplayerRepeater;
                sm.players{i}.UserData=0;
                s=sm.players{i}.SampleRate;
            end
            
            if s~=sampleRate
                sampleRate
                s
                error('didn''t get requested sample rate')
            end
            
            sm.clipDurs(i)=size(clip,2)/sampleRate;
        end
        for i=1:length(sm.clips)
            sm.clips{i}=decache(sm.clips{i});
        end
    end
else
    error('need a station')
end