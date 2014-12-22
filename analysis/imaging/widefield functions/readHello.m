tcourse = squeeze(mean(mean(cycle_mov,2),1));
figure
plot(tcourse);
resptime = 8:12; basetime =5:7;
figure
for i = 1:5
    im = mean(cycle_mov(:,:,(i-1)*20 + resptime),3) - mean(cycle_mov(:,:,(i-1)*20 + basetime),3);
    
    subplot(2,3,i)
    imagesc(fliplr(im)'); colormap(gray); axis equal
end
figure
imagesc(im)
[y x] = ginput(1);
figure
plot(squeeze(cycle_mov(round(x),round(y),:)))


figure
for i = 1:5
subplot(2,3,i)
imagesc(flipud(squeeze(moviedata(:,:,i*120 - 90))')); colormap gray; axis equal
end


for i = 1:150
    moviedata(:,:,(i-1)*120 +(21:120))=128;
end

