
dfAll = dF;

sp = getStimrecSpeed(dt);
sp = sp(1:size(dF,2));

figure
plot(sp)

figure
plot(dfAll')


clear dfAvg
for i = 1:cycLength
    dfAvg(:,i) = mean(dfAll(:,i:cycLength:end),2);
end

figure
plot(circshift(dfAvg',0));
figure
plot(mean(dfAvg,1))

figure
for i = 1:10:size(dfAvg,1)
    hold on
    plot(circshift(dfAvg(i,:)',0));
end


dfRaw=dfAll;
%dfAll = celldf;
for i  =1:size(dfAll,1)
   dfAll(i,:) = dfAll(i,:)/std(dfAll(i,:));
end
dfAll(isnan(dfAll))=0;

[coeff score latent] = pca(dfAll');
%[coeff score latent] = pcacov(corrcoef(dfAll'));
figure
plot(latent(1:10))

[icasig A W]= fastica(dfAll,'NumofIC',3,'LastEig',3,'stabilization','on');

figure
plot(icasig(:,1:1200)')
col = 'bgrcmyk';
for i = 1:size(icasig,1)
if mean(icasig(i,:))<0
    icasig(i,:)=-icasig(i,:);
    A(:,i)=-A(:,i);
end
figure
plot(0.5+(icasig(i,:)-min(icasig(i,:)))/(max(icasig(i,:))-min(icasig(i,:))),col(i));
hold on

for j= 1:length(onsets)
    plot([onsets(j)/dt onsets(j)/dt],[0 1])
end

%plot((sp-min(sp))/(max(sp)-min(sp)),'k');
% figure
% plot(sp,icasig(i,:),'o')
end



figure
plot(A(:,1),A(:,2),'o')

for r = 1:size(icasig,1)
    figure
hold on
range = max(abs(min(A(:,r))),abs(max(A(:,r))));
for i = 1:size(A,1)
    plot(pts(i,2),pts(i,1),'o','Color',cmapVar(A(i,r),-range,range));
  
end
  colormap(jet); colorbar; set(gca,'Clim',[-range range]);
axis ij
end


figure
plot(A(:,1),A(:,2),'o')

figure
plot(A(:,1),A(:,3),'o')

figure
plot(A(:,2),A(:,3),'o')

score = icasig';
figure
plot(score(:,1),score(:,2)); hold on; plot(score(:,1),score(:,2),'.','Color',[0.75 0  0]); 
figure
plot(score(:,1),score(:,3)); hold on; plot(score(:,1),score(:,3),'.','Color',[0.75 0  0]); 
figure
plot(score(:,2),score(:,3)); hold on; plot(score(:,2),score(:,3),'.','Color',[0.75 0  0]);
figure
plot3(score(:,1),score(:,2),score(:,3))

figure
plot(score(:,1),score(:,2));mapColors(score(:,1),score(:,2),'.',jet(length(score))); title('1 v 2');
figure
plot(score(:,1),score(:,3));mapColors(score(:,1),score(:,3),'.',jet(length(score))); title('1 v 3');
figure
plot(score(:,2),score(:,3));mapColors(score(:,2),score(:,3),'.',jet(length(score))); title('2 v 3');


% 

% col = 'bgr';
% for i = 1:3
%     figure
% plot(score(:,i),col(i))
% end
% figure
% imagesc(coeff,[-1 1])
% figure
% plot(score(1:1200,1:3))
% 
% 
% figure
% plot(score(:,1),score(:,2)); hold on; plot(score(:,1),score(:,2),'.','Color',[0.75 0  0]); 
% figure
% plot(score(:,1),score(:,3)); hold on; plot(score(:,1),score(:,3),'.','Color',[0.75 0  0]); 
% figure
% plot(score(:,2),score(:,3)); hold on; plot(score(:,2),score(:,3),'.','Color',[0.75 0  0]); 
% figure
% plot3(score(:,1),score(:,2),score(:,3))
% 
% figure
% plot(coeff(:,1),coeff(:,2),'o')
% 
m = mean(dfAll,2);
df = dfAll(m~=0,:);
figure
imagesc(corrcoef(df'),[-1 1])
dist = 1-corrcoef(df');
imagesc(dist)

[Y e] = mdscale(dist,2,'Start','random');
figure
imagesc(Y)
figure
plot(e)
figure
for i = 1:size(Y,1)
    hold on
    plot(Y(i,1),Y(i,2),'o')
end
title('mds coeff')
% 
% 
% figure
% for i = 1:size(coeff,1)
%     hold on
%     plot(coeff(i,1),coeff(i,2),'o')
% end
% title('pca coeff')
% 
% figure
% for i = 1:size(coeff,1)
%     hold on
%     plot(coeff(i,1),coeff(i,2),'o','Color',phaseColor(i,:))
% end
% title('pca coeff')
% 
% figure
% for i = 1:size(coeff,1)
%     hold on
%     plot(coeff(i,1),coeff(i,3),'o')
% end
% title('pca coeff')
% 
% 
% 
% figure
% for i = 1:size(coeff,1)
%     hold on
%     plot3(coeff(i,1),coeff(i,2),coeff(i,3),'o')
% end
% title('pca coeff 3')
% 
