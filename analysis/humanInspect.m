

%%
subjects={'bas'}
dateRange=[datenum('04-Jan-2009 19:34:59') now];
for i=1:length(subjects)
    d=getSmalls(subjects{i},dateRange,103)
    [stats plotParams]=flankerAnalysis(d,'colin+3','performancePerContrastPerCondition', 'pctCor',[],'humanPsych')
end


figure
doPlotPercentCorrect(d,getGoods(d,'humanPsych'))