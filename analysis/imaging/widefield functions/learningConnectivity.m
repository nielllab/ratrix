%%% run this after doCorrelationMap

pre =1; gts=2; hvv=3;

for f = 1:length(use)

    if strcmp(files(use(f)).task,'naive') |strcmp(files(use(f)).task,'Naive')
        task(f) = pre;
    elseif strcmp(files(use(f)).task,'GTS')
        task(f) = gts;
    elseif strcmp(files(use(f)).task,'HvV')
        task(f) = hvv;
    else
        task(f)=0;
    end
end

clear subjCorr
nsub =0;
for t = 1:3
   sess = find(task==t);
   subjs = unique({files(use(sess)).subj});
  
   for s = 1:length(subjs);
       subsess = strcmp({files(use).subj}, subjs{s}) & task==t;
       subjCorr(:,:,nsub+s) = mean(traceCorrAll(:,:,subsess),3);
       subjtask(nsub+s) = t;
   end
    nsub = nsub+length(subjs);
end




prePostMean(:,:,1) = nanmean(subjCorr(:,:,subjtask==pre),3); prePostMean(:,:,2) = nanmean(subjCorr(:,:,(subjtask==gts | subjtask == hvv)),3);
prePostErr(:,:,1) = nanstd(subjCorr(:,:,subjtask==pre),[],3)/sqrt(sum(subjtask==pre)); prePostErr(:,:,2) = nanstd(subjCorr(:,:,(subjtask==gts | subjtask == hvv)),[],3) / sqrt(sum(subjtask==gts | subjtask == hvv));

figure
imagesc(prePostMean(:,:,1));
figure
imagesc(prePostMean(:,:,2));

figure
imagesc(prePostErr(:,:,1));
figure
imagesc(prePostErr(:,:,2));


deltaErr = sqrt(prePostErr(:,:,1).^2 + prePostErr(:,:,2).^2);
deltaCorr = prePostMean(:,:,2)- prePostMean(:,:,1);

figure
imagesc(deltaCorr,[-0.3 0.3]); colormap jet
zCorr = deltaCorr./deltaErr; zCorr(isnan(zCorr))=0;
figure
imagesc(zCorr,[-4 4]); colormap jet

figure
imagesc(im(:,:,1),[-0.2 0.2]) ; colormap gray; axis equal
hold on
for i = 1:npts-1
    plot(y(i),x(i),[col(i) 'o'],'Markersize',8,'Linewidth',2)
    for j= 1:npts-1
        d = prePostMean(i,j,2)- prePostMean(i,j,1);
        z = zCorr(i,j);
        if z>1
            plot([y(i) y(j)],[x(i) x(j)],'r','Linewidth',round(10*d)+0.5)
        end
        if z<-1.5
            plot([y(i) y(j)],[x(i) x(j)],'B','Linewidth',round(-5*d)+0.5)
        end
    end
end
plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
axis ij
axis square; axis([10 50 10 50])