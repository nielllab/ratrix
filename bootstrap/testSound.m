InitializePsychSound(); 

fundamentalFreqs = [400];
maxFreq = 20000;
sampleRate = 44100;
msLength = 4000;
msMinSoundDuration = 100;
amplitude = 1.0;
numSamples = sampleRate*msLength/1000;
repetitions = 0; % 0 - Loop Forever;  1 - Run Once
mode = 1; % 1 - Just playback
channels = 2; % Normally 2 for stereo playback
reqlatencyclass = 1;
buffersize = 4096;
deviceid = -1; % Default to auto-selected default output device if none specified:

outFreqs=[];
for i=1:length(fundamentalFreqs)
    done=0;
    thisFreq=fundamentalFreqs(i);
    while ~done
        if thisFreq<=maxFreq
            outFreqs=[outFreqs thisFreq];
            thisFreq=2*thisFreq;
        else
            done=1;
        end
    end
end
freqs=unique(outFreqs);
raw=repmat(2*pi*[0:numSamples]/numSamples,length(freqs),1);
clip = sum(sin(diag(freqs)*raw));
% Duplicate mono stream into all channels
for i=2:channels
    clip(i,:) = clip(1,:);
end

for i=1:size(clip,1)
    clip(i,:)=clip(i,:)-mean(clip(i,:));
    clip(i,:)=clip(i,:)/max(abs(clip(i,:)))*amplitude;
end

% Open the sound device
player=PsychPortAudio('Open', deviceid, mode, reqlatencyclass, sampleRate, channels, buffersize);
% Fill buffer with data:
PsychPortAudio('FillBuffer', player, clip);
% Start the sound
audio_onset = PsychPortAudio('Start', player, repetitions, 0, 0);
pause(2);
PsychPortAudio('Stop',player);
PsychPortAudio('Close',player);
