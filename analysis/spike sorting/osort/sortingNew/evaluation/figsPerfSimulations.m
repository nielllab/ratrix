

%table1

correctDetected=[100 100 97 82];
TP=[96 95 90 83];
FP=[0 0 3 15];

figure(2)
bar([correctDetected; TP; FP]','grouped');
legend('detected', 'true positives (% detected)','false positives (% detected)');
ylabel('Percent of detected');
set(gca,'XTickLabel',{'6.7','3.4','2.2','1.2'});
xlabel('Noise level (SNR)');


%table3
correctDetected=[100 91 58 41];
TP=[92 83 71 68];
FP=[0 10 21 32];