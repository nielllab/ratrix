function sm=uninit(sm)
%can't put in soundManager.decache() directly, because need to be able to call decache without closing psychportaudio + losing buffers
sm=decache(sm);
    InitializePsychSound(1); 
PsychPortAudio('Close'); %does this work OK if sounds currently playing?  yes on osx...
clear PsychPortAudio;