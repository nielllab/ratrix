function plotGratingResp(phase, amp, rep, xpts, ypts)
    figure
        subplot(2,3,1);
        if rep==3
            range=[1 2];
        elseif rep==4
            range = [1 4]
        else
            range = [2 4];
        end
        
        im = mat2im(phase(:,:,1),jet,range);
        imAmp = amp; imAmp= imAmp/prctile(imAmp(:),90);
        imAmp(imAmp>1)=1;
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('x')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        
        
        subplot(2,3,2);
        im = mat2im(phase(:,:,2),jet,[1 3]);
        imAmp = amp; imAmp= imAmp/prctile(imAmp(:),90);
        imAmp(imAmp>1)=1;
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('y')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        
        if rep ==1
            range=[1 3.75];
        elseif rep==2
            range = [1 1.75];
        elseif rep==3 | rep==4
            range = [0 6];
        end
        subplot(2,3,3);
        im = mat2im(phase(:,:,3),jet,range);
        imAmp = amp; imAmp= imAmp/prctile(imAmp(:),90);
        imAmp(imAmp>1)=1;
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('sf')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        
        subplot(2,3,4);
        im = mat2im(phase(:,:,4),jet,[1 3]);
        imAmp = amp; imAmp= imAmp/prctile(imAmp(:),90);
        imAmp(imAmp>1)=1;
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('tf')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        
%         subplot(2,3,5);
%         im = mat2im(phase(:,:,5),jet,[1 10]);
%         imAmp = amp; imAmp= imAmp/prctile(imAmp(:),95);
%         imAmp(imAmp>1)=1;
%         im = im.*(repmat(imAmp,[1 1 3]));
%         imshow(im); title('speed')
%         hold on; plot(ypts,xpts,'w.','Markersize',2)