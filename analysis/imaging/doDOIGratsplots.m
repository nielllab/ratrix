% %%%% tf tuning plots
% figure('Position', [scsz(3)/2 scsz(2)/2 scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allshiftData(1,1,1,conds)))
% title('X tuning','position',[0.5 0.5],'color','r','fontsize',20)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     plot(squeeze(mean(mean(allshiftData(x(area)+range, y(area)+range, 1:3,conds),2),1)))
% %         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))%%% un-normalize it
%     title(sprintf(cell2mat(areanames(area))));
%     ylim([0 1])
% end

% w = 2;
% figure
% %plot the average? response
% imagesc(mean(allshiftData(:,:,5,:),4));
% hold on
% plot(ypts,xpts,'w.','Markersize',2); axis off
% for i = 1:7;
%     plot([y(i)-w y(i)-w y(i)+w y(i)+w y(i)-w],[x(i)-w x(i)+w x(i)+w x(i)-w x(i)-w])
% end
% axis('square')
% legend(areanames,'location','southeast')
% hold off


% %%%% sf tuning plots
% figure('Position', [scsz(1) scsz(2) scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('SF tuning','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range,6:7,conds),2),1));
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range,6:7,conds),2),1));
%     mseb(1:2,d',dsd',[],1)
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 2 0 1])
% end
%    
% %%%% y tuning plots
% figure('Position', [scsz(3)/2 scsz(2)/2 scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Y tuning','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range,4:5,conds),2),1));
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range,4:5,conds),2),1));
%     mseb(1:2,d',dsd',[],1);
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 2 0 1])
% end
% 
% %%%% x tuning plots
% figure('Position', [scsz(1) scsz(2) scsz(3)/scscale scsz(4)/scscale]);
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('X tuning','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range,1:3,conds),2),1));
%     dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range,1:3,conds),2),1));
%     mseb(1:3,d',dsd',[],1);
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 3 0 max(max(max(allmnfit(:,:,1:3))))])
% end
% 
%%cycle average for low spatial frequency stim
% labels = {'blank','blank+patch','patch','blank decon','b+p decon','patch decon'};
% for area = 1:length(areanames)
%     figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);
%     for s = 1:6
%         subplot(2,3,s);        
%         hold on
%         if s==1
%         mseb(1:25,squeeze(nanmean(inddeconcycavg(1:25,:,area,conds),2))',squeeze(nansem(inddeconcycavg(1:25,:,area,conds),2))');
%         elseif s==2
%         mseb(1:25,squeeze(nanmean(inddeconcycavg(26:50,:,area,conds),2))',squeeze(nansem(inddeconcycavg(26:50,:,area,conds),2))');
%         elseif s==3
%         mseb(1:25,squeeze(nanmean(inddeconcycavg(51:75,:,area,conds),2))',squeeze(nansem(inddeconcycavg(51:75,:,area,conds),2))');
%         elseif s==4
%         mseb(1:25,squeeze(nanmean(indcycavg(1:25,:,area,conds),2))',squeeze(nansem(indcycavg(1:25,:,area,conds),2))');
%         elseif s==5
%         mseb(1:25,squeeze(nanmean(indcycavg(26:50,:,area,conds),2))',squeeze(nansem(indcycavg(26:50,:,area,conds),2))');
%         elseif s==6
%         mseb(1:25,squeeze(nanmean(indcycavg(51:75,:,area,conds),2))',squeeze(nansem(indcycavg(51:75,:,area,conds),2))');
%         end
%         
%         plot([11 11],[0 0.2],':')
%         xlim([1 25]); 
%         if s<=3 
%             ylim([0 0.2]);
%         else
%             ylim([0 0.15])
%         end
%         title(sprintf('low sf %s %s',areanames{area},labels{s}));
%         xlabel('frames')
%     end
%     legend(datafiles(conds),'location','northeast')
% end
% 
% %%cycle average for high spatial frequency stim
% labels = {'blank','blank+patch','patch','blank decon','b+p decon','patch decon'};
% for area = 1:length(areanames)
%     figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);
%     for s = 1:6
%         subplot(2,3,s);        
%         hold on
%         if s==1
%         mseb(1:25,squeeze(nanmean(inddeconcycavg(76:100,:,area,conds),2))',squeeze(nansem(inddeconcycavg(76:100,:,area,conds),2))');
%         elseif s==2
%         mseb(1:25,squeeze(nanmean(inddeconcycavg(101:125,:,area,conds),2))',squeeze(nansem(inddeconcycavg(101:125,:,area,conds),2))');
%         elseif s==3
%         mseb(1:25,squeeze(nanmean(inddeconcycavg(126:150,:,area,conds),2))',squeeze(nansem(inddeconcycavg(126:150,:,area,conds),2))');
%         elseif s==4
%         mseb(1:25,squeeze(nanmean(indcycavg(76:100,:,area,conds),2))',squeeze(nansem(indcycavg(76:100,:,area,conds),2))');
%         elseif s==5
%         mseb(1:25,squeeze(nanmean(indcycavg(101:125,:,area,conds),2))',squeeze(nansem(indcycavg(101:125,:,area,conds),2))');
%         elseif s==6
%         mseb(1:25,squeeze(nanmean(indcycavg(126:150,:,area,conds),2))',squeeze(nansem(indcycavg(126:150,:,area,conds),2))');
%         end
%         
%         plot([11 11],[0 0.2],':')
%         xlim([1 25]); 
%         if s<=3 
%             ylim([0 0.15]);
%         else
%             ylim([0 0.2])
%         end
%         title(sprintf('high sf %s %s',areanames{area},labels{s}));
%         xlabel('frames')
%     end
%     legend(datafiles(conds),'location','northeast')
% end

