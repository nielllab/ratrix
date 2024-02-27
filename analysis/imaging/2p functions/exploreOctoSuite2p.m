%%% misc code to explore suite2p output
%%% cmn 01-2024

load('Fall.mat')

%plot some output images
figure
imagesc(ops.meanImg); colormap gray; axis equal
title('meanImg');

figure
imagesc(ops.refImg); colormap gray; axis equal
title('refImg')

figure
imagesc(ops.max_proj); colormap gray; axis equal
title('max proj')

%%%% select out cells
goodcells = find(iscell(:,1));
ncells = sum(iscell(:,1))

%%% compute image of masks
cols = [ 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
img = zeros(size(ops.max_proj,1),size(ops.max_proj,2),3);
for c = 1:ncells
    xpix = stat{goodcells(c)}.xpix;
    ypix = stat{goodcells(c)}.ypix;
    lam = stat{goodcells(c)}.lam; 
    xpts(c) = round(mean(xpix));
    ypts(c) = round(mean(ypix));
    

    for i = 1:length(xpix);
        img(ypix(i),xpix(i),:) = cols(mod(c,6)+1,:)*lam(i)/max(lam);
    end
end

%show max and masks side by side
figure
subplot(1,2,1);
imshow(1.5*ops.max_proj/max(ops.max_proj(:))); colormap gray; axis equal
subplot(1,2,2)
imshow(img)

%crop image
[x y] = ginput(2);

%show cropped
figure
subplot(1,2,1);
imshow(1.5*ops.max_proj/max(ops.max_proj(:))); colormap gray; axis equal
title('max proj');
xlim(x); ylim(y)
subplot(1,2,2)
imshow(img)
xlim(x); ylim(y)
title('masks')

figure
imshow(1.5*double(ops.refImg)/max(double(ops.refImg(:)))); colormap gray; axis equal
hold on
plot(xpts,ypts,'.');

%%% calculate dF/F
for c = 1:ncells
    dF(c,:) = (F(goodcells(c),:) - mean(F(goodcells(c),:)))/mean(F(goodcells(c,:)));
end


%%% plot dF/F traces for random subset
dF(dF>1)=1;
figure
hold on
range = 1:3000;
dt= 0.1;
np=32;
for i = 1:np;
    plot(range*dt,dF(ceil(rand*ncells),range)+i);
end
ylim([0 np+2])
xlabel('secs');
ylabel('cell #');
title('dF/F')






