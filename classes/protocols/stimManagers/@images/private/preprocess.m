function preprocess
loc='\\132.239.158.169\resources\paintbrush_flashlight\paintbrush_flashlight\';
d=dir([loc '*.png']);
imNames={d.name};

for i=1:length(imNames)
    [im{i} garbage alpha{i}]=imread([loc imNames{i}]);

    if length(size(im{i}))==3
        'im was rgb'
        im{i}=uint8(floor(sum(im{i},3)/3)); %convert to greyscale
    end
end

[out deltas]=prepareImages(im,alpha,[1200 1920*length(imNames)/2],.95,.9);

outDir='C:\Documents and Settings\rlab\Desktop\preprocessedImages\';
mkdir(outDir);
imWidth=size(out,2)/length(imNames);
for i=1:length(imNames)
    colRange=(1:imWidth)+(i-1)*imWidth;
    im=out(:,colRange);
    imwrite(im,[outDir imNames{i}],'png');
    [t1 t2 t3]=imread([outDir imNames{i}]);
    if ~isempty(t3)
        imshow(t3);
        error('saved alpha not empty')
    end
    if ~all(t1(:)==im(:))
        imshow([im t1 im-t1])
        error('saved not equal to read')
    end
end
end