% %circleshifted non-normalized cycle average
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1))';
%     for i = 1:length(conds)
%         d(i,:) = (d(i,:) - min(d(i,:)));
%     end
%     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
%     title(sprintf(cell2mat(areanames(area))));
%     axis([0.1 2.5 0 0.075]);
% end
% 
% %circleshifted cycle average
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Norm CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1))';
%     for i = 1:length(conds)
%         d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
%     end
%     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
%     title(sprintf(cell2mat(areanames(area))));
%     axis([0.1 2.5 0 1])
% end
% 
% %%%% non-norm deconvolved circleshifted cycle averages
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Decon CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1));
%     repd = repmat(d,[10 1]);
%     dconvd = deconvg6s(repd'+0.5,0.1);
%     d = dconvd(:,(ceil(length(dconvd)/2)):((ceil(length(dconvd)/2))+ceil(length(dconvd)/10)));
%     for i = 1:length(conds)
%         d(i,:) = (d(i,:) - min(d(i,:)));
%     end
%     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
%     title(sprintf(cell2mat(areanames(area))));    
%     axis([0.1 2.5 0 0.11])
% end
% 
% %%%% normalized deconvolved circleshifted cycle averages
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Decon Norm CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1));
%     repd = repmat(d,[10 1]);
%     dconvd = deconvg6s(repd'+0.5,0.1);
%     d = dconvd(:,(ceil(length(dconvd)/2)):((ceil(length(dconvd)/2))+ceil(length(dconvd)/10)));
%     for i = 1:length(conds)
%         d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
%     end
%     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
%     title(sprintf(cell2mat(areanames(area))));    
%     axis([0.1 2.5 0 1])
% end

% %%%% cycle averages
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d = squeeze(mean(mean(allcycavg(x(area)+range, y(area)+range,:,conds),2),1))';
%     for i = 1:length(conds) %this normalization can be done more efficiently, figure out how please
%         d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
%     end   
%     plot(d')
% %     plot(circshift(d',10))
%     title(sprintf(cell2mat(areanames(area))));
%     axis([1 25 0 1])
% end


% deconvolved cycle average
% figure('Position', [scsz(3)/4 scsz(4)/2-scsz(4)/10 scsz(3)/scscale scsz(4)/scscale]);%displays at top of screen
% subplot(2,4,1)
% plot(0,squeeze(allmnfit(1,1,1,conds)))
% title('Decon Shift CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% axis([0 1 0 1])
% axis off
% legend(datafiles(conds),'location','south')
% for area = 1:7
%     subplot(2,4,area+1)
%     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1));
%     repd = repmat(d,[10 1]);
%     dconvd = deconvg6s(repd'+0.5,0.1);
%     d = dconvd(:,31:45);
%     for i = 1:length(conds)
%         d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
%     end
%     plot(d')
%     axis([0.1 1.5 0 1])
% end
% 


%%%        
%figures for PDF

% % w = 2;
% % figure('visible','off');
% % imagesc(mean(allshiftData(:,:,5,:),4));
% % hold on
% % plot(ypts,xpts,'w.','Markersize',2); axis off
% % for i = 1:7;
% %     plot([y(i)-w y(i)-w y(i)+w y(i)+w y(i)-w],[x(i)-w x(i)+w x(i)+w x(i)-w x(i)-w])
% % end
% % legend(areanames,'location','southeast')
% % axis('square')
% % legend(areanames,'location','southeast')
% % hold off
% % print('-dpsc',psfilename,'-append');

%%%% SF tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('SF tuning','position',[0.5 0.5],'color','r','fontsize',12)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range,6:7,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range,6:7,conds),2),1));
    mseb(1:2,d',dsd',[],1)
    title(sprintf(cell2mat(areanames(area))));
    axis([1 2 0 1])
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
   
%%%% y tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('Y tuning','position',[0.5 0.5],'color','r','fontsize',12)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range,4:5,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range,4:5,conds),2),1));
    mseb(1:2,d',dsd',[],1);
    title(sprintf(cell2mat(areanames(area))));
    axis([1 2 0 1])
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

