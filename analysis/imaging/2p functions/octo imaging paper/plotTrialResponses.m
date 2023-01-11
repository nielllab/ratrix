gratingTitle=0; %%% titles for grating figs?
evRange = 10:20; baseRange = 1:5; %%% timepoints for evoked and baseline activity
dfofInterp(dfofInterp>1) = 1; dfofInterp(dfofInterp<-1) = -1; 
dfInterpsm = imresize(dfofInterp,0.25);
dfWeight = dfInterpsm.* repmat(imresize(normgreen(:,:,1),0.25),[1 1 size(dfofInterp,3)]);

traceLength = 40; baseRange = 1:5
pixTcourse = zeros(size(dfofInterp,1),size(dfofInterp,2),traceLength,length(stimOrder));
for i = 1:length(stimOrder); %%% get pixel-wise evoked activity on each individual stim presentation
  i
  startFrame = (stimTimes(i)-0.5)/dt;
%     trialmean(:,:,i) = nanmean(dfofInterp(:,:,round(startFrame + evRange)),3)- nanmean(dfofInterp(:,:,round(startFrame + baseRange)),3);
%     trialTcourse(:,i) = squeeze(mean(mean(dfofInterp(:,:,round(startFrame + (1:30))),2),1)) - mean(mean(dfofInterp(:,:,round(startFrame + 1)),2),1) ;
%     weightTcourse(:,i) = (squeeze(mean(mean(dfWeight(:,:,round(startFrame + (1:30))),2),1)) - mean(mean(mean(dfWeight(:,:,round(startFrame + baseRange)),3),2),1))/mean(normgreen(:)) ;
    pixTcourse(:,:,:,i) = dfofInterp(:,:,round(startFrame + (1:traceLength))) - repmat(nanmean(dfofInterp(:,:,round(startFrame + baseRange)),3),[1 1 traceLength]);
end


nStim = max(stimOrder)
clear pixTcourse_mn
for c = 1:nStim    
    pixTcourse_mn(:,:,:,c) = nanmean(pixTcourse(:,:,:,stimOrder==c),4);
end

filt = fspecial('gaussian',10,3);
pixTcourse_filt = imfilter(pixTcourse_mn,filt);
crange = [-0.05 0.5];

for c = 1:nStim
   figure
   sgtitle(sprintf('stim %d',c));
   for f = 1:24;
        subplot(4,6,f);
        imagesc(pixTcourse_filt(:,:,f,c),crange*0.5);
        colormap jet
        axis equal
   end
   drawnow
end

%%% mean across all conditions
figure
for f= 1:24
    subplot(4,6,f)
    imagesc(nanmean(pixTcourse_filt(:,:,f,:),4),crange*0.25);
    colormap jet
    axis equal
end
sgtitle('mean across conditions')


crange = [0 0.5]
for c = 31
   figure
   sgtitle(sprintf('stim %d',c));
   for f = 2:2:traceLength;
        subplot(4,5,f/2);
        %imagesc(pixTcourse_filt(:,:,f,c).*(normgreen(:,:,1)),crange*0.5);
        resp = mat2im(pixTcourse_filt(:,:,f,c),hot, crange*0.5); % or hot
        imshow(0.5*resp + 0.5*repmat(stdImg,[1 1 3])/nanmax(stdImg(:)));
        %colormap jet
        axis equal
   end
end
figure
imagesc(stdImg);
axis equal
colormap gray

pixTcourse_mn = nanmean(pixTcourse_filt,4);

figure
imagesc(pixTcourse_mn(:,:,15));
hold on
clear x y
for i = 1:4
    [x(i) y(i)] = ginput(1);
    plot(x(i),y(i),'o','Markersize',8);
end
x = round(x); y= round(y)


figure
hold on
for i = 1:4
    plot(((1:traceLength) - 7)/10,squeeze(nanmean(pixTcourse_mn(y(i)+range,x(i)+range,:),[1 2])));
end
xlabel('secs')
ylabel('dF/F')
xlim([-0.5 3]); ylim([-0.025 0.1])
legend

figure
hold on
for i = 1:4
    plot(((1:traceLength) - 7)/10,squeeze(nanmean(pixTcourse_filt(y(i)+range,x(i)+range,:,31),[1 2])));
end
xlabel('secs')
ylabel('dF/F')
xlim([-0.5 3]); ylim([-0.025 0.25])

figure
imagesc(stdImg);
colormap gray
hold on
for i = 1:4
    plot(x(i),y(i),'o','MarkerSize',8)
end

figure

resp = mat2im(pixTcourse_mn(:,:,15),jet, crange*0.5); % or hot
imshow(0.5*resp + 0.5*repmat(stdImg,[1 1 3])/nanmax(stdImg(:)));
        
        
%%% mean timecourse for each stim
tcourse = squeeze(nanmean(pixTcourse_mn,[1 2]));
figure
plot(1:traceLength,tcourse);
hold on
plot(mean(tcourse,2),'g','LineWidth',2);
title('mean timecourse')

        

%%% plot timecourse of N random locations
x = rand(64,1)*(size(dfofInterp,1)-62) + 31;
y =rand(64,1)*(size(dfofInterp,2)-62) + 31;
x = round(x); y = round(y);
range = -20:20;
clear traces
for i = 1:length(x)
    traces(:,i) = squeeze(nanmean(dfofInterp(x(i)+range,y(i)+range,:),[1 2]));
    traces(:,i) = traces(:,i)-nanmean(traces(:,i));
end

%traces = dF(10:20:end,:)';

figure
plot(traces);
xlim([0 300])

figure
for i = 1:length(x);
    hold on
    plot((1:length(traces))/10, traces(:,i)/0.2 + i);
end
xlabel('secs');
ylabel('unit #');
ylim([0 33])
xlim([0 120])
