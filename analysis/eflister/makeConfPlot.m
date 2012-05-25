function makeConfPlot(x,d,c,doBlack)
if ~isempty(x)

    if exist('doBlack','var') && ~isempty(doBlack) && doBlack
        transparency = .5;
        bw = 'w';               
    else
        transparency = .2;
        bw = 'k';
    end
    
    if strcmp(c,'k')
        c=bw;
    end
    
    chance=.5;
    plot([1 max(x)],chance*ones(1,2),bw);
    hold on
        
    fill([x x(length(x):-1:1)],[d.pci(:,2)' d.pci(length(x):-1:1,1)'],c,'FaceAlpha',transparency,'LineStyle','none');
    
    if false
        plot(x,d.phat,c);
        errorbar(x,d.phat,d.phat-d.pci(:,1)',d.pci(:,2)'-d.phat,c);
    end
    
    ylim([0 1]);
    xlim([1 max(x)]);
end
end