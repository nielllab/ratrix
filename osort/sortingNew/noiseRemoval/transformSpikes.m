% %function [newSpikes2,newTimestamps2] = transformSpikes( spikes, timestamps, noiseAutocorr )
% 
% figure(776)
% plot( spikeWaveformsNegative(:,:)' );
% figure(775)
% plot( filteredSignal )
% 
% stdEst=std(noiseTraces(:));
% 
% noise=[];
% for i=1:size(noiseTraces,1)
%     noise(i,:)=noiseTraces(i,:)./std(noiseTraces(i,:));
% end
% 
% 
% spikeWaveformsNegative=spikeWaveformsNegative./stdEst;
% 
% corrEst=[];
% for i=1:size(noise,1)
%     %[X,R]=corrmtx(noise(i,:),63,'covariance');
%     cc=xcorr( noise(i,:), 63, 'biased');
%     corrEst(i,:)=cc(64:end);
% end
% 
% autocorr=mean(corrEst);


C=(cov(noiseTracesTmp(1:end,1:64)+.01*randn(size(noiseTracesTmp,1),64)));
rank(C)


[transformedSpikes,transformedBack,Rinv] = transformBasis ( spikeWaveforms,C );
[transformedSpikes2,Sspectrum] = removeWhitenoise(transformedSpikes,3);

transformedSpikes3=transformedSpikes2*Rinv;   %correlate again

%[newSpikes2,newTimestamps2] = realigneSpikes(transformedSpikes, 1:size(transformedSpikes,1), 3);

range=[10:40];

%distribution
figure(776);
subplot(2,2,1);
plot(transformedSpikes(range,:)');
title('Decorrelated');

subplot(2,2,2)
m=mean( transformedSpikes(range,:));
plot(m);

subplot(2,2,3)

resd=(transformedSpikes(range,:)-repmat(m,length(range),1)).^2;
resdPerSpike=sum(resd');
hist(resdPerSpike,100);


plot( transformedSpikes2X(20:30,:)')

m=mean( transformedSpikes2X(20:30,:));

plot(m);

resd=(transformedSpikes2X(20:30)-repmat(m,10,1)).^2;
resdPerSpike=sum(resd');
hist(resdPerSpike,100);

ch=chi2pdf([1:450],256);
figure;plot(1:450,ch)
x = chi2inv(0.95,64)

transformedSpikes2X

%

%--
figure(777)

subplot(3,2,1);
plot(spikeWaveforms(range,:)');
title('Original, as recorded');

subplot(3,2,2);
plot(transformedSpikes(range,:)');
title('Decorrelated');

subplot(3,2,3)
plot(Sspectrum(range,:)','o');
title('SVD: Singular value spectrum');
ylabel('[sig_ii/sig_11]');

subplot(3,2,4);
plot(transformedSpikes2(range,:)');
title('TSVD white noise removal');

subplot(3,2,5)
plot(transformedSpikes3(range,:)');
title('Correlations re-introduced');


%--


figure(765)
range=[30:105];
tsp=transformedSpikes(range,:);
subplot(1,3,1)
plot(tsp')
subplot(1,3,2)
plot(spikeWaveformsNegative(range,:)')

xd=[];
for i=1:length(range)
xd(i,:) = wden(tsp(i,:),'heursure','s','one',3,'sym8');
end

%xd = wden(tsp,'minimaxi','s','sln',10,'sym8');

subplot(1,3,3)
plot(xd')


figure(888)
range=[10:15];

subplot(2,3,1)
plot(transformedSpikes(range,:)', 'LineWidth', 3);
xlim([1 64]);
%ylim([-0.04 0.04]);
title('All correlations removed');

subplot(2,3,2)
plot(spikeWaveformsNegative(range,:)', 'LineWidth', 3);
xlim([1 64]);

title('Original');


subplot(2,3,3)
plot(transformedSpikes2(range,:)','LineWidth', 3);
title('white noise removed');


subplot(2,3,4)
plot(transformedSpikes3(range,:)','LineWidth', 3);
title('Transformed back');

subplot(2,3,5)
%plot(autocorr);
plot( C(1,:) )