%%%% x tuning plots
figure('visible','off');
subplot(2,4,1)
plot(0,squeeze(allmnfit(1,1,1,conds)))
title('X tuning','position',[0.5 0.5],'color','r','fontsize',12)
axis([0 1 0 1])
axis off
legend(datafiles(conds),'location','south')
for area = 1:7
    subplot(2,4,area+1)
    d = squeeze(mean(mean(allmnfit(x(area)+range, y(area)+range,1:3,conds),2),1));
    dsd = squeeze(mean(mean(sdmnfit(x(area)+range, y(area)+range,1:3,conds),2),1));
    mseb(1:3,d',dsd',[],1);
    title(sprintf(cell2mat(areanames(area))));
    axis([1 3 0 max(max(max(allmnfit(:,:,1:3))))])
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

%%%%  cycle average for low spatial frequency stim
labels = {'blank decon','b+p decon','patch decon','blank','blank+patch','patch'};
for area = 1:length(areanames)
    figure('visible','off');
    for s = 1:6
        subplot(2,3,s);        
        hold on
        if s==1
        mseb(1:25,squeeze(nanmean(inddeconcycavg(1:25,:,area,conds),2))',squeeze(nansem(inddeconcycavg(1:25,:,area,conds),2))');
        elseif s==2
        mseb(1:25,squeeze(nanmean(inddeconcycavg(26:50,:,area,conds),2))',squeeze(nansem(inddeconcycavg(26:50,:,area,conds),2))');
        elseif s==3
        mseb(1:25,squeeze(nanmean(inddeconcycavg(51:75,:,area,conds),2))',squeeze(nansem(inddeconcycavg(51:75,:,area,conds),2))');
        elseif s==4
        mseb(1:25,squeeze(nanmean(indcycavg(1:25,:,area,conds),2))',squeeze(nansem(indcycavg(1:25,:,area,conds),2))');
        elseif s==5
        mseb(1:25,squeeze(nanmean(indcycavg(26:50,:,area,conds),2))',squeeze(nansem(indcycavg(26:50,:,area,conds),2))');
        elseif s==6
        mseb(1:25,squeeze(nanmean(indcycavg(51:75,:,area,conds),2))',squeeze(nansem(indcycavg(51:75,:,area,conds),2))');
        end
        
        xlim([1 25]); 
        if s<=3 
            ylim([0 0.2]);
        else
            ylim([0 0.15])
        end
        title(sprintf('low sf %s %s',areanames{area},labels{s}));
        xlabel('frames')
    end
    legend(datafiles(conds),'location','northeast')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end


%%%% cycle average for high spatial frequency stim
labels = {'blank decon','b+p decon','patch decon','blank','blank+patch','patch'};
for area = 1:length(areanames)
    figure('visible','off');
    for s = 1:6
        subplot(2,3,s);        
        hold on
        if s==1
        mseb(1:25,squeeze(nanmean(inddeconcycavg(76:100,:,area,conds),2))',squeeze(nansem(inddeconcycavg(76:100,:,area,conds),2))');
        elseif s==2
        mseb(1:25,squeeze(nanmean(inddeconcycavg(101:125,:,area,conds),2))',squeeze(nansem(inddeconcycavg(101:125,:,area,conds),2))');
        elseif s==3
        mseb(1:25,squeeze(nanmean(inddeconcycavg(126:150,:,area,conds),2))',squeeze(nansem(inddeconcycavg(126:150,:,area,conds),2))');
        elseif s==4
        mseb(1:25,squeeze(nanmean(indcycavg(76:100,:,area,conds),2))',squeeze(nansem(indcycavg(76:100,:,area,conds),2))');
        elseif s==5
        mseb(1:25,squeeze(nanmean(indcycavg(101:125,:,area,conds),2))',squeeze(nansem(indcycavg(101:125,:,area,conds),2))');
        elseif s==6
        mseb(1:25,squeeze(nanmean(indcycavg(126:150,:,area,conds),2))',squeeze(nansem(indcycavg(126:150,:,area,conds),2))');
        end
        
        xlim([1 25]); 
        if s<=3 
            ylim([0 0.2]);
        else
            ylim([0 0.15])
        end
        title(sprintf('high sf %s %s',areanames{area},labels{s}));
        xlabel('frames')
    end
    legend(datafiles(conds),'location','northeast')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

