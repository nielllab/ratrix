function out = scaleMovie(in,gb,class)
out = feval(class,1)
d = whos('out');

bytesPerPix = d.bytes;
pixPerFrame = gb*1000*1000*1000/size(in,3)/bytesPerPix;
sz(1) = size(in,1);
sz(2) = size(in,2);
scale = pixPerFrame/prod(sz);
if scale<1
    sz = round(sqrt(scale)*sz);
    
    out = zeros(sz(1),sz(2),size(in,3),class);
    
    fprintf('resizing...')
    tic
    for i=1:size(in,3)
        out(:,:,i) = feval(class,imresize(in(:,:,i),sz));
    end
    toc
else
    out = in;
end
end