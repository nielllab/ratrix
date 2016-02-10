function [map dcycmap full_im]= deconPhaseMap(im,framerate,period,binning);
if ~exist('binning','var') | isempty(binning)
    binning=1;
end
perFrames = round(period*framerate);
map =0;

%im = im(:,:,perFrames+1:end);
im(:,:,1:perFrames)=[];

length(im);
nframes = floor(length(im)/perFrames)*perFrames;
cycmap = zeros(ceil(size(im,1)*binning),ceil(size(im,2)*binning),perFrames);
if binning~=1
    full_im = zeros(ceil(size(im,1)*binning),ceil(size(im,2)*binning),size(im,3));
else
    full_im=im;
end


for f = 1:nframes
   if binning~=1;
       imframe = imresize(im(:,:,f),binning,'box');
   full_im(:,:,f) = imframe;
   else
       imframe = im(:,:,f);
   end
       
end


xymin = prctile(im,2,3);
for f = 1:nframes;
    im(:,:,f) = im(:,:,f)-xymin;
end
im(isnan(im))=0;
tic
dcyc = squeeze(deconvg6s(shiftdim(im,2),0.1));
toc
%dcycmap = dcycmap(perFrames+1:2*perFrames,:,:)*perFrames/nframes;

for f= 1:perFrames
    dcycmap(f,:,:) = mean(dcyc(f:perFrames:end,:,:),1);
end


for f=1:perFrames
    map = map+squeeze(dcycmap(f,:,:))*exp(2*pi*sqrt(-1)*f/perFrames);
end        
dcycmap = shiftdim(dcycmap,1);

map = map/perFrames;


