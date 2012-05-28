function makePerfBiasPlot(x,data,c,doBlack)
makeConfPlot(x,data.bias,c{2},doBlack);
makeConfPlot(x,data.perf,c{1},doBlack);
end