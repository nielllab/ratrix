

spikes=newSpikesNegative(find(assignedNegative==671),:);
[pxxAvNoise,wN] = calcAvPowerspectrum( noiseTraces, 25000, 99999);
[pxxAvSpikes,wS] = calcAvPowerspectrum( spikes, 100000, 99999);


figure(9)
set(gca,'FontSize',14);
plot(wN,log(pxxAvNoise), 'r', wS, log(pxxAvSpikes), 'b','LineWidth',3)
xlabel('[Hz]');
ylabel('log(power)');

legend('Noise', 'Valid Spikes');

xlim([0 6000]);

title('Av PSD of noise and spikes [P3S2A12-C671 n=10303]');
