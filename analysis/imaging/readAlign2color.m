function [img, framerate] = readAlign2color(fname, align,showImg,fwidth)

inf = imfinfo(fname)

img = imread(fname,1);

nframes = length(inf);
%nframes = 300;
mag = 1;
img = zeros(mag*size(img,1),mag*size(img,2),nframes/2,2);

eval(inf(1).ImageDescription);
framerate = state.acq.frameRate;

if align
    display('doing alignement')
    tic
    r = sbxalign(fname,2:2:nframes);
    toc
    figure
    
    plot(r.T(:,1));
    hold on
    plot(r.T(:,2),'g');
    figure
    imagesc(r.m{1}); colormap gray; axis equal
end


filt = fspecial('gaussian',5,fwidth)
tic
for f=1:nframes/2
    img(:,:,f,1) = imfilter(double(imread(fname,(f-1)*2+1)),filt);
     img(:,:,f,2) = imfilter(double(imread(fname,(f-1)*2+2)),filt);
end
toc
sprintf('read frame by frame')
tic
imjunk = imread(fname);
toc
sprintf('read all frames')

mn=squeeze(mean(img,3));
%mn= prctile(img,99,3);
if showImg
    figure
   for i = 1:2
       range = [prctile(mn(:),2) prctile(mn(:),98)];
    imagesc(squeeze(mn(:,:,i)),range);
    title('non aligned mean img')
    colormap(gray)
   end
end

if align
    for f=1:nframes/2
       for i = 1:2
           img(:,:,f,i) = circshift(squeeze(img(:,:,f,i)),[r.T(f,1),r.T(f,2)]);
       end
    end
    
    
    if showImg
        
        %mn= prctile(img,99,3);
        figure
       for i = 1:2
        mn=squeeze(mean(img(:,:,:,i),3));
        subplot(1,2,i)
         range = [prctile(mn(:),2) prctile(mn(:),98)];
        imagesc(mn,range);
        title('aligned mean img')
        colormap(gray)
        axis equal
        im(:,:,3-i) = (mn-range(1))/(range(2)-range(1));
       end
       im(:,:,3)=0;
       figure
       imshow(im)
    end
end