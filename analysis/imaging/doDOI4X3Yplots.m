%%%% tf tuning plots
% figure('Position', [scsz(3)/2 scsz(2)/2 scsz(3)/scscale scsz(4)/scscale]);
% %use 1st subplot for title/legend
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('TF tuning','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% %tf for each area in pts file
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 14:16,conds),2),1)); % calc mean
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 14:16,conds),2),1)); %calc sem
%     mseb(1:3,d',dsd',[],1); %plot mean +/-sem
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 3 0 1])
% end
% 
% %%%% sf tuning plots
% figure('Position', [scsz(1) scsz(2) scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('SF tuning','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 8:13,conds),2),1));
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 8:13,conds),2),1));
%     mseb(1:6,d',dsd',[],1);    
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 6 0 1])
% end
% 
%    
% %%%% y tuning plots
% figure('Position', [scsz(3)/2 scsz(2)/2 scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Y tuning','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 5:7,conds),2),1));
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 5:7,conds),2),1));
%     mseb(1:3,d',dsd',[],1);
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 3 0 1])
% end
% 
% %%%% x tuning plots
% figure('Position', [scsz(1) scsz(2) scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('X tuning','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 1:4,conds),2),1));
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 1:4,conds),2),1));
%     mseb(1:4,d',dsd',[],1)
%     title(sprintf(cell2mat(areanames(area))));
% end
% 
% 
% %%%% cycle averages
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Cycle averages','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = circshift(squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range, :,conds),2),1))',10);
%     dsd = circshift(squeeze(mean(mean(sdcycavg(x(area)+range, y(area)+range, :,conds),2),1))',10);
%     mseb(1:15,d,dsd,[],1);
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 15 -0.02 0.02])
% end
% 
% %%%% norm cycle averages
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Norm Cycle averages','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range, :,conds),2),1))';
%     for i = 1:length(conds) %this normalization can be done more efficiently, figure out how please
%         [dmin1 dmin2] = min(d(i,:));
%         [dmax1 dmax2] = max(d(i,:));
%         d(i,:) = circshift((d(i,:) - dmin1)/(dmax1-dmin1),10);
%     end   
%     plot(1:15,d);
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 15 0 1])
% end



%%figures for PDF

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
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 14:16,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 14:16,conds),2),1));
    mseb(1:3,d',dsd',[],1);
    title(sprintf(cell2mat(areanames(area))));
    axis([1 3 0 1])
end
set(gcf, 'PaperPositionMode', 'auto');
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
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 8:13,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 8:13,conds),2),1));
    mseb(1:6,d',dsd',[],1);    
    title(sprintf(cell2mat(areanames(area))));
    axis([1 6 0 1])
end
set(gcf, 'PaperPositionMode', 'auto');
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
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 5:7,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 5:7,conds),2),1));
    mseb(1:3,d',dsd',[],1);
    title(sprintf(cell2mat(areanames(area))));
    axis([1 3 0 1])
end
set(gcf, 'PaperPositionMode', 'auto');
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
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range, 1:4,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range, 1:4,conds),2),1));
    mseb(1:4,d',dsd',[],1)
    title(sprintf(cell2mat(areanames(area))));
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
   

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
    d = circshift(squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range, :,conds),2),1))',10);
    dsd = circshift(squeeze(mean(mean(sdcycavg(x(area)+range, y(area)+range, :,conds),2),1))',10);
    mseb(1:15,d,dsd,[],1);
    title(sprintf(cell2mat(areanames(area))));
    axis([1 15 -0.02 0.02])
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
   
%%%% norm cycle averages
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('Norm Cycle averages','position',[0.5 0.5],'color','r','fontsize',20)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    d = squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range, :,conds),2),1))';
    for i = 1:length(conds) %this normalization can be done more efficiently, figure out how please
        [dmin1 dmin2] = min(d(i,:));
        [dmax1 dmax2] = max(d(i,:));
        d(i,:) = circshift((d(i,:) - dmin1)/(dmax1-dmin1),10);
    end   
    plot(1:15,d);
    title(sprintf(cell2mat(areanames(area))));
    axis([1 15 0 1])
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
   



% %amp(:,:,i) = max(allmnfit(:,:,1:4,:),[],3); 