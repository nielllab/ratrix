clear all
close all

filetype = {'control map','DOI map'};
for doi = 1:2
    [f,p] = uigetfile('*.mat',filetype{doi});
    load(fullfile(p,f),'cycle_mov');
    mov{doi} = cycle_mov;
end
dual_mov = zeros(size(cycle_mov,1),size(cycle_mov,2),3,size(cycle_mov,3));
dual_mov(:,:,1,:) = mov{1};
dual_mov(:,:,2,:) = mov{2};

lower = prctile(dual_mov(:),1);
upper = prctile(dual_mov(:),99.5);

dual_mov = 0.8*(dual_mov - lower) / (upper-lower);

diff_mov = mov{2}-mov{1};
lower = prctile(diff_mov(:),1);
upper = prctile(diff_mov(:),99);

figure
for t=1:size(mov{1},3);
    subplot(1,2,1);
    imshow(dual_mov(:,:,:,t));
    subplot(1,2,2);
    imagesc(diff_mov(:,:,t),[lower upper]);
    colormap(gray); axis equal
    changeMovie(t)= getframe(gcf);
end

[f p ] = uiputfile('*.avi','movie file');

vid = VideoWriter(fullfile(p,f));
vid.FrameRate=25;
open(vid);
writeVideo(vid,changeMovie);
close(vid)

imfig=figure;

imshow(dual_mov(:,:,:,30));
for i = 1:100
figure(imfig)
[y x] = ginput(1);
figure
plot(squeeze(mean(mean(mov{1}(x-5:x+5,y-5:y+5,:),2),1)),'r');
hold on
plot(squeeze(mean(mean(mov{2}(x-5:x+5,y-5:y+5,:),2),1)),'g');
end
