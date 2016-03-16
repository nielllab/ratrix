close all
clear all
load('connJuv4sessGenericPts.mat','conn');
juvConn = conn;
load('connAdult4sessSelectPts.mat','conn');
adultConn = conn;

gridspace = 3;
scale = gridspace*10500/64

col = 'rgbc';
for i = 1:2
    if i==1
        conn=juvConn;
    else
        conn = adultConn;
    end
    allMeanC(:,i) = median(vertcat(conn.meanC)) ;
    allMeanCerr(:,i) = std(vertcat(conn.meanC))/sqrt(length(conn));
    
    figure
    hold on
    for j=1:length(conn);
        plot(conn(j).meanC,col(j)); hold on; plot(conn(j).meanC,[col(j) 'o']);
    end
    
    for j=1:length(conn);
        dist = conn(j).dist(:); contra= conn(j).contra(:); traceCorr = corrcoef(conn(j).decorrTrace);traceCorr=traceCorr(:); decorrTrace = conn(j).decorrTrace;
%         figure      
%         hold on
%         plot(dist(~contra),traceCorr(~contra),'o'); axis([0 50 -1 1])
        
        maxim = conn(j).maxim; x= conn(j).x; y= conn(j).y;
        contra=reshape(contra,sqrt(length(contra)),sqrt(length(contra))); dist = reshape(dist,sqrt(length(dist)),sqrt(length(dist)));
        traceCorr=reshape(traceCorr,sqrt(length(traceCorr)),sqrt(length(traceCorr)));
        
        clear str
        for pt = 1:size(contra,1);
            c = contra(pt,:); t = traceCorr(pt,:);
            str(pt) = prctile(t(c==1),95);
        end
        contraCorr(i,j) = mean(str);
        
        nclust = 7;
        tic
        idx = kmeans(decorrTrace',nclust,'distance','correlation');
        toc
    
         clustcol = 'wgrcmyk'; %%% color scheme for clusters
    figure
    imagesc(maxim) ; colormap gray; axis equal
    hold on

    npts = size(dist,1)
    for i = 1:npts
        for j= 1:npts

            if traceCorr(i,j)>0.66 && contra(i,j)
                plot([y(i) y(j)],[x(i) x(j)],'Linewidth',6*(traceCorr(i,j)-0.66),'Color','r')
            end
        end
    end
  
    for i = 1:npts
        plot(y(i),x(i),[clustcol(idx(i)) 'o'],'Markersize',8,'Linewidth',2)
        plot(y(i),x(i),[clustcol(idx(i)) '*'],'Markersize',8,'Linewidth',2)
    end
    axis ij; 
    axis equal ; axis off
    
    
    %%% plot clustered points with connectivity
    clustcol = 'wgrcmyk'; %%% color scheme for clusters
    figure
    imagesc(maxim) ; colormap gray; axis equal
    hold on
  
    for i = 1:npts
        for j= 1:npts
            
            if traceCorr(i,j)>0.5 && dist(i,j) > gridspace*2 &&~contra(i,j)
                plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.5),'Color','b')
            end
        end
    end  
    for i = 1:npts
        plot(y(i),x(i),[clustcol(idx(i)) 'o'],'Markersize',8,'Linewidth',2)
        plot(y(i),x(i),[clustcol(idx(i)) '*'],'Markersize',8,'Linewidth',2)
    end

    axis ij
    axis equal
    
        
        
        
    end
    
end

sprintf('contra strengths');
allMeanC(17,:) = mean(contraCorr,2);
allMeanCerr(17,:) = std(contraCorr,[],2)/sqrt(size(contraCorr,2));


figure
errorbar((1:15)*0.5,allMeanC(1:15,1),allMeanCerr(1:15,1),'b','Linewidth',2);
hold on
errorbar((1:15)*0.5,allMeanC(1:15,2),allMeanCerr(1:15,2),'r','Linewidth',2);
errorbar(17*0.5-0.1, allMeanC(17,1),allMeanCerr(17,1),'b','Linewidth',2);
errorbar(17*0.5+0.1, allMeanC(17,2),allMeanCerr(17,2),'r','Linewidth',2);
axis([0 9.5 -0.5 1])
axis square
legend('juvenile','adult')
ylabel('mean correlation'); xlabel('dist (mm)')
set(gca,'FontSize',16); set(gca,'LineWidth',0.5); set(gca,'LabelFontSizeMultiplier',1.25)

