nfiles = input('how many files ? ')
clear f p

for i = 1:nfiles
 i
 [thisf, thisp] = uigetfile('*.tif');
    f{i} = thisf; p{i} = thisp;
    info = imfinfo(fullfile(p{i},f{i}),'tif');
    nframes(i) =length(info);
end

sz = size(imread(fullfile(p{1},f{1}),1));
im_all = zeros(sz(1),sz(2),sum(nframes),'uint16');
nf=0;
for i = 1:nfiles
   i
   for fr = 1:nframes(i)
       if fr/100 == round(fr/100)
           sprintf('%d %0.2f done',i, fr/nframes(i))
       end
        nf=nf+1;
        im_all(:,:,nf)= imread(fullfile(p{i},f{i}),fr);
    end
end

[f p] = uiputfile('*.tif');
imwrite(im_all(:,:,1),fullfile(p,f),'tiff');
for fr = 2:nf;
  if fr/100==round(fr/100)
     sprintf('%d %0.2f done',i, fr/nf)
  end
  imwrite(im_all(:,:,fr),fullfile(p,f),'tiff','Writemode','append');
end