%super simple example

d=getSmalls('195');
daysAgo=10;
d=removeSomeSmalls(d,d.date<now-daysAgo);

figure; doPlot('percentCorrect',d)
figure; doPlot('plotBias',d)
figure; plotBodyWeights({'195'})
