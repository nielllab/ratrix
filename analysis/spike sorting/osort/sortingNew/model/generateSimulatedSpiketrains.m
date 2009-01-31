%generate simulated spiketrains of different lengths
%
%


load('allMeans.mat');

indsSimilar = find( allMeans(:,94) > 500 & allMeans(:,94)<600 );
indsSimilar=indsSimilar(1:5);
figure(20);
plot(1:256, allMeans(indsSimilar,:) );


noiseStd=0.05;
nrSamples=500*100000;  %x sec, at 100kHz

%realWaveformsInd = indsSimilar;

realWaveformsInd=[81 77]

figure(21);
plot(1:256, allMeans(realWaveformsInd,:), 'linewidth',2);
legend('81','77');
xlim([1 256]);


%realWaveformsIndAll=[2 51 61 72 81];
%realWaveformsInd=realWaveformsIndAll([ 2 3 5]);

i=1;
%for i=1:4
    i
    noiseStdThis=i*noiseStd;   

    %the variables returned here are according to an old version of generateSpiketrain -- needs to be fixed before this can be used!
    [spiketrainNoise, spiketrain, spiketrainDown, realWaveformsInd, noiseWaveformsInd,spiketimes] = generateSpiketrain(allMeans, realWaveformsInd, nrSamples, noiseStdThis);
    
%    save(['/data2/simulated/simulatedNew2' num2str(i) '.mat']);
%end
%-- [spiketrains, realWaveformsInd, noiseWaveformsInd,spiketimes,waveformsOrigAll,scalingFactorSpikes] = generateSpiketrain(allMeans, realWaveformsInd, nrSamples, noiseStds);

%renvar spiketrainsAll spiketrains

%save('/data2/simulated/simulatedNew_1000s_sim1_level1.mat', 'spiketrains', 'realWaveformsInd', 'allMeans', 'spiketimes', 'scalingFactorSpikes', 'noiseStds','nrSamples');

%save('/data2/simulated/simulatedNew_1000s_sim1_level1.mat','noiseStds','nrSamples','realWaveformsInd','spiketimes','spiketrain')
