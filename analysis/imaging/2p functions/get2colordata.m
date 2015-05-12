function [dfofInterp im_dt red green] = get2colordata(fname,dt,cycLength);
[imgAll framerate] = readAlign2color(fname,1,1,0.5);


red = squeeze(mean(imgAll(:,:,:,2),3));
green = squeeze(prctile(imgAll(:,:,:,1),95,3));
for i = 1:2
 i
 img = squeeze(imgAll(:,:,:,i));
nframes = size(img,3);  
display('doing prctile')
tic
m{i} = prctile(img(:,:,40:40:end),10,3);
toc
figure
imagesc(m{i});
title('10th prctile')
colormap(gray)

dfof=zeros(size(img));
if i==1
    for f = 1:nframes
    dfof(:,:,f)=(img(:,:,f)-m{i})./m{i};
    end
else
    dfof = img;
end



im_dt = 1/framerate;
dt = 0.25;
if i == 1
    dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
dfofInterp = shiftdim(dfofInterp,1);
end
imgInterpAll{i} = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(img,2),0:dt:(nframes-1)*im_dt);
imgInterpAll{i} = shiftdim(imgInterpAll{i},1);
end
imgInterp(:,:,:,1) = imgInterpAll{1};
imgInterp(:,:,:,2) = imgInterpAll{2};

cycFrames =cycLength/dt;
map=0; clear cycAvg mov


range = [prctile(m{1}(:),2) 2*prctile(m{1}(:),99)];
redframes = squeeze(imgInterp(:,:,:,2));
rangered = [ 0 prctile(m{2}(:),99)];
clear mov;

figure
for f = 1:cycFrames;
    cycAvg(:,:,f,:) = mean(imgInterp(:,:,f:cycFrames:end,:),3);
    im(:,:,1) = squeeze(cycAvg(:,:,f,2))/rangered(2);
    im(:,:,2) = (squeeze(cycAvg(:,:,f,1)) - range(1))/(range(2)-range(1));
   im(:,:,3) = 0;
   imshow(im);
    mov(:,:,:,f)=im;
end
mov = immovie(mov)
title('raw img frames')
vid = VideoWriter(sprintf('%sCycleMov.avi',fname(1:end-4)));
vid.FrameRate=10;
open(vid);
writeVideo(vid,mov);
close(vid)

% fullMov = zeros(size(imgInterp));
% fullMov(:,:,:,3)=0;
% 
%     fullMov(:,:,:,1) = imgInterp(:,:,:,2)/rangered(2);
%     fullMov(:,:,:,2) = (imgInterp(:,:,:,1)-range(1))/(range(2) - range(1)) ;
% 
% 
% 
% % fullMov= mat2im(imresize(img(25:end-25,25:end-25,150:550),2),gray,[prctile(m(:),2) 1.5*prctile(m(:),99)]);
% % %fullMov = squeeze(fullMov(:,:,:,1));
%  mov = immovie(permute(fullMov,[1 2 4 3]));
% %mov = immovie(fullMov);
% vid = VideoWriter(sprintf('%sfullMov.avi',fname(1:end-4)));
% vid.FrameRate=10;
% 
% vid.Quality=100;
% open(vid);
% writeVideo(vid,mov(50:250));
% close(vid)

% cycTimecourse = squeeze(mean(mean(cycAvg,2),1));
% figure
% plot(cycTimecourse);