function [c sampleRate s cacheUpdated]=getClip(s)
if isempty(s.clip)
    %disp(sprintf('caching %s',s.name))

    switch s.type
        case 'binaryWhiteNoise'
            s.clip = rand(1,s.numSamples)>.5;
        case 'gaussianWhiteNoise'
            s.clip = randn(1,s.numSamples);
        case 'uniformWhiteNoise'
            s.clip = rand(1,s.numSamples);
        case 'allOctaves'
            outFreqs=[];
            for i=1:length(s.fundamentalFreqs)
                done=0;
                thisFreq=s.fundamentalFreqs(i);
                while ~done
                    if thisFreq<=s.maxFreq
                        outFreqs=[outFreqs thisFreq];
                        thisFreq=2*thisFreq;
                    else
                        done=1;
                    end
                end
            end
            freqs=unique(outFreqs);
            raw=repmat(2*pi*[0:s.numSamples]/s.numSamples,length(freqs),1);
            s.clip = sum(sin(diag(freqs)*raw));
            
        case 'tone'
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;
        case 'CNMToneTrain'
            %train of pure tones, all at start freq, except last one is at
            %end freq. duration and isi specified in setProtocolCNM
            startfreq=s.freq(1);
            endfreq=s.freq(2);
            numtones=s.freq(3);
            isi=s.freq(4);
            toneDuration=s.freq(5);
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            starttone=sin(2*pi*t*startfreq);
            endtone=sin(2*pi*t*endfreq);
            silence=zeros(1, 44.1*isi);
            train=[];
            for i=1:numtones
            train=[train starttone silence];
            end    
            train=[train endtone];
            s.clip = train;
        case 'freeCNMToneTrain'
            %train of pure tones, all at start freq
            %duration and isi specified in setProtocolCNM
            startfreq=s.freq(1);
            endfreq=s.freq(2);
            numtones=s.freq(3);
            isi=s.freq(4);
            toneDuration=s.freq(5);
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            starttone=sin(2*pi*t*startfreq);
            endtone=sin(2*pi*t*endfreq);
            silence=zeros(1, 44.1*isi);
            train=[];
            for i=1:numtones-1
            train=[train starttone silence];
            end    
            train=[train starttone];
            s.clip = train;
        case 'tritones'
            s.clip = getClip(soundClip('annonymous','allOctaves',[s.fundamentalFreqs tritones(s.fundamentalFreqs)],s.maxFreq));
        case 'dualChannel'
            s.clip(1,:) = getClip(s.leftSoundClip);
            s.clip(2,:) = getClip(s.rightSoundClip);
            s.amplitude(1) = s.leftAmplitude;
            s.amplitude(2) = s.rightAmplitude;
        case 'empty'
            s.clip = []; %zeros(1,s.numSamples);
        otherwise
            error('unknown soundClip type')
    end

    %For all channels, normalize
    for i=1:size(s.clip,1)
        s.clip(i,:)=s.clip(i,:)-mean(s.clip(i,:));
        s.clip(i,:)=s.clip(i,:)/max(abs(s.clip(i,:)))*s.amplitude(i);
    end
    s.clip(isnan(s.clip))=0;
    
    cacheUpdated=1;

else
    %disp(sprintf('already cached %s',s.name))
    cacheUpdated=0;
end
c=s.clip;
sampleRate=s.sampleRate;

function t=tritones(freqs)
t=freqs*2.^(6/12); % to get i halfsteps over freq, use freq*2.^[i/12]