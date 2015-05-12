for f= 1:length(use)
    load([pathname files(use(f)).spont],'dfof_bg','sp');

im= imresize(dfof_bg,0.5);
 filt = fspecial('gaussian',10,3);
 
 imsmooth= imfilter(im,filt);
 sig = std(im,[],3);
 figure
 imagesc(sig)
 sig = reshape(sig,size(im,1)*size(im,2),1);
 
 
 im = im-0.5*imsmooth;
obs = reshape(im,size(im,1)*size(im,2),size(im,3));
obs(sig<0.025,:)=0;

[coeff score latent] = pca(obs');
figure
plot(latent)

tcourse = coeff(:,1)*score(:,1)';
obs = obs-tcourse;
figure
for i = 1:12
    subplot(3,4,i);
imagesc(reshape(coeff(:,i),size(im,1),size(im,2)),[-0.1 0.1])
end

figure
cv=cov(obs');
imagesc(cv)
figure
cc = corrcoef(obs');
imagesc(cc)

cc_im = reshape(cc,size(im,1),size(im,2),size(im,1),size(im,2));
imfig=figure
imagesc(im(:,:,100))

for i = 1:10
    figure(imfig);
    [y x] = ginput(1); x= round(x); y=round(y);
    figure
    imagesc(squeeze(cc_im(x,y,:,:)))
end

cc(isnan(cc))=0;
% cc= cc-0.7;
% cc(cc<0)=0;
display('clustering')
cl = kmeans(cc,10)
cl_im = reshape(cl,size(im,1),size(im,2));

figure
imagesc(cl_im)

zoom = 260/size(cl_im,1)
cl_im=shiftImageRotate(cl_im,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);


figure
imagesc(cl_im);
hold on
plot(ypts,xpts,'w.','Markersize',8);


end

    
