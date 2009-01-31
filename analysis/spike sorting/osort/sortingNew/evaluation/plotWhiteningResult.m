%
%plot raw waveforms non-whitened and whitened including PCA, for comparison
%
function plotWhiteningResult(corr, newSpikesNegative, allSpikesCorrFree, stdWhitened, plabel)

subplot(2,3,1)
plot(corr)
title([plabel ' autocorr noise']);

[pc,score,latent,tsquare] = princomp(newSpikesNegative);
[pc,score2,latent,tsquare] = princomp(allSpikesCorrFree);

subplot(2,3,2)
plot(score(:,1),score(:,2),'.');
title('raw');
subplot(2,3,3)
plot(score2(:,1),score2(:,2),'.');
title(['whitened std=' num2str(stdWhitened)]);

subplot(2,3,4)
plot(1:256,allSpikesCorrFree(1:500,:),'r');
%ylim([-15 15]);
xlim([1 256]);
title('whitened and realigned');

subplot(2,3,5)
plot(1:256,newSpikesNegative(1:500,:),'r');
xlim([1 256]);
title('orig non-whitened');
