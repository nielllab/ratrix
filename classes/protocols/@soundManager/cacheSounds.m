function [sm updateCache]=cacheSounds(sm)
updateCache=0;
sm = initializeSound(sm);
soundNames = getSoundNames(sm);

for i=1:length(soundNames)
    [clip sampleRate sm updateSMCache] = getSound(sm,soundNames{i});

    if sm.playerType == sm.AUDIO_PLAYER_CACHED
        % If mono sound, send same signal to both channels
        if(size(clip,1) == 1)
            clip(2,:) = clip(1,:);
        elseif(size(clip,1) ~= 2)
            error('Stereo or mono sound expected');
        end
        if size(clip,1)==2
            clip=clip'; %on osx, audioplayer constructor requires this
        end
        sm.players{i}=audioplayer(clip, sampleRate);
    end

    if updateSMCache
        updateCache=1;
    end
end