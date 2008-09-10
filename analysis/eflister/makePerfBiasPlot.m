function makePerfBiasPlot(x,data,c)
chance=.5;
plot([1 max(x)],chance*ones(1,2),'k');
hold on
makeConfPlot(x,data.bias,c{2});
makeConfPlot(x,data.perf,c{1});
ylim([0 1]);
xlim([1 max(x)]);
end

function makeConfPlot(x,d,c)
transparency=.2;

fill([x x(length(x):-1:1)],[d.pci(:,2)' d.pci(length(x):-1:1,1)'],c,'FaceAlpha',transparency,'LineStyle','none');
hold on
plot(x,d.phat,c);
errorbar(x,d.phat,d.phat-d.pci(:,1)',d.pci(:,2)'-d.phat,c);
end