batch2pBehaviorSBX;


alluse = find(strcmp({files.task},'GTS') & strcmp({files.notes},'good imaging session'))


rfAmpAll =[]; rfAll = []; trialDataAll=[];
for i = 1:length(alluse);
    i
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).compileData],'rfAmp','rf','behavTrialData');
    cutoff = size(behavTrialData,1);
    rfAmpAll = [rfAmpAll; rfAmp(1:cutoff,:)];
    rfAll = [rfAll; rf(1:cutoff,:)];
    trialDataAll = [trialDataAll; behavTrialData];
    
end


goodtopo = rfAmpAll(:,1)>0.025 & rfAmpAll(:,2)>0.025;
figure
plot(rfAll(goodtopo,2),rfAll(goodtopo,1),'.'); axis equal;  axis([0 72 0 128]);

d1 = sqrt((rfAll(:,1)-64).^2 + (rfAll(:,2)-36).^2);
d2 = sqrt((mod(rfAll(:,1)+64,128)-64).^2 + (mod(rfAll(:,2)+36,72)-36).^2);
sbc = d2<d1;

figure
plot(rfAll(goodtopo & ~sbc,2),rfAll(goodtopo& ~sbc,1),'.'); axis equal;  axis([0 72 0 128]);
hold on
plot(rfAll(goodtopo & sbc,2),rfAll(goodtopo& sbc,1),'r.'); axis equal;  axis([0 72 0 128]);

figure
plot(mean(mean(trialDataAll,3),1))

baseline = mean(mean(trialDataAll(:,1:10,:),3),2);
figure
hist(baseline)

top = mean(mean(trialDataAll(:,13:16,1:2),3),2)-baseline;
bottom = mean(mean(trialDataAll(:,13:16,3:4),3),2)-baseline;

figure
plot(top,bottom,'o'); axis equal; hold on ; plot([0 1],[0 1])

figure
plot(rfAll(goodtopo ,2),rfAll(goodtopo,1),'.'); axis equal;  axis([0 72 0 128]); hold on
plot(rfAll(goodtopo & top>0.25,2), rfAll(goodtopo&top>0.25,1),'g*');
plot(rfAll(goodtopo & top<-0.25,2), rfAll(goodtopo&top<-0.25,1),'r*');


figure
plot(rfAll(goodtopo ,2),rfAll(goodtopo,1),'.'); axis equal;  axis([0 72 0 128]); hold on
plot(rfAll(goodtopo & bottom>0.25,2), rfAll(goodtopo&bottom>0.25,1),'g*');
plot(rfAll(goodtopo & top<-0.25,2), rfAll(goodtopo&top<-0.25,1),'r*');


data = reshape(trialDataAll,size(trialDataAll,1),size(trialDataAll,2)*size(trialDataAll,3));
figure
imagesc(data,[0 0.5]); hold on; for i = 1:7; plot([i*61 i*61],[1 size(data,1)],'g'); end


