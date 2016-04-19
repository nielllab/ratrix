function [img, framerate] = readAlign2p_sbx(fn, align,showImg)

sbxread(fn,1,1);            % read one frame to read the header of the image sequence
global info;                % this contains the information about the structure of the image


if (exist([fn '.align'])==0 & align)
    
    [m,T] = sbxalignx(fn,0:info.max_idx-1);   %
    save([fn '.align'],'m','T');
    display(sprintf('Done %s: Aligned %d images in %d min',fn,info.max_idx,round(toc/60)))
end

sbxread(fn,1,1);            % read one frame to read the header of the image sequence


if align
    figure
    plot(info.aligned.T);
    
    m=double(info.aligned.m);
    upper = prctile(m(:),95)*1.2;
    lower = min(m(:));
    if showImg
        figure
        imagesc(m,[lower upper]); colormap gray; title('sbx aligned mean'); axis equal
    end
    drawnow
end



img = zeros(info.sz(1),info.sz(2),info.max_idx,'uint16');
for i = 1:info.max_idx;
    im = sbxread(fn,i-1,1);
    if align
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

framerate = info.resfreq/info.config.lines;

