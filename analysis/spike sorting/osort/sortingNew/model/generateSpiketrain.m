%generates a set of spiketrains,at different noise levels but with the same
%neuronal firing.
%
%input
%allMeans: collection of mean waveforms
%realWaveformsInd: real waveforms to use
%nrsamples:# samples to generate,sampled at 100000Hz
%noiseStds: vector of noise stds to generate
%
%returns
%spiketrainsAll: cell array of spike trains for each noise level
%realWaveformsInd:same as input
%noiseWaveformsInd:which of the mean waveforms were chosen to be used for
%noise
%spiketimes: cell array of points of time when neurons fire (for each
%neuron one element in cell array).
%
%waveformsOrig: cell array of cell arrays, orig waveforms of each noise
%level for each neuron.
%
%scalingFactorSpikes: scaling factor used for each of the real (=neuron)
%mean waveforms.
%
%
%urut/dec04
function [spiketrainsAll, realWaveformsInd, noiseWaveformsInd,spiketimes,waveformsOrig, scalingFactorSpikes] = generateSpiketrain(allMeans, realWaveformsInd, nrSamples, noiseStds)

%--- params
%firingRate=[5 7 4 6 9];  %Hz

%firingRate=[10 5 8 20 15]; % 7 4 6 9];  %Hz
firingRate=[1 2];

refractory=3/1000; %3ms
Fs=25000; %sampling rate in Hz of spiketrain
noiseAmp=1;

realWaveforms=length(realWaveformsInd);

scalingFactorSpikes=[];
for i=1:realWaveforms
    maxAmp = max(max(abs(allMeans(realWaveformsInd, :))));
    %maxAmp = max(abs(allMeans(realWaveformsInd(i), :)));
    scalingFactorSpikes(i) = 1/maxAmp;
end

nrWaveforms=size(allMeans,1);


%--- prepare noise

%find all waveforms with amplitude <500 to simulate noise realistically
allMeansNoise=[];
c=0;
for i=1:size(allMeans,1)
    if max(abs(allMeans(i,:))) <= 600 && abs(mean(allMeans(i,1:10)))<100    %exclude artifactual mean waveforms (which are not 0 at beginning (??) and also exclude high-peak once (those are not noise but real once)
        c=c+1;
        allMeansNoise(c,:)=allMeans(i,:);
    end
end
nrNoiseWaveforms=size(allMeansNoise,1)
r = randperm(nrNoiseWaveforms);
noiseWaveformsInd= r(1:nrNoiseWaveforms);

spiketrain=zeros(1,nrSamples);

for kk=2:30
    for ind=1:kk:nrSamples-300
        spikeInd=ceil(rand*nrNoiseWaveforms);
     
        if spikeInd<1 || spikeInd>nrNoiseWaveforms
             continue;
        end
        
        noiseSpike=allMeansNoise(noiseWaveformsInd(spikeInd),:)  * randn/10000 ;     
        spiketrain(ind:ind+220)=spiketrain(ind:ind+220)+noiseSpike(20:240);
    end
    [num2str(kk) ' of ' num2str(30)]
end

%--- prepare spiketimes
spiketimes=generateSpiketrain_times( realWaveforms, firingRate, refractory, nrSamples, Fs);

%if there are memory problems, terminate program here and store tmp result. than continue with generateSpiketrain_memOptimized.m
%
save('/data2/simulated/sim4/simTmp.mat');
return;

spiketrainsAll=[];
%--- insert spikes into each noise level
waveformsOrig=[];
for kk=1:length(noiseStds)
    %want -> std of noise fixed at noiseStd
    scaleNoiseFactor = 1/( std(spiketrain)/noiseStds(kk) );
    spiketrainLevel = spiketrain*scaleNoiseFactor;
    
    waveformsOrigLevel=[];

    for i=1:realWaveforms
        spikeFormsOrigClass=[];

        spiketimesClass=spiketimes{i}*4;
    
        spikeWaveform= allMeans(realWaveformsInd(i), :);
        %scale amplitude
        spikeWaveform = spikeWaveform * scalingFactorSpikes(i);
        
        c=0;
        for j=1:length(spiketimesClass)  %for each spike for this neuron
            %add a spike here
            currentInd=spiketimesClass(j)-55;
            spiketrainLevel( currentInd:currentInd+220) = spiketrainLevel(currentInd:currentInd+220)+spikeWaveform(20:240); 
            c=c+1;
            spikeFormsOrigClass(c,:)=spiketrainLevel(currentInd:currentInd+220);
        end

        waveformsOrigLevel{i}=spikeFormsOrigClass;    
    end
    waveformsOrig{kk}=waveformsOrigLevel;    

    %downsample
%    spiketrainsAll{kk} = downsample(spiketrainLevel,4);
end
