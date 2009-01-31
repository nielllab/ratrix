function plotDetectionROC( TPall, FPall, thresholds, labels, xlims, ylims, ptitle)

colors={'r-','g-','b-','m-','r--','g--','b--','m--'};

hold on
h=[];
for i=1:length(FPall)
    if length(FPall{i}>0)
        h(i) = plot( FPall{i}, TPall{i},['d' colors{i}],'MarkerSize',15,'linewidth',2);
        
        Ts=thresholds{i};
        for j=1:length(Ts)
            text( FPall{i}(j), TPall{i}(j), ['T=' num2str(Ts(j))]);
        end        
    end
end
hold off
legend(h,labels);

xlabel('P(false alarm)');
ylabel('P(hit)');
xlim(xlims);
ylim(ylims);

title(ptitle);
