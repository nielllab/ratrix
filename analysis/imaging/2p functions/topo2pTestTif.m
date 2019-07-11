function [outmap] = topo2pTestTif(fileName,acqrate,first_frame,last_frame)
% this script runs a quick test for topox or topoy to get cycavg and
% fourier map for data in tif format

spatialBin = 1; %spatial downsample factor (map will look cleaner)

tiff_info = imfinfo(fileName); % return tiff structure, one element per image
data = imread(fileName, first_frame) ; % read in first image
%concatenate each successive tiff to tiff_stack
disp('reading tif file, please wait...')
tic
for ii = first_frame+1:last_frame
    temp_tiff = imread(fileName, ii);
    data = cat(3 , data, temp_tiff);
end
toc
disp('finished reading tif file')

nframes = min(size(data,3),3000);  %%% limit topo data to 5mins to avoid movie boundaries
data = data(:,:,1:nframes);

%%% spatial downsampling
disp('resizing')
tic
data = imresize(data,1/spatialBin,'box');
toc
disp('finished resizing')

%%% get the median image to calculate dfof
medimg = double(median(data(:,:,10:10:end),3)); % was 10th percentile, changed to median to avoid zeros
figure;imagesc(medimg)
axis off
axis image
title('median image')

%%% calculate dfof
disp('doing dfof')
tic
dfof=zeros(size(data));
for f = 1:size(data,3)
    dfof(:,:,f)=(double(data(:,:,f))-medimg)./medimg;
end
toc
disp('finished dfof')

%%% generate pixel-wise fourier map
dt = 1/acqrate; %%% resampled time frame
cycLength=10; %length of movie cycle in seconds (should be 10)
cycLength = cycLength/dt; %length of movie cycle in frames
map = 0;
for i= 1:size(dfof,3);
    map = map+dfof(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfof,3); map(isnan(map))=0;
outmap = map;
amp = abs(map); amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg = figure;
imshow(img)
colormap(hsv); colorbar
title('fourier map')

clear cycAvg mov
figure
cycAvg = zeros(size(dfof,1),size(dfof,2),cycLength);
for i = 1:cycLength
    cycAvg(:,:,i) = squeeze(mean(dfof(:,:,i:cycLength:end),3));
end
cycAvgT = squeeze(mean(mean(cycAvg,2),1));
figure
plot(cycAvgT); title('cycle average across all pixels')
    

