clear all
close all

filetype = {'control map','DOI map'};
for doi = 1:2
    [f,p] = uigetfile('*.mat',filetype{doi});
    load(fullfile(p,f),'cycle_mov');
    mov{doi} = cycle_mov;
end

if any(size(mov{1})~=size(mov{2}))
    for f = 1:size(mov{1},3)
        mov_resize(:,:,f) = imresize(mov{2}(:,:,f),[size(mov{1},1) size(mov{1},2)]);
    end
    mov{2}=mov_resize;
end


for doi=1:2;
    [peakmax{doi} peaktime{doi}] = max(mov{doi},[],3);
end
figure
imagesc(peaktime{2}-peaktime{1},[-5 5]);
title('latency difference')
figure
imagesc(peakmax{2}-peakmax{1},[-0.05 0.05]);
title('amplitude difference');




dual_mov = zeros(size(mov{1},1),size(mov{1},2),3,size(cycle_mov,3));

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

basename = fullfile(p,f);
basename = basename(1:end-4);
psfilename = [basename '.ps']
if exist(psfilename,'file')==2;delete(psfilename);end

imfig=figure;imshow(dual_mov(:,:,:,30));

[f p ] = uigetfile('*.mat','map points');
hold on


        
if f~=0
    load(fullfile(p,f));
    scale = size(mov{1},1)/sz(1);
    pts=round(pts*scale);
    for n=1:size(pts,1);
        figure(imfig);
        plot(pts(n,2),pts(n,1),'*');
        text(pts(n,2)+5,pts(n,1)-5,sprintf('%d',n));
    end
    set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

    for n=1:size(pts,1);

        range = -5:5;
        figure
        plot(squeeze(mean(mean(mov{1}(pts(n,1)+range,pts(n,2)+range,:),2),1)),'g');
        hold on
        plot(squeeze(mean(mean(mov{2}(pts(n,1)+range,pts(n,2)+range,:),2),1)),'r');
        legend{'control','doi'}
        title(sprintf('point %d',n));
        set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
    end
    ps2pdf('psfile', psfilename, 'pdffile', [psfilename(1:(end-2)) 'pdf']);
delete(psfilename);
else %%% no map file

for i = 1:100
figure(imfig)
[y x] = ginput(1);
figure
plot(squeeze(mean(mean(mov{1}(x-5:x+5,y-5:y+5,:),2),1)),'g');
hold on
plot(squeeze(mean(mean(mov{2}(x-5:x+5,y-5:y+5,:),2),1)),'r');
 legend{'control','doi'}
end
end
