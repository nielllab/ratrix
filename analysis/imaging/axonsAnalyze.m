close all
dfofInterp(dfofInterp>5)=5;

clear cycAvg
for i= 1:cycLength;
    cycAvg(:,:,i) = mean(dfofInterp(:,:,i:cycLength:end),3);
end

map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
amp = abs(map);
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(angle(map),hsv,[-pi pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
imshow(img)

[x y] = getAxonPts(dfofInterp,greenframe);

 dfofcol = reshape(dfofInterp,size(dfofInterp,1)*size(dfofInterp,2),size(dfofInterp,3));
 dfAll = dfofcol(pts,:);
 figure
 plot(dfAll')

clear dfAll red phaseColor

range = -1:1;
for i = 1:length(x);
    dfAll(i,:) = squeeze(mean(mean(dfofInterp(x(i)+range,y(i)+range,:),2),1));
    dfAll(i,:) = dfAll(i,:)-mean(dfAll(i,:));
    red(i) = redframe(x(i),y(i));
    phaseColor(i,:) = squeeze(img(x(i),y(i),:));
end
figure
plot(dfAll')


clear dfAvg
for i = 1:cycLength
    dfAvg(:,i) = mean(dfAll(:,i:cycLength:end),2);
end

figure
plot(circshift(dfAvg',20));
figure
plot(mean(dfAvg,1))

figure
for i = 1:10:size(dfAvg,1)
    hold on
    plot(circshift(dfAvg(i,:)',20));
end


figure
for i = 1:10:size(dfAll,1)
    hold on
    plot(circshift(dfAll(i,:)',20),'Color',[min(1,red(i)/3000) max(0,1-red(i)/3000) 0]);
end


dfRaw=dfAll
%dfAll = celldf;
for i  =1:size(dfAll,1)
   dfAll(i,:) = dfAll(i,:)/std(dfAll(i,:));
end

[icasig A W]= fastica(dfAll,'NumofIC',3,'LastEig',3,'stabilization','on','approach','symm');
figure
plot(icasig')
col = 'bgr';
for i = 1:size(icasig,1)
    figure
plot(icasig(i,:),col(i))
end

score = icasig';
figure
plot(score(:,1),score(:,2)); hold on; plot(score(:,1),score(:,2),'.','Color',[0.75 0  0]); 
figure
plot(score(:,1),score(:,3)); hold on; plot(score(:,1),score(:,3),'.','Color',[0.75 0  0]); 
figure
plot(score(:,2),score(:,3)); hold on; plot(score(:,2),score(:,3),'.','Color',[0.75 0  0]);
figure
plot3(score(:,1),score(:,2),score(:,3))

[coeff score latent] = pca(dfAll');
%[coeff score latent] = pcacov(corrcoef(dfAll'));
figure
plot(latent(1:10))
col = 'bgr';
for i = 1:3
    figure
plot(score(:,i),col(i))
end
figure
imagesc(coeff,[-1 1])
figure
plot(score(1:1200,1:3))


figure
plot(score(:,1),score(:,2)); hold on; plot(score(:,1),score(:,2),'.','Color',[0.75 0  0]); 
figure
plot(score(:,1),score(:,3)); hold on; plot(score(:,1),score(:,3),'.','Color',[0.75 0  0]); 
figure
plot(score(:,2),score(:,3)); hold on; plot(score(:,2),score(:,3),'.','Color',[0.75 0  0]); 
figure
plot3(score(:,1),score(:,2),score(:,3))

figure
plot(coeff(:,1),coeff(:,2),'o')

figure
imagesc(corrcoef(dfAll'),[-1 1])
dist = 1-corrcoef(dfAll');
imagesc(dist)
[Y e] = mdscale(dist,3,'Start','random');
figure
imagesc(Y)
figure
plot(e)
figure
for i = 1:size(coeff,1)
    hold on
    plot(Y(i,1),Y(i,2),'o','Color',phaseColor(i,:))
end
title('mds coeff')

figure
for i = 1:size(coeff,1)
    hold on
    plot(Y(i,1),Y(i,2),'o','Color',[min(1,red(i)/3000) max(0,1-red(i)/3000) 0])
end
title('mds coeff')

figure
for i = 1:size(coeff,1)
    hold on
    plot3(Y(i,1),Y(i,2),Y(i,3),'o','Color',phaseColor(i,:))
end
title('mds coeff')

figure
for i = 1:size(coeff,1)
    hold on
    plot(coeff(i,1),coeff(i,2),'o','Color',[min(1,red(i)/3000) max(0,1-red(i)/3000) 0])
end
title('pca coeff')

figure
for i = 1:size(coeff,1)
    hold on
    plot(coeff(i,1),coeff(i,2),'o','Color',phaseColor(i,:))
end
title('pca coeff')

figure
for i = 1:size(coeff,1)
    hold on
    plot(coeff(i,1),coeff(i,3),'o','Color',phaseColor(i,:))
end
title('pca coeff')



figure
for i = 1:size(coeff,1)
    hold on
    plot3(coeff(i,1),coeff(i,2),coeff(i,3),'o','Color',phaseColor(i,:))
end
title('pca coeff 3')



figure
plot3(coeff(:,1),coeff(:,2))

figure
imshow(redframe/5000)

clear img
img(:,:,1) = redframe/2000;
img(:,:,2) = amp;
img(:,:,3)=0;
figure
imshow(img)
figure
r = redframe/2000; r(r>1)=1;
plot(r(:),amp(:),'.')
figure
h = hist3([r(:) amp(:)]);
imagesc(h)