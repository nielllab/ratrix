function [ims alphas names ext n]=validateImages(s)

ext='.png';
ims={};
alphas={};
names={};

[d n]=getImageNames(s);

tic
for i=1:length(d)

    name=d{i};

    [im m alpha]=loadRemoteImage(s,name,ext);

    if ~strcmp(class(im),'uint8') || ~ismember(length(size(im)),[2 3]) || (length(size(im))==3 && size(im,3)~=3) || isempty(alpha) || ~isempty(m)
        size(im)
        error('images must be png with alpha channel - unexpected image format for %s: %s',fullfile(s.directory,[name ext]),class(im))
    end

    if length(size(im))==3
        im=uint8(floor(sum(im,3)/3)); %convert to greyscale
    end

    names{end+1}=name;
    ims{end+1}=im;
    alphas{end+1}=alpha;
end

disp(sprintf('\nwasted %g secs loading %d images\n',toc,i))