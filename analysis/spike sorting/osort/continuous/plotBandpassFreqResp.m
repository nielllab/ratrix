%plots frequency response of the bandpass filters used

%== response of existing filter
Fs=32556;
n=20;
bandpass=[300 3000];

[b,a]=butter(n,bandpass/(Fs/2));

figure(2);
freqz(b,a, [], Fs);

title(['butter n=' num2str(n) ' bassband=' num2str(bandpass)]);

%== response of new filter
%load ..
%HdFilt3 is exported from fdatool.
load('contFilt32556_1.mat');
b=HdFilt3.Numerator;
a=HdFilt3.Denominator;

%verify whether the filter is stable
isstable(HdFilt3)

figure(3);
freqz(b,a, [], Fs);
title(['butter 10th order designed 300-4000']);


%save('contFilt32556_1.mat','HdFilt3')