% % %circleshifted non-normalized cycle average
% % figure('visible','off');
% % subplot(2,4,1)
% % plot(0,squeeze(allmnfit(1,1,1,conds)))
% % title('CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% % axis([0 1 0 1])
% % axis off
% % legend(datafiles(conds),'location','south')
% % for area = 1:7
% %     subplot(2,4,area+1)
% %     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1))';
% %     for i = 1:length(conds)
% %         d(i,:) = (d(i,:) - min(d(i,:)));
% %     end
% %     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
% %     title(sprintf(cell2mat(areanames(area))));
% %     axis([0.1 2.5 0 0.075]);
% % end
% % print('-dpsc',psfilename,'-append');
% % 
% % %circleshifted cycle average
% % figure('visible','off');
% % subplot(2,4,1)
% % plot(0,squeeze(allmnfit(1,1,1,conds)))
% % title('Norm CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% % axis([0 1 0 1])
% % axis off
% % legend(datafiles(conds),'location','south')
% % for area = 1:7
% %     subplot(2,4,area+1)
% %     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1))';
% %     for i = 1:length(conds)
% %         d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
% %     end
% %     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
% %     title(sprintf(cell2mat(areanames(area))));
% %     axis([0.1 2.5 0 1])
% % end
% % print('-dpsc',psfilename,'-append');
% % 
% % %%%% non-norm deconvolved circleshifted cycle averages
% % figure('visible','off');
% % subplot(2,4,1)
% % plot(0,squeeze(allmnfit(1,1,1,conds)))
% % title('Decon CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% % axis([0 1 0 1])
% % axis off
% % legend(datafiles(conds),'location','south')
% % for area = 1:7
% %     subplot(2,4,area+1)
% %     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1));
% %     repd = repmat(d,[10 1]);
% %     dconvd = deconvg6s(repd'+0.5,0.1);
% %     d = dconvd(:,(ceil(length(dconvd)/2)):((ceil(length(dconvd)/2))+ceil(length(dconvd)/10)));
% %     for i = 1:length(conds)
% %         d(i,:) = (d(i,:) - min(d(i,:)));
% %     end
% %     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
% %     title(sprintf(cell2mat(areanames(area))));    
% %     axis([0.1 2.5 0 0.11])
% % end
% % print('-dpsc',psfilename,'-append');
% % 
% % %%%% normalized deconvolved circleshifted cycle averages
% % figure('visible','off');
% % subplot(2,4,1)
% % plot(0,squeeze(allmnfit(1,1,1,conds)))
% % title('Decon Norm CycAvg','position',[0.5 0.5],'color','r','fontsize',12)
% % axis([0 1 0 1])
% % axis off
% % legend(datafiles(conds),'location','south')
% % for area = 1:7
% %     subplot(2,4,area+1)
% %     d=squeeze(mean(mean(allcycavg(x(area)+range,y(area)+range,:,conds),2),1));
% %     repd = repmat(d,[10 1]);
% %     dconvd = deconvg6s(repd'+0.5,0.1);
% %     d = dconvd(:,(ceil(length(dconvd)/2)):((ceil(length(dconvd)/2))+ceil(length(dconvd)/10)));
% %     for i = 1:length(conds)
% %         d(i,:) = (d(i,:) - min(d(i,:)))/(max(d(i,:))-min(d(i,:)));
% %     end
% %     plot(0.1:0.1:(0.1*length(d)),circshift(d',10));
% %     title(sprintf(cell2mat(areanames(area))));    
% %     axis([0.1 2.5 0 1])
% % end
% % print('-dpsc',psfilename,'-append');



        
% % 
% % %         amp(:,:,i) = max(allmnfit(:,:,1:4,:),[],3); 
% % %         plot(squeeze(allmnfit(x(area)+(-2:2),y(area),1:4,:).*squeeze((amp(x(i),y(i),:))
% %         %un-normalizes data via x tuning
