

for i = 1:2
    [f p] = uigetfile('*.mat',sprintf('maps file %d',i));
    load(fullfile(p,f),'map');
    maps{i} = map{3};
end

figure
for i = 1:2
    subplot(2,2,i);
    imagesc(abs(maps{i}),[0 0.04]); colormap jet; axis equal
end
subplot(2,2,3);
imagesc(abs(maps{2}) - abs(maps{1}),[-0.02 0.02]); axis equal; colormap jet

subplot(2,2,4);
imshow(polarMap(maps{1},95))