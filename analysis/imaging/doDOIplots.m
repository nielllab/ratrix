scsz = get( 0, 'Screensize' ); %get screensize for plots
%screensize = get( groot, 'Screensize' ); %get screensize for plots in R2014b and later

%%%% tf tuning plots
figure('Position', [scsz(3)/2 scsz(2)/2 scsz(3)/scscale scsz(4)/scscale]);
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('TF tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 14:16,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
    ylim([0 1])
end

%%%% sf tuning plots
figure('Position', [scsz(1) scsz(2) scsz(3)/scscale scsz(4)/scscale]);
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('SF tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 8:13,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
    ylim([0 1])
end

   
%%%% y tuning plots
figure('Position', [scsz(3)/2 scsz(2)/2 scsz(3)/scscale scsz(4)/scscale]);
% figure('Position', [scsz(3)/2 scsz(4)/2 scsz(3)/scscale scsz(4)/scscale]); %displays at top of screen
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('Y tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 5:7,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
    ylim([0 1])
end

%%%% x tuning plots
figure('Position', [scsz(1) scsz(2) scsz(3)/scscale scsz(4)/scscale]);
% figure('Position', [scsz(1) scsz(4)/2 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('X tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 1:4,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
end


%%%% cycle averages
figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('Cycle averages','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    d = squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range, :,conds),2),1))';
    for i = 1:length(conds) %this normalization can be done more efficiently, figure out how please
        d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
    end   
    plot(circshift(d',10))
    title(sprintf(cell2mat(areanames(area))));
    axis([1 15 0 1])
end



%%figures for PDF

%%%% cycle averages
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('Cycle averages','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    d = squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range, :,conds),2),1))';
    for i = 1:length(conds) %this normalization can be done more efficiently, figure out how please
        d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
    end   
    plot(circshift(d',10))
    title(sprintf(cell2mat(areanames(area))));
    axis([1 15 0 1])
end
print('-dpsc',psfilename,'-append');

%%%% x tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('X tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 1:4,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
end
print('-dpsc',psfilename,'-append');
   
%%%% y tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('Y tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 5:7,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
    ylim([0 1])
end
print('-dpsc',psfilename,'-append');

%%%% sf tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('SF tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 8:13,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
    ylim([0 1])
end
print('-dpsc',psfilename,'-append');

%%%% tf tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('TF tuning','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    plot(squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 14:16,conds),2),1)))
%         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
    title(sprintf(cell2mat(areanames(area))));
    ylim([0 1])
end
print('-dpsc',psfilename,'-append');






% %amp(:,:,i) = max(allmnfit(:,:,1:4,:),[],3); 