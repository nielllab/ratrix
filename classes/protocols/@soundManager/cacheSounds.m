function [sm updateCache]=cacheSounds(sm)
updateCache=0;
sm = initializeSound(sm);
soundNames = getSoundNames(sm);

for i=1:length(soundNames)
    [clip sampleRate sm updateSMCache] = getSound(sm,soundNames{i});

    if updateSMCache
        updateCache=1;
    end
end