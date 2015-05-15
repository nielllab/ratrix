function [img, framerate] = readAlign2p(fname, align,showImg,fwidth)

inf = imfinfo(fname)

img = imread(fname,1);

nframes = length(inf);
%nframes = 300;
mag = 1;
img = zeros(mag*size(img,1),mag*size(img,2),nframes);

eval(inf(1).ImageDescription);
framerate = state.acq.frameRate

if align
    display('doing alignement')
    tic
    r = sbxalign(fname,1:nframes);
    toc
    figure
    
    plot(r.T(:,1));
    hold on
    plot(r.T(:,2),'g');
    figure
    imagesc(r.m{1}); colormap gray; axis equal
end


filt = fspecial('gaussian',5,fwidth)
for f=1:nframes
    img(:,:,f) = imfilter(double(imread(fname,f)),filt);
end

mn=mean(img,3);
%mn= prctile(img,99,3);
if showImg
    figure
    range = [prctile(mn(:),2) prctile(mn(:),98)];
    imagesc(mn,range);
    title('non aligned mean img')
    colormap(gray)
end

if align
    for f=1:nframes
        img(:,:,f) = circshift(squeeze(img(:,:,f)),[r.T(f,1),r.T(f,2)]);
    end
    
    
    if showImg
        mn=mean(img,3);
        %mn= prctile(img,99,3);
        figure
        range = [prctile(mn(:),2) prctile(mn(:),98)];
        imagesc(mn,range);
        title('aligned mean img')
        colormap(gray)
    end
end