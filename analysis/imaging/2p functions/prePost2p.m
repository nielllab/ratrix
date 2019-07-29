function prePost2p(fnames, psfile)
%%% generic code to compare responses to two periodic stimuli
%%% works on pixelwise data (after running topo2pSession)
%%% also works on selected points (from getCellsPeaks, or other?)
%%%
%%% input
%%% fnames{2} = name of two analysis .mat files
%%% psfile = postscript file to write figures to
%%% 

%%% load in data
for i = 1:2
    load(fnames{i},'meanImg','tcourse','cycAvgT','polarImg','dF','cycLength','dt');
    meanImgAll{i} = meanImg;
    tcourseAll{i} = tcourse;
    cycAvgAll{i} = cycAvgT;
    polarMapAll{i} = polarImg;
   if exist('dF','var') 
       dFall{i} = dF;
   end
end

cycLength = cycLength/dt; %%% convert to frames rather than secs

%%% plot mean images and polar maps
figure
for i = 1:2
    subplot(2,2,i)
    if i ==1  %%% set clim based on first image. keep fixed for second for comparison
        upper = 1.2*prctile(meanImgAll{1}(:),95);
    end
    imagesc(meanImgAll{i},[0 upper]); axis equal; title(fnames{i}); colormap gray;
    subplot(2,2,i+2)
    imshow(polarMapAll{i});
end

if exist('psfile','var'), set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot mean timecourse  and cycle average for the whole image
tcFig = figure;
subplot(2,2,1)
hold on
for i = 1:2
    plot(tcourseAll{i} - min(tcourseAll{i}))
    ylim([0 2]); ylabel('dF/F')
    title('mean timecourse'); xlim([0 3000]); xlabel('frame')
end
legend('pre','post')

%%% plot mean cycle average for whole image
subplot(2,2,2)
hold on
for i = 1:2
    plot(squeeze(cycAvgAll{i}) - min(cycAvgAll{i}))
    ylim([0 0.25]); ylabel('dF/F');  xlabel('frame')
    title('mean cycAvg')
end


%%% calculations based on extracted cells
if exist('dFall','var')   %%% only if there was extracted cell data
    
    %%% heatmap of all activity pre/post
    figure
    for i = 1:2
        subplot(2,2,i);
        
        %%% multidimensional scaling to order neurons for display
        display('doing mds');
        dist = pdist(dFall{i},'correlation');
        tic; [Y e] = mdscale(dist,1); toc
        [y sortind] = sort(Y);
      
        imagesc(dFall{i}(sortind,:),[-1 1]);
        title('activity across cells')
    end
    
    %%% calculate cycle average and show heatmaps pre/post
    for i= 1:2
        for j = 1:cycLength;
            cycAvgPts{i}(:,j)= mean(dFall{i}(:,j:cycLength:end),2);
        end
        for j = 1:size(cycAvgPts{i},1);  %%% baseline so min = 0
            cycAvgPts{i}(j,:) = cycAvgPts{i}(j,:) - min(cycAvgPts{i}(j,:));
        end
        %%% multidimensional scaling to order neurons for display
        display('doing mds');
        dist = pdist(cycAvgPts{i},'correlation');
        tic; [Y e] = mdscale(dist,1); toc
        [y sortind] = sort(Y);
        
        subplot(2,2,i+2);
        imagesc(cycAvgPts{i}(sortind,:),[0 0.25])
        title('cyc avg across cells')
    end    
    if exist('psfile','var'), set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    figure(tcFig);  %%% bring back timecourse figure from before
    
    %%% mean timecourse of all points
    subplot(2,2,3);
    hold on
    for i = 1:2
        mn = mean(dFall{i},1);
        plot(mn- min(mn)); ylim([0 2]);
    end
    title('mean timecourse across points');
    xlabel('frame'); ylabel('dF/F')
    
    %%% mean cycle average of all points
    subplot(2,2,4);
    hold on
    for i = 1:2
        mn = mean(cycAvgPts{i},1);
        plot(mn- min(mn)); ylim([0 0.2]);
    end
    title('mean cyc avg across points');
    xlabel('frame'); ylabel('dF/F')
    
    if exist('psfile','var'), set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

end

