function sm=uninit(sm,station)
if isa(station,'station')
    sm=decache(sm);

    if getSoundOn(station) && sm.usePsychPortAudio
        %can't put in soundManager.decache() directly, because need to be able to call decache without closing psychportaudio + losing buffers
        InitializePsychSound(1);
        PsychPortAudio('Close'); %does this work OK if sounds currently playing?  yes on osx...
        clear PsychPortAudio;
    end
else
    error('need a station')
end