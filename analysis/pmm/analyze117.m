
subject = {'117'};
%junk = allToSmall(subject,[now - 9999 now],1,0);
d = getSmalls(subject{1})

%%
figure;
hold on
plot([1:length(d.date)],d.targetContrast,'b.')
plot([1:length(d.date)],d.deviation,'r.')
plot([1:length(d.date)],d.targetOrientation,'g.')
plot([1:length(d.date)],log2(d.pixPerCycs),'c.')
plot([1:length(d.date)],d.step,'k')
% figure; doPlot('percentCorrect', d )


%% 

ss=min(find(d.pixPerCycs==32))
ee=max(find(d.pixPerCycs==32))
some=removeSomeSmalls(d,~(d.trialNumber>ss & d.trialNumber<ee))



clear conditionInds
ppc=unique(some.pixPerCycs)
ppc=ppc(4);
for i=1:length(ppc)
conditionInds(i,:)=(some.pixPerCycs==ppc(i) & some.targetContrast==1);
end

figure; doPlotPercentCorrect(some,[],[],[],[],[],[],[],[],[],[],[],conditionInds);

allContrasts=removeSomeSmalls(d,~(d.trialNumber>140594 & d.trialNumber<153677)); %only the second section of two
oneContrast=removeSomeSmalls(d,~(d.trialNumber>134461 & d.trialNumber<140594)); %only the second section of two

figure; doPlotPercentCorrect(allContrasts,[],[],[],[],[],[],[],[],[],[],[],allContrasts.pixPerCycs==64 & allContrasts.targetContrast==1);
figure; doPlotPercentCorrect(oneContrast,[],[],[],[],[],[],[],[],[],[],[],oneContrast.pixPerCycs==64 & oneContrast.targetContrast==1);



%%
%conclusion: 117 can sustain 70% correct on his previously learned task,(~85% correct)
%even when swamped with many hard ppcs 
%this performance dropped to 65-50% correct with the addition of many hard contrasts. 


%%

%to do: adjust to view discrim ; not just detection 

conditionType='allPixPerCycs';
plotType='performancePerContrastPerCondition'; %performancePerContrastPerCondition, performancePerDeviationPerCondition
performanceMeasure = 'pctCor';
stepUsed = [];
verbose = 0;
figure; flankerAnalysis(oneContrast,  conditionType, plotType,performanceMeasure, stepUsed, verbose)

