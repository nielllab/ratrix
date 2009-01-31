%--under development
%
%plots the crosscorrelation between two neurons
%
%urut/oct06

%---crosscorr
function clusterCrosscorr(filename, clNr1, clNr2)

%filename='/data/SF_032406/sortNORE/5/A22_sorted_new.mat';
%clNr1=3152;
%clNr2=3146;

%---

load(filename);


timestamps=newTimestampsNegative;
assigned=assignedNegative;

t1=timestamps( find(assigned==clNr1) );
t1=t1/1000;
t2=timestamps( find(assigned==clNr2) );
t2=t2/1000;

maxlag=200;
[c,lags]=pxcorr(t1,t2, 1, maxlag);
c=c(maxlag+1:end);

kSize=2;
gaussKernel = getGaussianKernel(2, kSize);
smooth=conv(c,gaussKernel);

%[c,lags]=xcorr(t1,t2,30,'coeff');

figure(23);
h(1)=plot( 1:length(c), c, 'k');
hold on
h(2)=plot(1:length(smooth), smooth, 'r', 'LineWidth', 2);
hold off
xlim([0 maxlag-10]);
legend(h,{'Raw','Smooth s=2'});
xlabel('lag [ms]');
ylabel('incidence');
title(['cross correlation ' num2str(clNr1) ' with ' num2str(clNr2)]);

