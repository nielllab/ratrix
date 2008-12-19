function [sm updateCache]=cacheSounds(sm)
updateCache=false;

if length(sm.players)~=length(sm.clips)
    fprintf('recaching sounds, this is expensive\n')
    
    sm=uninit(sm); %need to clean up any existing buffers
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

        sm.players{i}= PsychPortAudio('Open',[],[],4,sampleRate,2); %we need special low latency, or ppa('close') takse 25ms on osx!
        PsychPortAudio('FillBuffer', sm.players{i}, clip); 
        PsychPortAudio('GetStatus', sm.players{i})

        sm.clipDurs(i)=size(clip,2)/sampleRate;
    end
end