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
      % map = map+imframe*exp(2*pi*sqrt(-1)*f/perFrames);
       cycmap(:,:,mod(f,perFrames)+1)=cycmap(:,:,mod(f,perFrames)+1)+imframe;
       
end


xymin = prctile(cycmap,2,3);
for f = 1:perFrames;
    cycmap(:,:,f) = cycmap(:,:,f)-xymin;
end
repcycmap = repmat(cycmap,[1 1 3]);
repcycmap(isnan(repcycmap))=0;
dcycmap = squeeze(deconvg6s(shiftdim(repcycmap,2),0.1));
dcycmap = dcycmap(perFrames+1:2*perFrames,:,:)*perFrames/nframes;

for f=1:perFrames
    map = map+squeeze(dcycmap(f,:,:))*exp(2*pi*sqrt(-1)*f/perFrames);
end        
dcycmap = shiftdim(dcycmap,1);

map = map/perFrames;


