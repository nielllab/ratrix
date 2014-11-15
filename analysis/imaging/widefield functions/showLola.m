figure
subplot(2,2,1)
imagesc(movemap,[0.023 0.03])
axis equal
subplot(2,2,2)
imagesc(abs(aud),[0 0.015]);
axis equal
subplot(2,2,3);
imagesc(abs(vis_step),[0 0.05]);
axis equal
colormap gray


composite=zeros(size(vis_topo,1),size(vis_topo,2),3);
map = mat2im(movemap,gray,[0.032 0.055]);
composite(:,:,1) = map(:,:,1);
map = mat2im(abs(aud),gray,[0.0 0.015]);
composite(:,:,2) = map(:,:,1);
map = mat2im(abs(vis_step),gray,[0.0 0.04]);
composite(:,:,3) = map(:,:,1);
composite(:,:,2) =composite(:,:,2)+0.2*map(:,:,1);
composite(:,:,1) =composite(:,:,1)+0.2*map(:,:,1);


subplot(2,2,4)
imshow(composite)