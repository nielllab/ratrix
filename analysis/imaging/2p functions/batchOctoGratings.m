close all
clear all

batchOctoSutterLobe

%used = find( strcmp({files.stim},'6x4blocks'));

used = find( strcmp({files.stim},'360gratings'));

for sess = 1:length(used)
    folder = [pathname '\' files(used(sess)).path];
    fname = [files(used(sess)).tif(1:end-4) '.mat'];
    sprintf('loading %s',fullfile(folder,fname))
    load(fullfile(folder,fname));
    
    figString =sprintf('%s loc %d ',files(used(sess)).expt, files(used(sess)).location);
    
    
    range = [-0.05 0.2]; %%% colormap range
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = [figString 'vert1 gratings'];
    npanel = 6; nrow = 2; ncol = 3; offset = 0;
    pixPlot;
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = [figString 'horiz1 gratings'];
    npanel = 6; nrow = 2; ncol = 3; offset = 6;
    pixPlot;
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = [figString 'vert2 gratings'];
    npanel = 6; nrow = 2; ncol = 3; offset = 12;
    pixPlot;
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = [figString 'horiz2 gratings'];
    npanel = 6; nrow = 2; ncol = 3; offset = 18;
    pixPlot;
    
    loc = 1:2 %%% map stim order onto subplot
    figLabel = 'flicker';
    npanel = 2; nrow = 1; ncol = 2; offset = 24;
    pixPlot;
    
    drawnow
    
    for i = 1:26;
        resp(sess,i) = mean(nanmedian(trialTcourse(6:8,stimOrder==i),2),1);
    end
    
    figure
    plot(resp(sess,:))
    
    
end

resp = resp(1:4,:)

sfResp(:,1) = resp(:,25);
for sf=1:3;
    sfResp(:,sf+1) = mean(resp(:,sf:6:24),2);
end

sfResp


figure
plot(mean(resp,1))

mnresp = mean(resp,1)

sfMean = mean(sfResp,1);
sfStd = std(sfResp,[],1)/sqrt(size(sfResp,1));
figure
errorbar(sfMean-min(sfMean),sfStd)
xlabel('SF (cyc/deg)');
ylabel('dF/F');
set(gca,'Xtick',1:4);
set(gca,'XtickLabel',{'0','0.01','0.04','0.16'})
ylim([-0.01 0.14])
xlim([0.75 4.25])

