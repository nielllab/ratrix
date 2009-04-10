function out=makeChunk(sampRate,minsDur)
%clc

%sampRate=40000;
%minsDur=.1;
spkRates=[10 50];
spkDurMS=2;

freqs=0:.001:1;
lows=zeros(1,length(freqs));
lowness=10;
mags=exp(-lowness*freqs)-exp(-lowness*freqs(end)) + lows;

out=randn(1,round(sampRate*minsDur*60));

[b,a]=fir2(round(sampRate/100),freqs,mags);
out=25*out+cumsum(out)+250*filtfilt(b,a,out);

out=out/max(abs(out));

spkLen=round(sampRate*spkDurMS/1000);
for i=1:length(spkRates)
    if rand>.5
        shape=exp(-.05*(0:spkLen-1));
    else
        env=normpdf(linspace(-6,6,spkLen),0,1);
        shape=env.*sin(linspace(0,2*pi,spkLen))+.3*env*sign(randn);
        shape=shape/max(abs(shape));
    end
    deltas=rand(size(out))<spkRates(i)/sampRate;
    amp=0.65*sign(randn);
    spks=conv(amp*deltas,shape);
    spks=spks(1:end-spkLen+1);
    out=out+spks;
    spkTimes{i}=find(deltas);
end

out=out/max(abs(out));

doplots=false;
if doplots
    numPlots=2;
    
    times=(0:length(out)-1)/sampRate;
    
    subplot(numPlots,1,1)
    plot(times,out)
    ylabel('volts')
    xlabel('secs')
    
    hold on
    
    loOnly=false;
    if loOnly %even hicut at 5000 smooths spikes way too much
        loCut=50;
        [b,a]=fir1(sampRate/50,2*loCut/sampRate,'high');
    else
        band=[50 10000];
        [b,a]=fir1(sampRate/50,2*band/sampRate);
    end
    
    banded=filtfilt(b,a,out);
    banded=banded/max(abs(banded));
    
    
    plot(times,banded,'r')
    for i=1:length(spkRates)
        plot(spkTimes{i}/sampRate,1-i*.1,'k*')
    end
    
    [Pxx,f] = pmtm(out,[],[],sampRate);
    subplot(numPlots,1,2)
    plot(f/1000,log(Pxx))
    ylabel('log(dB/Hz)')
    xlabel('kHz')
    
    hold on
    
    [Pxx,f] = pmtm(banded,[],[],sampRate);
    subplot(numPlots,1,2)
    plot(f/1000,log(Pxx),'r')
    
end