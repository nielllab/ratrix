function sbx2dfofNoStim(fname,svname,cfg);
%%% reads in 2p data and syncs with stimulus signals

load([fname(1:end-4) '.mat'])

%%% read in sbx data and perform motion correction (if not already done)
display('reading data')
tic
alignData=cfg.alignData; showImages=1;

img = zeros(info.sz(1),info.sz(2),info.max_idx,'uint16');
for i = 1:10000;
    im = sbxread(fname,i-1,1);
    if alignData
        img(:,:,i)  = circshift(squeeze(im(1,:,:)),info.aligned.T(i,:));
    else
        img(:,:,i)=im;
    end
end

m = mean(img,3);
upper = prctile(m(:),95)*1.2;
lower = min(m(:));
if showImg
    figure
    imagesc(m,[lower upper]); colormap gray; title('readAlign mean'); axis equal
    drawnow
end

greenframe = prctile(img(:,:,25:25:end),10,3);  %%% keep mean raw fluorescence image


%%% spatial downsampling
display('resizing')
tic
img = imresize(img,1/cfg.spatialBin,'box');
toc

size(img)
%%% temporal binning, to improve SNR before interpolation
%%% a gaussian temporal filter might be better, but slow!
display('temporal downsampling')
binsize=cfg.temporalBin;
if binsize~=1
    downsampleLength = binsize*floor(size(img,3)/binsize);
    tic
    img= downsamplebin(img(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code
    toc
else
    display('binsize ==1')
end


display('computing baseline')
tic
m = prctile(double(img(:,:,10:10:end)),10,3);
toc
%%% Yeti seems to have a large DC offset, even in blanks on edge of image
%%% Estimate this as minimum of mean image and subtract it off
dcOffset = 0.95*min(m(:));
m = m-dcOffset;
img = img-dcOffset;
greenframe=greenframe-dcOffset;

if (exist('S2P','var')&S2P==1)
    dfof = double(img);
else
    display('doing dfof')
    tic
    dfof=zeros(size(img));
    for f = 1:size(img,3)
        dfof(:,:,f)=(double(img(:,:,f))-m)./m;
    end
    toc
end

display('saving dfof...')
save(svname,'dfof')