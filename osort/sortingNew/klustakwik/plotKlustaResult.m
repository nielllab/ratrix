function plotKlustaResult(allSpikes,allTimestamps, clu,nrClusters)

meanWaveforms=[];
meanCounter=0;

plotNr=0;
for i=0:nrClusters
        %waveforms
        
        %dont plot small clusters
        if length(find(clu==i)) < 500
            continue;
        end
        
        plotNr=plotNr+1;
        subplot(7,7,plotNr);
        
        plot(1:256, allSpikes( find(clu==i),:),'b');
        title(['n=' num2str(length(find(clu==i)))]);
        hold on
        meanCounter=meanCounter+1;
        meanWaveforms(meanCounter,1:256)=mean(allSpikes( find(clu==i),:));
        plot(1:256, meanWaveforms(meanCounter,1:256),'r','linewidth',2.0);
        
        hold off
        xlim([1 256]);
        ylim([-2500 2500]);
        
        %histogram
        plotNr=plotNr+1;
        subplot(7,7,plotNr);
        timestamps = allTimestamps(find(clu==i));
        d = diff(timestamps);
        d = d/1000; %in ms
        edges1=0:3:50;
        n1=histc(d,edges1);
        bar(edges1,n1,'histc');
        xlim([0 50]);
        
        below = length( find(d <= 3.0) );
        percentageBelow = (below*100) / length(find(d<=70));	
        m1=0;
        if length(find(d<=70))>1
            m1=mean(d(find(d<=70)));
        end
        
        title(['% bel.=' num2str(percentageBelow,3) ' m=' num2str(m1,3) ]);
        
        if i==49
            break
        end
end

    
subplot(7,7,49)
plot(1:256, meanWaveforms);
    