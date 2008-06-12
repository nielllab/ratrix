function sm=initializeSound(sm)

if sm.playerType == sm.PSYCH_PORT_AUDIO
    initializePsychSound();
    % Maybe substitute you're own latency bias instead of allowing
    % PsychPortAudio to compute it?
    %prelat = PsychPortAudio('LatencyBias', t.pahandle, t.latbias)
    %postlat = PsychPortAudio('LatencyBias', t.pahandle)
end