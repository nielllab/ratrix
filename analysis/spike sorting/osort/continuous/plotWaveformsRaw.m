%
%plots all raw waveforms and a histogram plus a zoom-in on the peak part
%
%urut/2004
function plotWaveformsRaw( allSpikesRawFiltered, allSpikesRawDenoised, timestamps, label )

if size(allSpikesRawFiltered,1)==0
    return;
end


nrSamples=size(allSpikesRawFiltered,2); %nrSamples are multiplies of 64

subplot(2,2,1)
plot ( 1:nrSamples, allSpikesRawFiltered, 'r');
title([label ' raw waveforms, unsorted. n=' num2str(size(allSpikesRawFiltered,1)) ] );
xlabel(['time (' num2str(0.04/(nrSamples/64)) 'ms  per point), 2.56ms total']);
ylabel('uV');
xlim([1 256]);

%text(-21,-10,label,'Rotation',90);
subplot(2,2,2)
if length(timestamps)>0
    dd=diff(timestamps);
    dd=dd/1000; %to ms

    [n]=histc(dd, 1:1:100);
    bar(1:1:100,n,'histc');
    xlabel('[ms]');
end
xlim([1 90]);

subplot(2,2,3)
plot ( 1:size(allSpikesRawDenoised,2), allSpikesRawDenoised, 'r');
title([label ' raw waveforms, unsorted. Decorrelated/Denoised. n=' num2str(size(allSpikesRawFiltered,1)) ] );
xlabel(['time (' num2str(0.04/(nrSamples/64)) 'ms  per point), 2.56ms total']);
ylabel('uV');
xlim([1 size(allSpikesRawDenoised,2)]);

subplot(2,2,4)
S=std(allSpikesRawFiltered);
plot(1:256, S,'r');
ymax=ylim;
line([95 95],[ymax(1) ymax(2)],'color','m');
title(['STD mean=' num2str(mean(S))]);